// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Desk Interaction Engine

/// Full desk interaction system — tap to spawn, throw to wall, stack, flick, snap.
@Observable
final class DeskInteractionEngine {
    
    var magneticEdges = true
    var snapToGrid = true
    var gridSpacing: Float = 0.05   // 5cm grid
    var throwVelocityThreshold: Float = 2.0
    var stackingEnabled = true
    
    struct WindowStack: Identifiable {
        let id = UUID()
        var windowIds: [UUID]
        var position: SIMD3<Float>
        var isExpanded = false
    }
    
    var stacks: [WindowStack] = []
    
    // MARK: - Desk Tap to Spawn
    
    /// Handle tap on desk surface — spawn window at tap location
    func handleDeskTap(at position: SIMD3<Float>, store: WorkspaceStore) {
        // Spawn a new window at the tapped desk position, slightly above surface
        let spawnPos = SIMD3(position.x, position.y + 0.3, position.z)
        let window = SpatialWindow(type: .notes, position: spawnPos)
        store.activeWindows.append(window)
        HapticManager.shared.mediumTap()
    }
    
    // MARK: - Throw to Wall
    
    /// Detect throw gesture and move window to wall display mode
    func handleThrow(windowId: UUID, velocity: SIMD3<Float>, store: WorkspaceStore) {
        let speed = length(velocity)
        guard speed > throwVelocityThreshold else { return }
        
        if let index = store.activeWindows.firstIndex(where: { $0.id == windowId }) {
            // Move to wall (far away, facing user)
            let direction = normalize(velocity)
            store.activeWindows[index].position = SIMD3(direction.x * 3, 1.8, direction.z * 3)
            store.activeWindows[index].size = store.activeWindows[index].type.defaultSize * 1.5
            HapticManager.shared.success()
        }
    }
    
    // MARK: - Flick to Dismiss
    
    func handleFlick(windowId: UUID, store: WorkspaceStore) {
        store.activeWindows.removeAll { $0.id == windowId }
        HapticManager.shared.lightTap()
    }
    
    // MARK: - Stack Windows
    
    func stackWindows(_ ids: [UUID], at position: SIMD3<Float>) {
        let stack = WindowStack(windowIds: ids, position: position)
        stacks.append(stack)
    }
    
    // MARK: - Snap to Grid
    
    func snapPosition(_ position: SIMD3<Float>) -> SIMD3<Float> {
        guard snapToGrid else { return position }
        return SIMD3(
            round(position.x / gridSpacing) * gridSpacing,
            position.y,
            round(position.z / gridSpacing) * gridSpacing
        )
    }
    
    // MARK: - Magnetic Edges
    
    func applyMagneticSnap(_ window: SpatialWindow, nearbyWindows: [SpatialWindow]) -> SIMD3<Float> {
        guard magneticEdges else { return window.position }
        var pos = window.position
        let threshold: Float = 0.05
        
        for other in nearbyWindows where other.id != window.id {
            // Snap to right edge of other window
            let otherRight = other.position.x + Float(other.size.x) / 2000
            let thisLeft = pos.x - Float(window.size.x) / 2000
            if abs(otherRight - thisLeft) < threshold {
                pos.x = otherRight + Float(window.size.x) / 2000
            }
            // Snap to same Y
            if abs(other.position.y - pos.y) < threshold {
                pos.y = other.position.y
            }
        }
        return pos
    }
    
    // MARK: - Corner Quick Actions
    
    enum DeskCorner { case topLeft, topRight, bottomLeft, bottomRight }
    
    func cornerAction(_ corner: DeskCorner) -> String {
        switch corner {
        case .topLeft:     return "Quick Capture"
        case .topRight:    return "Screenshot"
        case .bottomLeft:  return "Voice Command"
        case .bottomRight: return "App Launcher"
        }
    }
}

// MARK: - Spatial Radial Menu

/// Gesture-triggered radial action menu — appears on long press in space.
struct SpatialRadialMenu: View {
    @Binding var isPresented: Bool
    var onAction: (String) -> Void
    
    private let actions: [(icon: String, label: String, color: Color)] = [
        ("plus.rectangle", "Add Window", .blue),
        ("square.and.arrow.down", "Save", .green),
        ("camera", "Screenshot", .orange),
        ("mic", "Voice", .red),
        ("wand.and.stars", "AI Assist", .purple),
        ("rectangle.grid.2x2", "Layouts", .cyan),
        ("gearshape", "Settings", .gray),
        ("moon", "Focus", .indigo),
    ]
    
    var body: some View {
        ZStack {
            ForEach(Array(actions.enumerated()), id: \.offset) { i, action in
                let angle = Double(i) * (360.0 / Double(actions.count)) - 90
                let rad = angle * .pi / 180
                let radius: CGFloat = 80
                
                Button {
                    onAction(action.label)
                    isPresented = false
                    HapticManager.shared.lightTap()
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: action.icon)
                            .font(.system(size: 16))
                            .foregroundStyle(action.color)
                            .frame(width: 36, height: 36)
                            .background(action.color.opacity(0.15), in: Circle())
                        Text(action.label)
                            .font(.system(size: 7, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .buttonStyle(.plain)
                .offset(x: cos(rad) * radius, y: sin(rad) * radius)
            }
            
            // Center dot
            Circle()
                .fill(.white.opacity(0.2))
                .frame(width: 20, height: 20)
        }
        .frame(width: 240, height: 240)
    }
}
