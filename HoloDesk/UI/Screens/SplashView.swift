// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Splash Screen

/// Cinematic launch animation — the "boot sequence" of HoloDesk.
/// Shows a spatial-themed logo reveal with particle effects and
/// smooth transition into the onboarding or main workspace.
struct SplashView: View {
    
    @Binding var isComplete: Bool
    
    @State private var phase: SplashPhase = .logo
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    @State private var rotationAngle: Double = 0
    @State private var particlePhase: Double = 0
    @State private var backgroundOpacity: Double = 1
    
    enum SplashPhase {
        case logo, text, transition
    }
    
    var body: some View {
        ZStack {
            // Deep space background
            Color.black.opacity(backgroundOpacity)
                .ignoresSafeArea()
            
            // Starfield
            starfield
            
            // Main content
            VStack(spacing: 24) {
                Spacer()
                
                // Logo orb
                ZStack {
                    // Outer rotating rings
                    ForEach(0..<3, id: \.self) { ring in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.holoPrimary.opacity(0.4 - Double(ring) * 0.1),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: 120 + CGFloat(ring) * 30, height: 120 + CGFloat(ring) * 30)
                            .rotationEffect(.degrees(rotationAngle * (ring % 2 == 0 ? 1 : -0.7)))
                            .scaleEffect(ringScale)
                            .opacity(ringOpacity)
                    }
                    
                    // Particle orbit
                    ForEach(0..<12, id: \.self) { i in
                        Circle()
                            .fill(Color.holoPrimary.opacity(0.5))
                            .frame(width: 2.5, height: 2.5)
                            .offset(
                                x: cos(particlePhase + Double(i) * .pi / 6) * 80,
                                y: sin(particlePhase + Double(i) * .pi / 6) * 80
                            )
                            .blur(radius: 0.5)
                            .opacity(ringOpacity)
                    }
                    
                    // Core glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.holoPrimary.opacity(0.6),
                                    Color.holoPrimary.opacity(0.2),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: glowRadius)
                    
                    // Logo
                    ZStack {
                        // Glass backing
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.holoPrimary.opacity(0.4),
                                        Color.holoSecondary.opacity(0.2),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "cube.transparent.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        // Specular highlight
                        Ellipse()
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.5), .clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                            .frame(width: 48, height: 18)
                            .offset(y: -24)
                            .blur(radius: 2)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                }
                
                // Text
                VStack(spacing: 8) {
                    Text("HOLODESK")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .tracking(8)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(textOpacity)
                    
                    Text("S P A T I A L   W O R K S P A C E")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(4)
                        .foregroundStyle(.white.opacity(0.4))
                        .opacity(subtitleOpacity)
                }
                
                Spacer()
                
                // Bottom branding
                VStack(spacing: 4) {
                    Text("Built by")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.2))
                    
                    Text("NOTMINELAP INDUSTRIES")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.35))
                }
                .opacity(subtitleOpacity)
                .padding(.bottom, 40)
            }
        }
        .onAppear { startAnimation() }
    }
    
    // MARK: - Starfield
    
    private var starfield: some View {
        Canvas { context, size in
            for i in 0..<60 {
                let x = Double(i * 17 + 13).truncatingRemainder(dividingBy: size.width)
                let y = Double(i * 31 + 7).truncatingRemainder(dividingBy: size.height)
                let brightness = Double(i * 7 % 10) / 10.0 * 0.3
                let dotSize = Double(i % 3 + 1)
                
                context.fill(
                    Circle().path(in: CGRect(x: x, y: y, width: dotSize, height: dotSize)),
                    with: .color(.white.opacity(brightness))
                )
            }
        }
        .opacity(backgroundOpacity)
    }
    
    // MARK: - Animation Sequence
    
    private func startAnimation() {
        // Phase 1: Logo reveal (0s - 0.8s)
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            logoScale = 1.0
            logoOpacity = 1.0
            glowRadius = 15
        }
        
        // Phase 2: Rings appear (0.3s)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
            ringScale = 1.0
            ringOpacity = 1.0
        }
        
        // Phase 3: Start rotation (0.5s)
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false).delay(0.5)) {
            rotationAngle = 360
        }
        
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false).delay(0.5)) {
            particlePhase = .pi * 2
        }
        
        // Phase 4: Title text (1s)
        withAnimation(.easeOut(duration: 0.6).delay(1.0)) {
            textOpacity = 1.0
        }
        
        // Phase 5: Subtitle + branding (1.5s)
        withAnimation(.easeOut(duration: 0.5).delay(1.5)) {
            subtitleOpacity = 1.0
        }
        
        // Phase 6: Transition out (3.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                backgroundOpacity = 0
                isComplete = true
            }
        }
    }
}
