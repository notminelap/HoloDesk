// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - HoloPet 🐙 — Living Spatial Desk Companion

/// A procedurally animated desk creature that reacts to your workspace activity.
/// Lives on the nearest LiDAR-detected surface. Evolves as you use HoloDesk.
///
/// No 3D models — entirely rendered via SwiftUI + canvas for zero bundle impact.
@Observable
final class HoloPet {
    
    // ────────────────────────────────────────
    // MARK: - Identity
    // ────────────────────────────────────────
    
    let name = "Holo"
    var stage: EvolutionStage = .orb
    var experiencePoints = 0
    var totalInteractions = 0
    
    // ────────────────────────────────────────
    // MARK: - Mood System
    // ────────────────────────────────────────
    
    var mood: Mood = .idle
    var moodIntensity: Double = 0.5  // 0.0 = subtle, 1.0 = intense
    private var moodTimer: Date = Date()
    private var lastActivityTime: Date = Date()
    
    enum Mood: String, CaseIterable {
        case idle     = "Chillin'"
        case happy    = "Happy!"
        case curious  = "Curious..."
        case sleepy   = "Sleepy..."
        case excited  = "Excited!!"
        case shy      = "Hiding..."
        case dancing  = "Groovin' 🎵"
        case focused  = "Deep Focus"
        case proud    = "So proud!"
        
        var emoji: String {
            switch self {
            case .idle:     return "😊"
            case .happy:    return "😄"
            case .curious:  return "🧐"
            case .sleepy:   return "😴"
            case .excited:  return "🤩"
            case .shy:      return "🙈"
            case .dancing:  return "💃"
            case .focused:  return "🎯"
            case .proud:    return "🥹"
            }
        }
        
        var color: Color {
            switch self {
            case .idle:     return .cyan
            case .happy:    return .yellow
            case .curious:  return .purple
            case .sleepy:   return .indigo
            case .excited:  return .orange
            case .shy:      return .pink
            case .dancing:  return .green
            case .focused:  return .blue
            case .proud:    return .mint
            }
        }
    }
    
    // ────────────────────────────────────────
    // MARK: - Evolution
    // ────────────────────────────────────────
    
    enum EvolutionStage: Int, CaseIterable {
        case orb = 0        // Simple glowing sphere
        case blobby = 1     // Organic shape with wobble
        case creature = 2   // Eyes + antenna
        case companion = 3  // Full featured pet
        case cosmic = 4     // Transcended — glowing cosmic entity
        
        var displayName: String {
            switch self {
            case .orb:       return "Spark"
            case .blobby:    return "Blobby"
            case .creature:  return "Critter"
            case .companion: return "Companion"
            case .cosmic:    return "Cosmic"
            }
        }
        
        var xpToNext: Int {
            switch self {
            case .orb:       return 50
            case .blobby:    return 150
            case .creature:  return 400
            case .companion: return 1000
            case .cosmic:    return Int.max  // Final stage
            }
        }
        
        /// Number of decorative elements (tentacles, antennae, etc.)
        var featureCount: Int {
            switch self {
            case .orb:       return 0
            case .blobby:    return 2
            case .creature:  return 4
            case .companion: return 6
            case .cosmic:    return 8
            }
        }
    }
    
    // ────────────────────────────────────────
    // MARK: - Position & Animation
    // ────────────────────────────────────────
    
    var position: CGPoint = CGPoint(x: 60, y: 60)
    var bobOffset: CGFloat = 0
    var wiggleAngle: Double = 0
    var eyeDirection: CGPoint = .zero
    var isVisible = true
    
    // ────────────────────────────────────────
    // MARK: - Activity Reactions
    // ────────────────────────────────────────
    
    /// Call when a new window opens — pet gets excited.
    func onWindowOpened() {
        addXP(5)
        setMood(.excited, duration: 3)
        moodIntensity = 0.9
        totalInteractions += 1
    }
    
    /// Call when a window closes — pet is curious.
    func onWindowClosed() {
        addXP(2)
        setMood(.curious, duration: 2)
    }
    
