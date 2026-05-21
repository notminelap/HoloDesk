// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Meditation Mode Content

/// Guided meditation — breathing circle, ambient visuals, session timer with spatial audio.
struct MeditationContent: View {
    
    @Environment(SpatialAudioManager.self) private var audio
    
    @State private var isActive = false
    @State private var breathPhase: BreathPhase = .inhale
    @State private var breathScale: CGFloat = 0.6
    @State private var phaseProgress: Double = 0.0
    @State private var sessionMinutes = 5
    @State private var remainingSeconds = 300
    @State private var completedBreaths = 0
    
    @State private var sessionTimer: Timer?
    @State private var breathTimer: Timer?
    
    // Ambient rotating background particle/glow angle
    @State private var ambientRotation = 0.0
    
    enum BreathPhase: String {
        case inhale = "Breathe In"
        case hold = "Hold"
        case exhale = "Breathe Out"
        case rest = "Rest"
        
        var duration: Double {
            switch self {
            case .inhale: return 4
            case .hold:   return 4
            case .exhale: return 6
            case .rest:   return 2
            }
        }
        
        var instruction: String {
            switch self {
            case .inhale: return "Feel the clean spatial energy filling your lungs"
            case .hold:   return "Suspend your breath, finding stillness in the void"
            case .exhale: return "Release all stress, tension, and noise into the air"
            case .rest:   return "Relax completely, returning to your natural state"
            }
        }
        
        var color: Color {
            switch self {
            case .inhale: return Color(red: 0.15, green: 0.72, blue: 0.75) // Calm Teal
            case .hold:   return Color(red: 0.48, green: 0.38, blue: 0.88) // Deep Royal Purple
            case .exhale: return Color(red: 0.95, green: 0.45, blue: 0.35) // Warm Coral
            case .rest:   return Color(red: 0.38, green: 0.68, blue: 0.48) // Peaceful Sage
            }
        }
        
        var next: BreathPhase {
            switch self {
            case .inhale: return .hold
            case .hold:   return .exhale
            case .exhale: return .rest
            case .rest:   return .inhale
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Interactive spatial background with slowly rotating atmospheric glow
            ZStack {
                Color(white: 0.02)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [breathPhase.color.opacity(0.18), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 280
                        )
                    )
                    .blur(radius: 40)
                    .scaleEffect(isActive ? breathScale * 1.2 : 0.8)
                    .offset(x: isActive ? CGFloat(sin(ambientRotation) * 40) : 0,
                            y: isActive ? CGFloat(cos(ambientRotation) * 40) : 0)
            }
            .ignoresSafeArea()
            .onAppear {
                if isActive {
                    withAnimation(.linear(duration: 20).repeatForever(autoreverses: true)) {
                        ambientRotation = .pi * 2
                    }
                }
            }
            
            VStack {
                if isActive {
                    activeSession
                        .transition(.spatialAppear)
                } else {
                    startScreen
                        .transition(.spatialAppear)
                }
            }
        }
        .onDisappear {
            stopAllTimers()
        }
    }
    
    // MARK: - Start Screen
    
    private var startScreen: some View {
        VStack(spacing: 24) {
            // Top icon with radial soft glow
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.08))
                    .frame(width: 80, height: 80)
                    .blur(radius: 5)
                
