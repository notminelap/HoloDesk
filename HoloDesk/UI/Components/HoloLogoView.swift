// ─────────────────────────────────────────────────────────────────────────────
//                 H O L O G R A P H I C   3 D   L O G O   V I E W
// ─────────────────────────────────────────────────────────────────────────────
//   HoloDesk Zero-Dependency Procedural Vector Logo - visionOS 2.0+
//
//   Copyright (c) 2027 Radhesh Ranvijay. All Rights Reserved.
//   Designed and engineered by Radhesh Ranvijay for Apple Swift Student Challenge.
// ─────────────────────────────────────────────────────────────────────────────


import SwiftUI

// MARK: - Premium Holographic Spatial Logo View

/// A mathematically-rendered, 3D holographic isometric spatial computing logo.
/// Designed specifically for the Apple Swift Student Challenge 2027 to deliver
/// a breathtaking visual signature. Utilizes layered geometries, additive blend
/// modes, ambient orbits, and moving glass caustics completely in code.
struct HoloLogoView: View {
    
    /// Outer frame bounding box.
    var size: CGFloat = 80
    
    /// Controls whether micro-animations (rotations, pulses, shimmer) run.
    var isAnimated: Bool = true
    
    @State private var rotation: Double = 0
    @State private var breatheScale: CGFloat = 1.0
    @State private var shineOffset: CGFloat = -1.0
    
    var body: some View {
        ZStack {
            // 1. Ambient Nebula Glow Backing (HSL Hues)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.holoPrimary.opacity(0.25),
                            Color.holoTertiary.opacity(0.12),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.65
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)
                .scaleEffect(breatheScale)
            
            // 2. Neon Orbit Ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.holoPrimary.opacity(0.7),
                            Color.clear,
                            Color.holoTertiary.opacity(0.8),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: max(1.0, size * 0.02)
                )
                .frame(width: size * 1.15, height: size * 1.15)
                .rotationEffect(.degrees(rotation * -0.7))
            
            // 3. Floating Orbital Particle Orbs
            ForEach(0..<4, id: \.self) { i in
                let angle = Double(i) * .pi / 2.0
                Circle()
                    .fill(Color.holoSecondary)
                    .frame(width: max(2.0, size * 0.04), height: max(2.0, size * 0.04))
                    .offset(
                        x: cos(rotation * 0.02 + angle) * (size * 0.575),
                        y: sin(rotation * 0.02 + angle) * (size * 0.575)
                    )
                    .shadow(color: Color.holoSecondary, radius: size * 0.04)
            }
            
            // 4. Central Glowing Core (Conceptualized from Workspace Presets)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white,
                            Color.holoSecondary.opacity(0.95),
                            Color.holoPrimary.opacity(0.4),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.26
                    )
                )
                .frame(width: size * 0.52, height: size * 0.52)
                .scaleEffect(0.92 + breatheScale * 0.08)
                .blur(radius: size * 0.02)
            
            // 5. Overlapping Isometric Holographic Prisms
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    let angle = Double(i) * 120.0
                    prismPanel(angle: angle)
                }
            }
            .rotationEffect(.degrees(rotation))
            
            // 6. Curved Glass Highlight Ring (Refractive Specular Glint)
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.7), .clear, .white.opacity(0.25), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: max(1.0, size * 0.015)
                )
                .frame(width: size * 0.98, height: size * 0.98)
                .mask(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .black, .clear],
                                startPoint: UnitPoint(x: shineOffset, y: shineOffset),
                                endPoint: UnitPoint(x: shineOffset + 0.4, y: shineOffset + 0.4)
                            )
                        )
                )
            
            // 7. Core Specular Reflection Overlay
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.45), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.5, height: size * 0.16)
                .offset(y: -size * 0.28)
                .blur(radius: size * 0.025)
        }
        .frame(width: size, height: size)
        .onAppear {
            if isAnimated {
                // Calm, celestial rotation of outer geometry
                withAnimation(.linear(duration: 22).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                // Breathing glow animation linked conceptually to Meditation view
                withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                    breatheScale = 1.06
                }
                // Periodic caustics shimmer sweep
                withAnimation(.linear(duration: 6.0).repeatForever(autoreverses: false)) {
                    shineOffset = 1.6
                }
            }
        }
    }
    
    // MARK: - Prism Geometric Assembly
    
    @ViewBuilder
    private func prismPanel(angle: Double) -> some View {
        let colors: [Color] = {
            if angle == 0 {
                return [Color.holoPrimary, Color.holoSecondary]
            } else if angle == 120 {
                return [Color.holoSecondary, Color.holoTertiary]
            } else {
                // Creative high-end spectrum gradient
                return [Color.holoTertiary, Color(red: 1.0, green: 0.45, blue: 0.72)]
            }
        }()
        
        ZStack {
            // Glass Prism Face
            RoundedRectangle(cornerRadius: size * 0.1)
                .fill(
                    LinearGradient(
                        colors: colors.map { $0.opacity(0.55) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.26, height: size * 0.48)
            
            // Refractive Inner Bevel Edge
            RoundedRectangle(cornerRadius: size * 0.1)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.85),
                            .clear,
                            colors[0].opacity(0.4),
                            .white.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: max(0.5, size * 0.015)
                )
                .frame(width: size * 0.26, height: size * 0.48)
        }
        .offset(y: -size * 0.22)
        .rotationEffect(.degrees(angle))
        // Additive lighting blend mode creates true spatial compute aesthetics
        .blendMode(.plusLighter)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HoloLogoView(size: 200)
    }
}
