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
    @State private var bootLineIndex: Int = -1
    @State private var bootCharIndex: Int = 0
    @State private var showBootSequence = false
    @State private var bootComplete = false
    
    // Typewriter state
    @State private var linesTyped: [String] = []
    @State private var currentLineText: String = ""
    @State private var cursorBlink = false
    @State private var activeTimer: Timer? = nil
    
    private var loadProgress: Double {
        Double(linesTyped.count) / Double(max(bootLines.count, 1))
    }
    
    /// The cinematic boot lines — each appears with a typewriter effect.
    private let bootLines: [(status: String, text: String)] = [
        ("OK",  "Swift Runtime 6.0 .............. loaded"),
        ("OK",  "RealityKit Engine .............. initialized"),
        ("OK",  "Liquid Glass v2 Renderer ....... compiled"),
        ("OK",  "Spatial Audio (13 channels) .... online"),
        ("OK",  "Apple Intelligence ............. ready"),
        ("OK",  "LiDAR Mesh Scanner ............. calibrating"),
        ("OK",  "Hand Tracking (22 joints) ...... active"),
        ("OK",  "HoloPet Companion .............. awakening"),
        ("OK",  "32 Spatial Applications ........ loaded"),
        ("OK",  "104 Swift Source Files ......... verified"),
        ("OK",  "24,673 Lines of Code .......... clean"),
    ]
    
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
                    
                    // Progressive loading track
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 3)
                        .frame(width: 145, height: 145)
                        .opacity(ringOpacity)
                    
                    // Progressive loading ring
                    Circle()
                        .trim(from: 0.0, to: CGFloat(loadProgress))
                        .stroke(
                            LinearGradient(
                                colors: [.cyan, .holoPrimary, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                        )
                        .frame(width: 145, height: 145)
                        .rotationEffect(.degrees(rotationAngle * 0.4))
                        .opacity(ringOpacity)
                    
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
                    
                    HoloLogoView(size: 80, isAnimated: true)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }
                
                // Text + Boot Sequence
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
                    
                    Text("SPATIAL OPERATING SYSTEM v3.0.0")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .tracking(2)
                        .foregroundStyle(.cyan.opacity(0.5))
                        .opacity(subtitleOpacity)
                    
                    // Progressive loading bar
                    if showBootSequence {
                        HStack(spacing: 8) {
                            ProgressView(value: loadProgress, total: 1.0)
                                .progressViewStyle(.linear)
                                .tint(.cyan)
                                .frame(width: 160)
                            
                            Text("\(Int(loadProgress * 100))%")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(.cyan)
                        }
                        .transition(.opacity)
                        .opacity(subtitleOpacity)
                        .padding(.top, 4)
                    }
                }
                
                // Boot Sequence Terminal
                if showBootSequence {
                    bootSequenceView
                        .transition(.opacity)
                        .padding(.top, 8)
                }
                
                Spacer()
                
                // Bottom branding
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "swift")
                            .font(.system(size: 10))
                            .foregroundStyle(.orange.opacity(0.6))
                        Text("Swift Student Challenge")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    
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
        .onDisappear { activeTimer?.invalidate() }
        .onTapGesture { skipBoot() }
    }
    
    // MARK: - Starfield
    
    private var starfield: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                
                // 1. Draw central Cyan/Blue dynamic spatial nebula cloud
                let cyanOffset = CGPoint(
                    x: sin(time * 0.25) * 40.0,
                    y: cos(time * 0.30) * 30.0
                )
                let cyanCenter = CGPoint(x: center.x + cyanOffset.x, y: center.y + cyanOffset.y)
                let cyanRadius = max(size.width, size.height) * 0.65
                let cyanGradient = Gradient(colors: [
                    Color(red: 0.0, green: 0.75, blue: 0.95).opacity(0.14),
                    Color.holoPrimary.opacity(0.06),
                    .clear
                ])
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .shading(.radialGradient(cyanGradient, center: cyanCenter, startRadius: 0, endRadius: cyanRadius))
                )
                
                // 2. Draw secondary Purple/Magenta cosmic dust cloud
                let purpleOffset = CGPoint(
                    x: cos(time * 0.22) * 55.0,
                    y: sin(time * 0.33) * 35.0
                )
                let purpleCenter = CGPoint(x: center.x + purpleOffset.x, y: center.y + purpleOffset.y)
                let purpleRadius = max(size.width, size.height) * 0.55
                let purpleGradient = Gradient(colors: [
                    Color(red: 0.65, green: 0.15, blue: 0.85).opacity(0.11),
                    Color(red: 0.95, green: 0.20, blue: 0.55).opacity(0.04),
                    .clear
                ])
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .shading(.radialGradient(purpleGradient, center: purpleCenter, startRadius: 0, endRadius: purpleRadius))
                )
                
                // 3. Draw 80 dynamically twinkling and organically drifting stars
                for i in 0..<80 {
                    // Seeded base positioning utilizing modular arithmetic
                    let seedX = Double((i * 47 + 19) % 1000) / 1000.0
                    let seedY = Double((i * 31 + 13) % 1000) / 1000.0
                    let baseSpeed = 0.4 + Double((i * 7) % 6) * 0.18
                    let twinkle = 0.15 + 0.65 * sin(time * baseSpeed + Double(i))
                    let sizeSeed = Double((i * 13) % 4) * 0.7 + 0.8 // Size range from 0.8 to 2.9
                    
                    // Subtle organic gravitational drift
                    let driftX = sin(time * 0.05 + Double(i)) * 6.0
                    let driftY = cos(time * 0.04 + Double(i)) * 6.0
                    
                    let x = seedX * size.width + driftX
                    let y = seedY * size.height + driftY
                    
                    // Keep stars wrapped inside screen boundaries
                    let boundedX = x.truncatingRemainder(dividingBy: size.width)
                    let boundedY = y.truncatingRemainder(dividingBy: size.height)
                    
                    let starRect = CGRect(
                        x: boundedX - sizeSeed / 2,
                        y: boundedY - sizeSeed / 2,
                        width: sizeSeed,
                        height: sizeSeed
                    )
                    
                    // Add high-end radial light halos to larger stars
                    if sizeSeed > 2.0 {
                        let glowRect = starRect.insetBy(dx: -sizeSeed * 1.5, dy: -sizeSeed * 1.5)
                        let glowGradient = Gradient(colors: [Color.white.opacity(twinkle * 0.25), .clear])
                        context.fill(
                            Path(ellipseIn: glowRect),
                            with: .shading(.radialGradient(glowGradient, center: CGPoint(x: boundedX, y: boundedY), startRadius: 0, endRadius: sizeSeed * 2.0))
                        )
                    }
                    
                    context.fill(
                        Path(ellipseIn: starRect),
                        with: .color(.white.opacity(max(0.0, twinkle)))
                    )
                }
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
        
        // Phase 5: Subtitle (1.3s)
        withAnimation(.easeOut(duration: 0.5).delay(1.3)) {
            subtitleOpacity = 1.0
        }
        
        // Phase 6: Boot sequence starts (1.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeIn(duration: 0.3)) {
                showBootSequence = true
            }
            startBootSequence()
        }
    }
    
    // MARK: - Boot Sequence
    
    private func startBootSequence() {
        typeNextLine(index: 0)
    }
    
    private func typeNextLine(index: Int) {
        guard index < bootLines.count else {
            // All lines typed!
            withAnimation(.easeOut(duration: 0.3)) {
                bootComplete = true
            }
            HapticManager.shared.success()
            
            // Transition out after a brief moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    backgroundOpacity = 0
                    isComplete = true
                }
            }
            return
        }
        
        bootLineIndex = index
        let line = bootLines[index]
        let fullText = "[\(line.status)] \(line.text)"
        currentLineText = ""
        
        var charIndex = 0
        activeTimer = Timer.scheduledTimer(withTimeInterval: 0.006, repeats: true) { timer in
            guard charIndex < fullText.count else {
                timer.invalidate()
                linesTyped.append(fullText)
                currentLineText = ""
                typeNextLine(index: index + 1)
                return
            }
            
            let indexStart = fullText.startIndex
            let indexEnd = fullText.index(indexStart, offsetBy: charIndex + 1)
            currentLineText = String(fullText[indexStart..<indexEnd])
            charIndex += 1
            
            if charIndex % 4 == 0 {
                HapticManager.shared.lightTap()
            }
        }
    }
    
    private func skipBoot() {
        guard !bootComplete else { return }
        activeTimer?.invalidate()
        linesTyped = bootLines.map { "[\($0.status)] \($0.text)" }
        currentLineText = ""
        bootLineIndex = bootLines.count
        bootComplete = true
        HapticManager.shared.success()
        
        withAnimation(.easeInOut(duration: 0.5)) {
            backgroundOpacity = 0
            isComplete = true
        }
    }
    
    // MARK: - Boot Sequence View
    
    private var bootSequenceView: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Header line
            Text("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                .font(.system(size: 7, weight: .regular, design: .monospaced))
                .foregroundStyle(.green.opacity(0.3))
            
            // Boot lines (already fully typed)
            ForEach(linesTyped, id: \.self) { line in
                Text(line)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(.green.opacity(0.7))
            }
            
            // Currently typing line with a pulsing cursor
            if !currentLineText.isEmpty {
                HStack(spacing: 1) {
                    Text(currentLineText)
                    Text("█")
                        .opacity(cursorBlink ? 1 : 0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.25).repeatForever()) {
                                cursorBlink.toggle()
                            }
                        }
                }
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundStyle(.green)
            }
            
            // Footer
            if bootComplete {
                Text("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    .font(.system(size: 7, weight: .regular, design: .monospaced))
                    .foregroundStyle(.green.opacity(0.3))
                
                Text("ALL SYSTEMS NOMINAL ✓")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.green)
                    .padding(.top, 2)
                
                Text("Welcome. Your workspace is ready.")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(.cyan.opacity(0.8))
                    .padding(.top, 1)
                
                Text("Double-tap / pinch anywhere to skip calibration")
                    .font(.system(size: 7, weight: .regular, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.2))
                    .padding(.top, 1)
            }
        }
        .frame(maxWidth: 320, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.green.opacity(0.15), lineWidth: 0.5)
                )
        )
    }
}
