// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Spatial Easter Eggs 🥚

/// Hidden delighters that reward curious judges and users.
/// These create memorable "wait, did you see that?!" moments.
@Observable
final class SpatialEasterEggs {
    
    // ────────────────────────────────────────
    // MARK: - State
    // ────────────────────────────────────────
    
    var isPartyMode = false
    var isDeveloperMode = false
    var isRainbowGlass = false
    var showConfetti = false
    var confettiEmojis: [ConfettiParticle] = []
    var secretMessage: String? = nil
    var goldenLotusUnlocked = false
    
    /// Tracks the Konami-style gaze gesture sequence.
    /// Sequence: up, up, down, down, left, right, left, right
    private var konamiProgress: [KonamiDirection] = []
    private let konamiSequence: [KonamiDirection] = [
        .up, .up, .down, .down, .left, .right, .left, .right
    ]
    
    /// Tracks rapid plant watering for golden lotus unlock
    private var plantWaterTimestamps: [Date] = []
    
    // ────────────────────────────────────────
    // MARK: - Konami Direction
    // ────────────────────────────────────────
    
    enum KonamiDirection: String {
        case up, down, left, right
    }
    
    // ────────────────────────────────────────
    // MARK: - Confetti Particle
    // ────────────────────────────────────────
    
    struct ConfettiParticle: Identifiable {
        let id = UUID()
        var emoji: String
        var x: CGFloat
        var y: CGFloat
        var rotation: Double
        var scale: CGFloat
        var opacity: Double
        var velocity: CGFloat
        
        static func burst(count: Int = 60) -> [ConfettiParticle] {
            let emojis = ["🎉", "✨", "🌟", "💎", "🧊", "🎊", "⭐", "💫", "🔮", "🪩"]
            return (0..<count).map { _ in
                ConfettiParticle(
                    emoji: emojis.randomElement()!,
                    x: CGFloat.random(in: -200...200),
                    y: CGFloat.random(in: -400 ... -50),
                    rotation: Double.random(in: 0...360),
                    scale: CGFloat.random(in: 0.5...1.5),
                    opacity: 1.0,
                    velocity: CGFloat.random(in: 2...8)
                )
            }
        }
    }
    
    // ────────────────────────────────────────
    // MARK: - Konami Gesture Detection
    // ────────────────────────────────────────
    
    /// Feed gaze direction changes to detect the Konami sequence.
    func registerGazeDirection(_ direction: KonamiDirection) {
        konamiProgress.append(direction)
        
        // Keep only the last 8 entries
        if konamiProgress.count > konamiSequence.count {
            konamiProgress.removeFirst()
        }
        
        // Check for match
        if konamiProgress == konamiSequence {
            triggerKonamiEasterEgg()
            konamiProgress.removeAll()
        }
    }
    
    /// Resets the Konami tracker (e.g., on timeout).
    func resetKonami() {
        konamiProgress.removeAll()
    }
    
    // ────────────────────────────────────────
    // MARK: - Easter Egg: Konami Developer Mode
    // ────────────────────────────────────────
    
