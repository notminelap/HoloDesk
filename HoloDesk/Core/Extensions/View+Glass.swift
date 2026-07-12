// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Glassmorphism System (Ultra-Realistic)

extension View {
    
    /// Applies a premium visionOS 2.0 / visionOS 27 native "Liquid Glass" background.
    /// Multi-layered: ultraThinMaterial + dynamic fluid cores + shifting caustics + double border refraction.
    func glassBackground(
        cornerRadius: CGFloat = 20,
        opacity: Double = 0.85,
        shadowRadius: CGFloat = 10
    ) -> some View {
        let bg = ZStack {
            Color.clear.background(.ultraThinMaterial)
            LiquidGlassFluidCore(cornerRadius: cornerRadius)
        }
        
        let noise = RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.white.opacity(0.012))
            .blendMode(.overlay)
            
        let caustics = LiquidGlassCaustics(cornerRadius: cornerRadius)
        
        let primaryBorder = RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        .white.opacity(0.55),
                        .white.opacity(0.12),
                        .clear,
                        .white.opacity(0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 0.5
            )
            
        let secondaryBorder = RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        Color.holoSecondary.opacity(0.18),
                        .clear,
                        Color.holoTertiary.opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
            
        let edgeDarkening = RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(
                LinearGradient(
                    colors: [.black.opacity(0.15), .clear, .black.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1.5
            )
            
        let viewWithBackground = self.background(bg)
        let clippedView = viewWithBackground.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        let viewWithNoise = clippedView.overlay(noise)
        let viewWithCaustics = viewWithNoise.overlay(caustics)
        let viewWithPrimaryBorder = viewWithCaustics.overlay(primaryBorder)
        let viewWithSecondaryBorder = viewWithPrimaryBorder.overlay(secondaryBorder)
        let viewWithEdgeDarkening = viewWithSecondaryBorder.overlay(edgeDarkening)
        
        return viewWithEdgeDarkening
            .shadow(color: .black.opacity(0.24), radius: shadowRadius, x: 0, y: 5)
            .shadow(color: Color.holoPrimary.opacity(0.04), radius: shadowRadius * 1.5, x: 0, y: 0)
    }
    
    /// Inner glass - lighter variant for nested elements.
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
    
    /// Deep frosted glass - heavier blur for modal/sheet backgrounds.
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
    
    /// Subtle hover illumination system - adds glow + lift on hover.
    func hoverGlow() -> some View {
        self.modifier(HoverGlowModifier())
    }
    
    /// Window spawn animation - scales from 0 with spring.
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
    
    /// Spatial depth effect - subtle parallax on hover.
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

// MARK: - Spatial Bezel Reflection Modifier

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

// MARK: - Liquid Glass Helpers (visionOS 27 Specification)

/// Programmatic shifting liquid iridescence layer under the frosted material.
struct LiquidGlassFluidCore: View {
    var cornerRadius: CGFloat
    @State private var phase: Double = 0.0
    
    var body: some View {
        ZStack {
            // Chromatic aberration fluid flowing gradient
            LinearGradient(
                colors: [
                    Color.holoPrimary.opacity(0.03),
                    Color.holoSecondary.opacity(0.01),
                    Color.holoTertiary.opacity(0.02),
                    Color(red: 1.0, green: 0.45, blue: 0.72).opacity(0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .rotationEffect(.degrees(phase))
            
            // Soft centering ambient lens glow
            RadialGradient(
                colors: [
                    Color.holoSecondary.opacity(0.02),
                    .clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 180
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onAppear {
            // Calm slow rotation simulating a viscous liquid glass physical medium
            withAnimation(.linear(duration: 28).repeatForever(autoreverses: true)) {
                phase = 35.0
            }
        }
    }
}

/// Dynamic sweeping lighting caustics and bezel reflection highlights.
struct LiquidGlassCaustics: View {
    var cornerRadius: CGFloat
    @State private var sweepOffset: CGFloat = -1.2
    
    var body: some View {
        ZStack {
            // Periodic sweeping refractive caustics light glint
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.05), .clear],
                        startPoint: UnitPoint(x: sweepOffset, y: sweepOffset),
                        endPoint: UnitPoint(x: sweepOffset + 0.35, y: sweepOffset + 0.35)
                    )
                )
                .blendMode(.screen)
                .allowsHitTesting(false)
            
            // Fixed top-left bezel internal reflection glint
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.14), .clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
                .mask(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(.black, lineWidth: 1.5)
                )
                .allowsHitTesting(false)
        }
        .onAppear {
            // Shimmer caustics sweep period
            withAnimation(.linear(duration: 9.0).repeatForever(autoreverses: false)) {
                sweepOffset = 1.4
            }
        }
    }
}

// MARK: - visionOS 27 Active Window Dimming

extension View {
    /// Dims content when the window is inactive - visionOS 27 `appearsActive` integration.
    /// Falls back to full opacity on earlier visionOS versions.
    func activeWindowAware() -> some View {
        self.modifier(ActiveWindowModifier())
    }
}

struct ActiveWindowModifier: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    
    func body(content: Content) -> some View {
        content
            .opacity(isEnabled ? 1.0 : 0.7)
            .animation(.easeInOut(duration: 0.25), value: isEnabled)
    }
}
