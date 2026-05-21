// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Window Snap Manager

/// Spatial window snapping — snap windows to grid positions, walls, or arrangements.
struct WindowSnapSystem {
    
    enum SnapLayout: String, CaseIterable, Identifiable {
        case arc          // Default arc layout
        case grid         // 2x3 grid
        case leftRight    // Two halves
        case stack        // Stacked vertically
        case circle       // Circular around user
        case timeline     // Horizontal timeline
        case amphitheater // Curved amphitheater rows
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .arc:          return "Arc"
            case .grid:         return "Grid"
            case .leftRight:    return "Split"
            case .stack:        return "Stack"
            case .circle:       return "Circle"
            case .timeline:     return "Timeline"
            case .amphitheater: return "Amphitheater"
            }
        }
        
        var emoji: String {
            switch self {
            case .arc:          return "🌈"
            case .grid:         return "▦"
            case .leftRight:    return "◧"
            case .stack:        return "▤"
            case .circle:       return "⭕"
            case .timeline:     return "→"
            case .amphitheater: return "🏛️"
            }
        }
        
        var iconName: String {
            switch self {
            case .arc:          return "circle.hexagongrid.fill"
            case .grid:         return "square.grid.2x2"
            case .leftRight:    return "rectangle.split.2x1"
            case .stack:        return "rectangle.stack"
            case .circle:       return "circle"
            case .timeline:     return "arrow.left.and.right"
            case .amphitheater: return "person.line.dotted.person"
            }
        }
    }
    
    /// Calculate positions for windows in a given layout.
    static func positions(for layout: SnapLayout, windowCount: Int) -> [SIMD3<Float>] {
        switch layout {
        case .arc:
            return arcPositions(count: windowCount)
        case .grid:
            return gridPositions(count: windowCount)
        case .leftRight:
            return splitPositions(count: windowCount)
        case .stack:
            return stackPositions(count: windowCount)
        case .circle:
            return circlePositions(count: windowCount)
        case .timeline:
            return timelinePositions(count: windowCount)
        case .amphitheater:
            return amphitheaterPositions(count: windowCount)
        }
    }
    
    // MARK: - Layout Algorithms
    
    private static func arcPositions(count: Int) -> [SIMD3<Float>] {
        let radius: Float = 1.8
        let arcSpan: Float = .pi * 0.8
        let startAngle: Float = -.pi * 0.4
        
        return (0..<count).map { i in
            let angle = startAngle + (arcSpan / Float(max(count - 1, 1))) * Float(i)
            return SIMD3(sin(angle) * radius, 1.4, -cos(angle) * radius)
        }
    }
    
    private static func gridPositions(count: Int) -> [SIMD3<Float>] {
        let cols = 3
        let spacingX: Float = 0.65
        let spacingY: Float = 0.55
        let startX: Float = -spacingX * Float(cols - 1) / 2
        
        return (0..<count).map { i in
            let col = i % cols
            let row = i / cols
            return SIMD3(startX + Float(col) * spacingX, 1.6 - Float(row) * spacingY, -2.0)
        }
    }
    
    private static func splitPositions(count: Int) -> [SIMD3<Float>] {
        let half = count / 2
        return (0..<count).map { i in
            let side: Float = i < half ? -0.7 : 0.7
            let indexInSide = i < half ? i : i - half
            return SIMD3(side, 1.6 - Float(indexInSide) * 0.45, -1.8)
        }
    }
    
    private static func stackPositions(count: Int) -> [SIMD3<Float>] {
        return (0..<count).map { i in
            SIMD3(0, 1.8 - Float(i) * 0.4, -1.8 - Float(i) * 0.15)
        }
    }
    
    private static func circlePositions(count: Int) -> [SIMD3<Float>] {
        let radius: Float = 1.5
        return (0..<count).map { i in
            let angle = (Float.pi * 2 / Float(count)) * Float(i) - .pi / 2
            return SIMD3(cos(angle) * radius, 1.4, sin(angle) * radius - 1.5)
        }
    }
    
    private static func timelinePositions(count: Int) -> [SIMD3<Float>] {
        let spacing: Float = 0.6
        let startX = -Float(count - 1) * spacing / 2
        return (0..<count).map { i in
            SIMD3(startX + Float(i) * spacing, 1.4, -1.8)
        }
    }
    
    private static func amphitheaterPositions(count: Int) -> [SIMD3<Float>] {
        var positions: [SIMD3<Float>] = []
        let rows = 2
        let perRow = (count + rows - 1) / rows
        
        for i in 0..<count {
            let row = i / perRow
            let col = i % perRow
            let radius: Float = 1.6 + Float(row) * 0.6
            let arcSpan: Float = .pi * 0.7
            let startAngle: Float = -.pi * 0.35
            let angle = startAngle + (arcSpan / Float(max(perRow - 1, 1))) * Float(col)
            let y: Float = 1.5 - Float(row) * 0.4
            positions.append(SIMD3(sin(angle) * radius, y, -cos(angle) * radius))
        }
        return positions
    }
}

// MARK: - Snap Layout Picker View

struct SnapLayoutPickerView: View {
    @Environment(WorkspaceStore.self) private var store
    @Binding var isPresented: Bool
    @State private var selectedLayout: WindowSnapSystem.SnapLayout = .arc
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "rectangle.3.group")
                    .font(.system(size: 16))
                    .foregroundStyle(.holoPrimary)
                Text("Window Layout")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(WindowSnapSystem.SnapLayout.allCases) { layout in
                    layoutCard(layout)
                }
            }
            
            // Apply button
            Button {
                applyLayout()
                isPresented = false
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Apply Layout")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(LinearGradient.accentGradient, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(width: 360)
        .glassBackground(cornerRadius: 24)
    }
    
    private func layoutCard(_ layout: WindowSnapSystem.SnapLayout) -> some View {
        let isActive = selectedLayout == layout
        return Button {
            withAnimation(.spatialInteract) { selectedLayout = layout }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: layout.iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(isActive ? .holoPrimary : .white.opacity(0.5))
                Text(layout.displayName)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(isActive ? 1 : 0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isActive ? Color.holoPrimary.opacity(0.2) : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isActive ? Color.holoPrimary.opacity(0.4) : .clear, lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func applyLayout() {
        let positions = WindowSnapSystem.positions(for: selectedLayout, windowCount: store.activeWindows.count)
        for (index, position) in positions.enumerated() {
            if index < store.activeWindows.count {
                store.updateWindowPosition(id: store.activeWindows[index].id, position: position)
            }
        }
        HapticManager.shared.modeSwitched()
    }
}