                Image(systemName: "leaf.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.green, Color.teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, 16)
            
            VStack(spacing: 8) {
                Text("Spatial Sanctuary")
                    .font(.system(size: 24, weight: .light, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(1.2)
                
                Text("Align your breathing with synthesized atmospheric soundscapes.")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            // Duration Picker
            VStack(alignment: .leading, spacing: 10) {
                Text("SESSION DURATION")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.leading, 6)
                
                HStack(spacing: 10) {
                    ForEach([1, 3, 5, 10, 15], id: \.self) { mins in
                        Button {
                            sessionMinutes = mins
                            remainingSeconds = mins * 60
                            audio.playSFX(.softTick)
                            HapticManager.shared.lightTap()
                        } label: {
                            Text("\(mins)m")
                                .font(.system(size: 13, weight: sessionMinutes == mins ? .bold : .regular))
                                .foregroundStyle(sessionMinutes == mins ? .white : .white.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    sessionMinutes == mins
                                    ? Color.green.opacity(0.18)
                                    : Color.white.opacity(0.03),
                                    in: RoundedRectangle(cornerRadius: 10)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(
                                            sessionMinutes == mins ? Color.green.opacity(0.4) : Color.white.opacity(0.06),
                                            lineWidth: 1
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                        .hoverGlow()
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Start Button
            Button {
                startSession()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12))
                    Text("Begin Meditation")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.green.opacity(0.6), Color.teal.opacity(0.6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: Capsule()
                )
                .overlay(
                    Capsule()
                        .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: Color.green.opacity(0.25), radius: 12, y: 4)
            }
            .buttonStyle(.plain)
            .hoverGlow()
            .spatialDepth()
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .padding(16)
    }
    
    // MARK: - Active Session
    
    private var activeSession: some View {
        VStack(spacing: 20) {
            // Header timer bar
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(breathPhase.color)
                        .frame(width: 6, height: 6)
                    Text(breathPhase.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(breathPhase.color)
                        .tracking(1.5)
                }
                
                Spacer()
                
                Text(formatTime(remainingSeconds))
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.04), in: Capsule())
            }
            .padding(.horizontal, 12)
            
            Spacer()
            
            // Breathing Circle & Radial Ring
            ZStack {
                // Expanding cosmic pulse wave
                Circle()
                    .stroke(breathPhase.color.opacity(0.2), lineWidth: 2)
                    .frame(width: 140, height: 140)
                    .scaleEffect(breathScale * 1.5)
                    .opacity(isActive ? (2.0 - breathScale) : 0)
                
                // Pulsing ambient glow rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .strokeBorder(
                            breathPhase.color.opacity(0.12 - Double(i) * 0.03),
                            lineWidth: 1
                        )
                        .frame(width: 130 + CGFloat(i) * 36, height: 130 + CGFloat(i) * 36)
                        .scaleEffect(breathScale)
                }
                
                // Sweeping precise circular progress ring
                Circle()
                    .stroke(Color.white.opacity(0.04), lineWidth: 4)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: CGFloat(phaseProgress))
                    .stroke(
                        AngularGradient(
                            colors: [breathPhase.color.opacity(0.2), breathPhase.color],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                // Solid core breathing bubble
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                breathPhase.color.opacity(0.35),
                                breathPhase.color.opacity(0.15)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(breathScale)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.5),
                                        breathPhase.color.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .scaleEffect(breathScale)
                    )
                
                // Breath HUD Text
                VStack(spacing: 4) {
                    Text(breathPhase.rawValue)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("\(Int(ceil(breathPhase.duration * (1.0 - phaseProgress))))s")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .padding(.vertical, 12)
            
            // Dynamic Breathing Instruction Text
            Text(breathPhase.instruction)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .frame(height: 36)
                .padding(.horizontal, 24)
            
            Spacer()
            
            // Footer Info & Control Actions
            HStack(spacing: 20) {
                // Breaths stats
                HStack(spacing: 6) {
                    Image(systemName: "lungs.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.teal)
                    Text("\(completedBreaths) breaths")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
                
                // End Session button
                Button {
                    endSession()
                } label: {
                    Text("End Session")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.red.opacity(0.8))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.red.opacity(0.2), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .hoverGlow()
            }
            .padding(.bottom, 8)
        }
        .padding(14)
    }
    
    // MARK: - Logic & Timers
    
    private func startSession() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            isActive = true
        }
        remainingSeconds = sessionMinutes * 60
        completedBreaths = 0
        
        // Start atmospheric sweep sound
        audio.playSFX(.cosmicSweep)
        
        // Turn on drone if available
        audio.startAmbientDrone()
        
        // Begin organic breathing cycle
        breathPhase = .inhale
        animateBreath()
        startTimer()
        
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: true)) {
            ambientRotation = .pi * 2
        }
    }
    
    private func animateBreath() {
        guard isActive else { return }
        
        // Play gentle transition click
        audio.playSFX(.softTick)
        
        // Apply breathing size scale with spring
        applyBreathAnimation()
        
        // Reset sweeping progress ring and animate it over phase duration
        phaseProgress = 0.0
        withAnimation(.linear(duration: breathPhase.duration)) {
            phaseProgress = 1.0
        }
        
        // Schedule next phase
        breathTimer?.invalidate()
        breathTimer = Timer.scheduledTimer(withTimeInterval: breathPhase.duration, repeats: false) { _ in
            guard isActive else { return }
            if breathPhase == .rest {
                completedBreaths += 1
            }
            breathPhase = breathPhase.next
            animateBreath()
        }
    }
    
    private func applyBreathAnimation() {
        let responseTime: Double = breathPhase.duration
        
        // Use a customized spring-like easeInOut for incredibly natural feel
        withAnimation(.easeInOut(duration: responseTime)) {
            switch breathPhase {
            case .inhale: breathScale = 1.15
            case .hold:   breathScale = 1.15
            case .exhale: breathScale = 0.65
            case .rest:   breathScale = 0.65
            }
        }
    }
    
    private func startTimer() {
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            guard isActive else {
                timer.invalidate()
                return
            }
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                completeSession()
            }
        }
    }
    
    private func completeSession() {
        audio.playSFX(.success) // Play majestic pentatonic success
        audio.stopAmbientDrone()
        HapticManager.shared.success()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            isActive = false
        }
        stopAllTimers()
    }
    
    private func endSession() {
        audio.playSFX(.windowClose) // Play descending swoop
        audio.stopAmbientDrone()
        HapticManager.shared.lightTap()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            isActive = false
        }
        stopAllTimers()
    }
    
    private func stopAllTimers() {
        sessionTimer?.invalidate()
        sessionTimer = nil
        breathTimer?.invalidate()
        breathTimer = nil
    }
    
    private func formatTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