    /// Call when music starts playing — pet dances!
    func onMusicStarted() {
        addXP(3)
        setMood(.dancing, duration: 10)
        moodIntensity = 1.0
    }
    
    /// Call when focus mode is entered — pet goes shy/quiet.
    func onFocusModeEntered() {
        addXP(8)
        setMood(.shy, duration: 5)
        moodIntensity = 0.3
    }
    
    /// Call when a workspace is saved — pet is proud.
    func onWorkspaceSaved() {
        addXP(10)
        setMood(.proud, duration: 4)
        moodIntensity = 0.8
    }
    
    /// Call when immersive space is opened — pet is excited.
    func onImmersiveSpaceOpened() {
        addXP(15)
        setMood(.excited, duration: 5)
        moodIntensity = 1.0
    }
    
    /// Periodic idle check — goes sleepy if no activity for 60s.
    func idleCheck() {
        let elapsed = Date().timeIntervalSince(lastActivityTime)
        if elapsed > 60 && mood != .sleepy {
            setMood(.sleepy, duration: 30)
            moodIntensity = 0.2
        } else if elapsed > 10 && mood == .excited {
            setMood(.idle, duration: 0)
        }
    }
    
    /// Call when user interacts with the pet directly (tap).
    func onPetTapped() {
        addXP(3)
        totalInteractions += 1
        
        // Cycle through happy reactions
        let reactions: [Mood] = [.happy, .excited, .dancing, .proud]
        let nextMood = reactions[totalInteractions % reactions.count]
        setMood(nextMood, duration: 4)
        moodIntensity = 1.0
        HapticManager.shared.lightTap()
    }
    
    // ────────────────────────────────────────
    // MARK: - Internal
    // ────────────────────────────────────────
    
    private func setMood(_ newMood: Mood, duration: TimeInterval) {
        mood = newMood
        lastActivityTime = Date()
        
        if duration > 0 {
            let capturedTime = lastActivityTime
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                // Only revert if no newer mood was set
                if self?.lastActivityTime == capturedTime {
                    self?.mood = .idle
                    self?.moodIntensity = 0.5
                }
            }
        }
    }
    
    private func addXP(_ points: Int) {
        experiencePoints += points
        
        // Check for evolution
        if experiencePoints >= stage.xpToNext, let nextStage = EvolutionStage(rawValue: stage.rawValue + 1) {
            experiencePoints = 0
            stage = nextStage
            setMood(.proud, duration: 5)
            moodIntensity = 1.0
            HapticManager.shared.success()
        }
    }
}

// MARK: - HoloPet View

/// Renders the desk pet as a procedural SwiftUI animation.
struct HoloPetView: View {
    @Bindable var pet: HoloPet
    
    @State private var bobPhase: Double = 0
    @State private var wigglePhase: Double = 0
    @State private var pulsePhase: Double = 0
    @State private var isAppeared = false
    
    var body: some View {
        VStack(spacing: 4) {
            // Pet body
            ZStack {
                // Glow aura
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [pet.mood.color.opacity(0.3 * pet.moodIntensity), .clear],
                            center: .center,
                            startRadius: 5,
                            endRadius: 40
                        )
                    )
                    .frame(width: 70, height: 70)
                    .scaleEffect(1.0 + 0.15 * sin(pulsePhase))
                
                // Main body
                petBody
                
                // Eyes (stage 2+)
                if pet.stage.rawValue >= EvolutionStage.creature.rawValue {
                    petEyes
                }
                
                // Decorative features
                petFeatures
            }
            .frame(width: 60, height: 60)
            .offset(y: CGFloat(sin(bobPhase) * (pet.mood == .dancing ? 6 : 3)))
            .rotationEffect(.degrees(pet.mood == .dancing ? sin(wigglePhase) * 15 : sin(wigglePhase) * 3))
            
