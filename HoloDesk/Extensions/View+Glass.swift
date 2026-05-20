// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Glassmorphism System

extension View {
    
    /// Applies a premium visionOS-native glass background with adaptive properties.
    func glassBackground(
        cornerRadius: CGFloat = 20,
        opacity: Double = 0.85,
        shadowRadius: CGFloat = 10
    ) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.35),
                                .white.opacity(0.08),
                                .white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: shadowRadius, x: 0, y: 4)
            .shadow(color: .black.opacity(0.05), radius: shadowRadius * 2, x: 0, y: 8)
    }
    
    /// Inner glass — lighter variant for nested elements.
    func innerGlass(cornerRadius: CGFloat = 12) -> some View {
        self
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.12), .white.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
            )
    }
    
    /// Subtle hover illumination system — adds glow on hover.
    func hoverGlow() -> some View {
        self.modifier(HoverGlowModifier())
    }
    
    /// Window spawn animation — scales from 0 with spring.
    func spawnAnimation(isPresented: Bool, delay: Double = 0) -> some View {
        self
            .scaleEffect(isPresented ? 1 : 0.3)
            .opacity(isPresented ? 1 : 0)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.75)
                .delay(delay),
                value: isPresented
            )
    }
    
    /// Spatial depth effect — subtle parallax on hover.
    func spatialDepth() -> some View {
        self.modifier(SpatialDepthModifier())
    }
    
    /// Frosted glass with accent tint.
    func accentGlass(color: Color, cornerRadius: CGFloat = 16) -> some View {
        self
            .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: cornerRadius))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(color.opacity(0.2), lineWidth: 0.5)
            )
    }
}

// MARK: - Hover Glow Modifier

struct HoverGlowModifier: ViewModifier {
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(isHovered ? 0.06 : 0))
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isHovered)
            .onHover { isHovered = $0 }
    }
}

// MARK: - Spatial Depth Modifier

struct SpatialDepthModifier: ViewModifier {
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(isHovered ? 0.3 : 0.15), radius: isHovered ? 20 : 10, y: isHovered ? 8 : 4)
            .scaleEffect(isHovered ? 1.01 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isHovered)
            .onHover { isHovered = $0 }
    }
}

// MARK: - Spatial Window Container

struct SpatialWindowStyle: ViewModifier {
    var width: CGFloat
    var height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .glassBackground()
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

extension View {
    func spatialWindow(width: CGFloat = 400, height: CGFloat = 350) -> some View {
        modifier(SpatialWindowStyle(width: width, height: height))
    }
}
