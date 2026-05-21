// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Meditation Mode Content

/// Guided meditation — breathing circle, ambient visuals, session timer.
struct MeditationContent: View {
    
    @State private var isActive = false
    @State private var breathPhase: BreathPhase = .inhale
    @State private var breathScale: CGFloat = 0.6
    @State private var sessionMinutes = 5
    @State private var remainingSeconds = 300
    @State private var completedBreaths = 0
    @State private var sessionTimer: Timer?
    @State private var breathTimer: Timer?
    
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
        
        var color: Color {
            switch self {
            case .inhale: return Color(hue: 0.55, saturation: 0.5, brightness: 0.9)
            case .hold:   return Color(hue: 0.6, saturation: 0.4, brightness: 0.8)
            case .exhale: return Color(hue: 0.75, saturation: 0.4, brightness: 0.7)
            case .rest:   return Color(hue: 0.65, saturation: 0.3, brightness: 0.6)
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
            // Background gradient
            LinearGradient(
                colors: [
                    breathPhase.color.opacity(0.15),
                    Color(white: 0.03)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            if isActive {
                activeSession
            } else {
                startScreen
            }
        }
        .onDisappear {
            sessionTimer?.invalidate()
            sessionTimer = nil
            breathTimer?.invalidate()
            breathTimer = nil
            isActive = false
        }
    }
    
    // MARK: - Start Screen
    
    private var startScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 36))
                .foregroundStyle(.green.opacity(0.6))
            
            Text("Meditation")
                .font(.system(size: 20, weight: .light, design: .rounded))
                .foregroundStyle(.white)
            
            Text("Find your center in spatial space")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.4))
            
            // Duration picker
            HStack(spacing: 12) {
                ForEach([3, 5, 10, 15, 20], id: \.self) { mins in
                    Button {
                        sessionMinutes = mins
                        remainingSeconds = mins * 60
                    } label: {
                        Text("\(mins)m")
                            .font(.system(size: 12, weight: sessionMinutes == mins ? .bold : .regular))
                            .foregroundStyle(sessionMinutes == mins ? .white : .white.opacity(0.4))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                sessionMinutes == mins
                                ? Color.green.opacity(0.2)
                                : Color.clear,
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Button {
                startSession()
            } label: {
                Text("Begin")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 10)
                    .background(.green.opacity(0.5), in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Active Session
    
    private var activeSession: some View {
        VStack(spacing: 20) {
            // Timer
            Text(formatTime(remainingSeconds))
                .font(.system(size: 14, weight: .light, design: .monospaced))
                .foregroundStyle(.white.opacity(0.4))
            
            Spacer()
            
            // Breathing circle
            ZStack {
                // Outer glow rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .strokeBorder(breathPhase.color.opacity(0.08 - Double(i) * 0.02), lineWidth: 1)
                        .frame(width: 120 + CGFloat(i) * 30, height: 120 + CGFloat(i) * 30)
                        .scaleEffect(breathScale + CGFloat(i) * 0.05)
                }
                
                // Main circle
                Circle()
                    .fill(breathPhase.color.opacity(0.25))
                    .frame(width: 100, height: 100)
                    .scaleEffect(breathScale)
                    .overlay(
                        Circle()
                            .strokeBorder(breathPhase.color.opacity(0.4), lineWidth: 1.5)
                            .scaleEffect(breathScale)
                    )
                
                // Center
                VStack(spacing: 4) {
                    Text(breathPhase.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                    Text("\(Int(breathPhase.duration))s")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            
            Spacer()
            
            // Stats
            HStack(spacing: 24) {
                VStack(spacing: 2) {
                    Text("\(completedBreaths)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Breaths")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.3))
                }
                
                VStack(spacing: 2) {
                    Text("\(sessionMinutes - remainingSeconds / 60)m")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Elapsed")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            
            // Stop
            Button {
                sessionTimer?.invalidate()
                sessionTimer = nil
                isActive = false
            } label: {
                Text("End Session")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .innerGlass(cornerRadius: 8)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
    }
    
    // MARK: - Logic
    
    private func startSession() {
        isActive = true
        remainingSeconds = sessionMinutes * 60
        completedBreaths = 0
        animateBreath()
        startTimer()
    }
    
    private func animateBreath() {
        guard isActive else { return }
        
        // Apply the current phase animation
        applyBreathAnimation()
        
        // Schedule phase transitions via Timer
        breathTimer?.invalidate()
        breathTimer = Timer.scheduledTimer(withTimeInterval: breathPhase.duration, repeats: false) { _ in
            guard isActive else { return }
            if breathPhase == .rest { completedBreaths += 1 }
            breathPhase = breathPhase.next
            animateBreath()
        }
    }
    
    private func applyBreathAnimation() {
        withAnimation(.easeInOut(duration: breathPhase.duration)) {
            switch breathPhase {
            case .inhale: breathScale = 1.0
            case .hold:   breathScale = 1.0
            case .exhale: breathScale = 0.6
            case .rest:   breathScale = 0.6
            }
        }
    }
    
    private func startTimer() {
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if remainingSeconds > 0 && isActive {
                remainingSeconds -= 1
            } else {
                timer.invalidate()
                sessionTimer = nil
                isActive = false
                HapticManager.shared.success()
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
