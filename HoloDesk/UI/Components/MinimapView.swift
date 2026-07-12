// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Minimap View

/// Bird's-eye view of your spatial workspace showing window positions.
struct MinimapView: View {
    @Environment(WorkspaceStore.self) private var store
    @State private var isExpanded = false
    
    private let mapSize: CGFloat = 180
    private let scale: CGFloat = 40 // meters to points
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spatialInteract) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "map")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.holoSecondary)
                    if isExpanded {
                        Text("Minimap")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                    }
                }
                .padding(.horizontal, isExpanded ? 12 : 6)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Divider().overlay(Color.white.opacity(0.08))
                
                // Map canvas
                ZStack {
                    // Background grid
                    gridPattern
                    
                    // User position (center)
                    Circle()
                        .fill(.white)
                        .frame(width: 6, height: 6)
                        .overlay(
                            Circle()
                                .strokeBorder(.white.opacity(0.3), lineWidth: 0.5)
                                .frame(width: 14, height: 14)
                        )
                    
                    // Field of view cone
                    fovCone
                    
                    // Window markers
                    ForEach(store.activeWindows) { window in
                        windowMarker(window)
                    }
                }
                .frame(width: mapSize, height: mapSize)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(8)
                
                // Legend
                HStack(spacing: 12) {
                    legendItem(color: .white, label: "You")
                    legendItem(color: .holoPrimary, label: "Windows")
                }
                .padding(.bottom, 8)
            }
        }
        .frame(width: isExpanded ? 200 : 36)
        .glassBackground(cornerRadius: isExpanded ? 16 : 18)
        .animation(.spatialInteract, value: isExpanded)
    }
    
    // MARK: - Grid
    
    private var gridPattern: some View {
        Canvas { context, size in
            let step: CGFloat = 20
            for x in stride(from: 0, to: size.width, by: step) {
                context.stroke(
                    Path { p in p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height)) },
                    with: .color(.white.opacity(0.04)), lineWidth: 0.5
                )
            }
            for y in stride(from: 0, to: size.height, by: step) {
                context.stroke(
                    Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y)) },
                    with: .color(.white.opacity(0.04)), lineWidth: 0.5
                )
            }
        }
    }
    
    // MARK: - FOV Cone
    
    private var fovCone: some View {
        Path { path in
            let center = CGPoint(x: mapSize / 2, y: mapSize / 2)
            path.move(to: center)
            path.addLine(to: CGPoint(x: center.x - 30, y: center.y - 60))
            path.addLine(to: CGPoint(x: center.x + 30, y: center.y - 60))
            path.closeSubpath()
        }
        .fill(.white.opacity(0.04))
    }
    
    // MARK: - Window Marker
    
    private func windowMarker(_ window: SpatialWindow) -> some View {
        let x = mapSize / 2 + CGFloat(window.position.x) * scale
        let y = mapSize / 2 + CGFloat(window.position.z) * scale
        
        return RoundedRectangle(cornerRadius: 2)
            .fill(Color.windowAccent(for: window.type))
            .frame(width: 8, height: 6)
            .overlay(
                Image(systemName: window.type.iconName)
                    .font(.system(size: 4))
                    .foregroundStyle(.white)
            )
            .position(x: x, y: y)
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 5, height: 5)
            Text(label)
                .font(.system(size: 8))
                .foregroundStyle(.white.opacity(0.4))
        }
    }
}