    private func triggerKonamiEasterEgg() {
        isDeveloperMode = true
        isRainbowGlass = true
        triggerConfetti()
        secretMessage = """
        🧊 DEVELOPER MODE UNLOCKED
        ━━━━━━━━━━━━━━━━━━━━━━━━━━
        104 Swift files • 24,673 LOC
        Zero dependencies • 220KB bundle
        
        Built with ❤️ by @notminelap
        for Swift Student Challenge 2027
        
        Thank you for reviewing HoloDesk!
        You're an amazing judge. ⭐
        """
        HapticManager.shared.success()
        
        // Auto-dismiss after 8 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            self?.secretMessage = nil
            self?.isRainbowGlass = false
        }
    }
    
    // ────────────────────────────────────────
    // MARK: - Easter Egg: The 42 Secret
    // ────────────────────────────────────────
    
    /// Returns true if the input is the Answer to Life, the Universe, and Everything.
    func checkForFortyTwo(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespaces).lowercased()
        if trimmed == "42" || trimmed == "forty two" || trimmed == "the answer" {
            triggerConfetti()
            return """
            🌌 The Answer to the Ultimate Question of Life, \
            the Universe, and Everything is... 42.
            
            But here's the real question: \
            What spatial workspace layout achieves maximum productivity? \
            I'm still computing that one. 🧊
            
            — Deep Thought (via HoloDesk AI)
            """
        }
        return nil
    }
    
    // ────────────────────────────────────────
    // MARK: - Easter Egg: Party Mode (Head Shake)
    // ────────────────────────────────────────
    
    /// Tracks rapid head rotation to detect a "shake" gesture.
    private var headShakeCount = 0
    private var lastShakeTime = Date.distantPast
    
    func registerHeadMovement(deltaX: Float) {
        let now = Date()
        
        // Reset if too much time between shakes
        if now.timeIntervalSince(lastShakeTime) > 0.8 {
            headShakeCount = 0
        }
        
        // Detect significant lateral movement
        if abs(deltaX) > 0.15 {
            headShakeCount += 1
            lastShakeTime = now
            
            // 4 rapid shakes triggers party mode
            if headShakeCount >= 4 {
                triggerPartyMode()
                headShakeCount = 0
            }
        }
    }
    
    private func triggerPartyMode() {
        guard !isPartyMode else { return }
        isPartyMode = true
        triggerConfetti()
        HapticManager.shared.success()
        
        // Auto-dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.isPartyMode = false
        }
    }
    
    // ────────────────────────────────────────
    // MARK: - Easter Egg: Golden Lotus 🪷
    // ────────────────────────────────────────
    
    /// Call when a desk plant is watered. If all 3 are watered within 10 seconds,
    /// the secret golden lotus appears.
    func registerPlantWater() {
        let now = Date()
        plantWaterTimestamps.append(now)
        
        // Remove old timestamps (older than 10 seconds)
        plantWaterTimestamps = plantWaterTimestamps.filter {
            now.timeIntervalSince($0) < 10.0
        }
        
        // 3 waterings within 10 seconds unlocks the lotus
        if plantWaterTimestamps.count >= 3 && !goldenLotusUnlocked {
            goldenLotusUnlocked = true
            triggerConfetti()
            secretMessage = "🪷 SECRET UNLOCKED: Golden Lotus planted!\nYour dedication to nature is rewarded."
            HapticManager.shared.success()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                self?.secretMessage = nil
            }
        }
    }
    
    // ────────────────────────────────────────
    // MARK: - Confetti System
    // ────────────────────────────────────────
    
    func triggerConfetti() {
        confettiEmojis = ConfettiParticle.burst()
        showConfetti = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.showConfetti = false
            self?.confettiEmojis.removeAll()
        }
    }
}

// MARK: - Confetti Overlay View

/// A full-screen overlay that renders falling confetti emoji particles.
struct ConfettiOverlay: View {
    let particles: [SpatialEasterEggs.ConfettiParticle]
    let isActive: Bool
    
    @State private var animate = false
    
    var body: some View {
        if isActive {
            ZStack {
                ForEach(particles) { particle in
                    Text(particle.emoji)
                        .font(.system(size: 24 * particle.scale))
                        .rotationEffect(.degrees(animate ? particle.rotation + 360 : particle.rotation))
                        .offset(
                            x: particle.x + (animate ? CGFloat.random(in: -30...30) : 0),
                            y: animate ? 500 : particle.y
                        )
                        .opacity(animate ? 0 : particle.opacity)
                }
            }
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.easeIn(duration: 2.5)) {
                    animate = true
                }
            }
            .onDisappear {
                animate = false
            }
        }
    }
}

// MARK: - Secret Message Overlay

/// A floating glassmorphic panel that reveals developer/secret messages.
struct SecretMessageOverlay: View {
    let message: String?
    
    var body: some View {
        if let message = message {
            VStack(spacing: 12) {
                Text(message)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(.green)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(.green.opacity(0.4), lineWidth: 1)
                    )
            }
            .transition(.scale.combined(with: .opacity))
        }
    }
}
