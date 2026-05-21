// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Glassmorphism System (Ultra-Realistic)

extension View {
    
    /// Applies a premium visionOS-native glass background with adaptive properties.
    /// Multi-layered: ultraThinMaterial + 3-stop gradient border + dual shadow + noise grain.
    func glassBackground(
        cornerRadius: CGFloat = 20,
        opacity: Double = 0.85,
        shadowRadius: CGFloat = 10
    ) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            // Subtle noise grain for realism
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.white.opacity(0.015))
                    .blendMode(.overlay)
            )
            // 3-stop refraction border
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.4),
                                .white.opacity(0.1),
                                .white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            // Inner edge highlight (top-left caustic)
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.12), .clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
            }
            // Primary shadow
            .shadow(color: .black.opacity(0.22), radius: shadowRadius, x: 0, y: 4)
            // Ambient occlusion shadow
            .shadow(color: .black.opacity(0.06), radius: shadowRadius * 2.5, x: 0, y: 10)
    }
    
    /// Inner glass — lighter variant for nested elements.
    /// Uses thinMaterial with subtle 2-stop border.
    func innerGlass(cornerRadius: CGFloat = 12) -> some View {
        self
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.14), .white.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
            )
    }
    
    /// Deep frosted glass — heavier blur for modal/sheet backgrounds.
    func deepGlass(cornerRadius: CGFloat = 24) -> some View {
        self
            .background(.thickMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 30, y: 12)
    }
    
    /// Frosted glass with accent tint.
    func accentGlass(color: Color, cornerRadius: CGFloat = 16) -> some View {
        self
            .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: cornerRadius))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [color.opacity(0.35), color.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: color.opacity(0.1), radius: 8, y: 2)
    }
    
    /// Subtle hover illumination system — adds glow + lift on hover.
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
    
    /// Transition: fade in from bottom with opacity.
    func spatialAppear() -> some View {
        self.modifier(SpatialAppearModifier())
    }
}

// MARK: - Spatial Appear Transition

extension AnyTransition {
    static var spatialAppear: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .move(edge: .bottom)).combined(with: .scale(scale: 0.95)),
            removal: .opacity.combined(with: .scale(scale: 0.9))
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
            .scaleEffect(isHovered ? 1.015 : 1.0)
            .shadow(color: .white.opacity(isHovered ? 0.05 : 0), radius: 12)
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
            .scaleEffect(isHovered ? 1.008 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isHovered)
            .onHover { isHovered = $0 }
    }
}

// MARK: - Spatial Appear Modifier

struct SpatialAppearModifier: ViewModifier {
    @State private var appeared = false
    
    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .scaleEffect(appeared ? 1 : 0.96)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                    appeared = true
                }
            }
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