            // Name + mood
            VStack(spacing: 1) {
                Text("\(pet.mood.emoji) \(pet.name)")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(pet.mood.rawValue)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundStyle(pet.mood.color.opacity(0.7))
                
                // XP bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.1))
                        Capsule()
                            .fill(pet.mood.color.opacity(0.6))
                            .frame(width: geo.size.width * xpProgress)
                    }
                }
                .frame(width: 40, height: 2)
                .padding(.top, 1)
            }
        }
        .padding(8)
        .innerGlass(cornerRadius: 16)
        .scaleEffect(isAppeared ? 1 : 0)
        .opacity(isAppeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                isAppeared = true
            }
            startAnimationLoops()
        }
        .onTapGesture {
            pet.onPetTapped()
        }
        .accessibilityLabel("HoloPet \(pet.name), mood: \(pet.mood.rawValue)")
    }
    
    // ────────────────────────────────────────
    // MARK: - Body Rendering
    // ────────────────────────────────────────
    
    @ViewBuilder
    private var petBody: some View {
        let size: CGFloat = pet.stage.rawValue >= 3 ? 36 : 28
        
        ZStack {
            // Core shape
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            pet.mood.color.opacity(0.9),
                            pet.mood.color.opacity(0.5),
                            pet.mood.color.opacity(0.2)
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)
            
            // Specular highlight
            Ellipse()
                .fill(.white.opacity(0.5))
                .frame(width: size * 0.4, height: size * 0.2)
                .offset(x: -size * 0.1, y: -size * 0.2)
                .blur(radius: 1)
            
            // Blobby wobble (stage 1+)
            if pet.stage.rawValue >= 1 {
                Circle()
                    .fill(pet.mood.color.opacity(0.3))
                    .frame(width: size * 0.8, height: size * 0.8)
                    .scaleEffect(
                        x: 1.0 + 0.1 * CGFloat(sin(wigglePhase * 1.3)),
                        y: 1.0 + 0.1 * CGFloat(cos(wigglePhase * 0.9))
                    )
            }
        }
    }
    
    // ────────────────────────────────────────
    // MARK: - Eyes
    // ────────────────────────────────────────
    
    private var petEyes: some View {
        HStack(spacing: 6) {
            petEye
            petEye
        }
        .offset(y: -2)
    }
    
    private var petEye: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 8, height: 8)
            Circle()
                .fill(.black)
                .frame(width: 4, height: 4)
                .offset(
                    x: pet.mood == .sleepy ? 0 : 1,
                    y: pet.mood == .sleepy ? 2 : 0
                )
        }
        .scaleEffect(y: pet.mood == .sleepy ? 0.3 : 1.0)
    }
    
    // ────────────────────────────────────────
    // MARK: - Decorative Features
    // ────────────────────────────────────────
    
    private var petFeatures: some View {
        ForEach(0..<pet.stage.featureCount, id: \.self) { i in
            let angle = (Double(i) / Double(max(pet.stage.featureCount, 1))) * .pi * 2
            let radius: CGFloat = 22
            
            Circle()
                .fill(pet.mood.color.opacity(0.6))
                .frame(width: 4, height: 4)
                .offset(
                    x: CGFloat(cos(angle + wigglePhase * 0.5)) * radius,
                    y: CGFloat(sin(angle + wigglePhase * 0.5)) * radius
                )
                .blur(radius: 0.5)
        }
    }
    
    // ────────────────────────────────────────
    // MARK: - Animation
    // ────────────────────────────────────────
    
    private var xpProgress: CGFloat {
        guard pet.stage.xpToNext > 0 && pet.stage.xpToNext < Int.max else { return 1.0 }
        return CGFloat(pet.experiencePoints) / CGFloat(pet.stage.xpToNext)
    }
    
    private func startAnimationLoops() {
        // Bob animation
        withAnimation(.easeInOut(duration: pet.mood == .dancing ? 0.4 : 1.5).repeatForever(autoreverses: true)) {
            bobPhase = .pi
        }
        // Wiggle animation
        withAnimation(.linear(duration: pet.mood == .dancing ? 0.8 : 3.0).repeatForever(autoreverses: false)) {
            wigglePhase = .pi * 2
        }
        // Pulse animation
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulsePhase = .pi
        }
    }
}
