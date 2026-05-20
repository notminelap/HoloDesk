// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - AI Buddy View

/// A 3D animated AI companion that floats in your spatial workspace.
/// Can be placed anywhere via drag gestures. Breathes, reacts, and
/// shows status through dynamic animations.
struct AIBuddyView: View {
    
    @Environment(WorkspaceStore.self) private var store
    @Environment(WindowManager.self) private var windowManager
    @Bindable var assistant: AIAssistantManager
    
    @State private var isExpanded = false
    @State private var buddyScale: CGFloat = 1.0
    @State private var buddyRotation: Double = 0
    @State private var glowIntensity: Double = 0.3
    @State private var orbPhase: Double = 0
    @State private var isBouncing = false
    @State private var particlePhase: Double = 0
    @State private var moodColor: Color = .holoPrimary
    @State private var showChat = false
    @State private var userInput = ""
    
    // Mood system
    enum BuddyMood { case idle, listening, thinking, happy, excited }
    @State private var mood: BuddyMood = .idle
    
    var body: some View {
        VStack(spacing: 0) {
            // The 3D buddy orb
            buddyOrb
                .onTapGesture {
                    withAnimation(.spatialSpawn) {
                        showChat.toggle()
                        if showChat && !assistant.isActive {
                            assistant.activate()
                        }
                        mood = showChat ? .listening : .idle
                        HapticManager.shared.mediumTap()
                    }
                }
            
            // Chat panel (expands below buddy)
            if showChat {
                chatPanel
                    .transition(.spatialAppear)
            }
        }
        .onAppear { startAnimations() }
        .onChange(of: assistant.isThinking) { _, thinking in
            withAnimation(.spatialInteract) {
                mood = thinking ? .thinking : .idle
            }
        }
    }
    
    // MARK: - 3D Buddy Orb
    
    private var buddyOrb: some View {
        ZStack {
            // Outer glow ring
            ForEach(0..<3, id: \.self) { ring in
                Circle()
                    .stroke(
                        moodGradient.opacity(0.15 - Double(ring) * 0.04),
                        lineWidth: 2 - CGFloat(ring) * 0.5
                    )
                    .frame(width: 90 + CGFloat(ring) * 16, height: 90 + CGFloat(ring) * 16)
                    .rotationEffect(.degrees(orbPhase * (ring % 2 == 0 ? 1 : -1)))
                    .scaleEffect(1 + sin(orbPhase * 0.5) * 0.03)
            }
            
            // Particle field
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(moodColor.opacity(0.4))
                    .frame(width: 3, height: 3)
                    .offset(
                        x: cos(particlePhase + Double(i) * .pi / 4) * 50,
                        y: sin(particlePhase + Double(i) * .pi / 4) * 50
                    )
                    .blur(radius: 1)
            }
            
            // Core orb
            ZStack {
                // Background sphere
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                moodColor.opacity(0.8),
                                moodColor.opacity(0.4),
                                Color.black.opacity(0.3)
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 40
                        )
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: moodColor.opacity(glowIntensity), radius: 20)
                    .shadow(color: moodColor.opacity(glowIntensity * 0.5), radius: 40)
                
                // Glass overlay
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 72, height: 72)
                    .opacity(0.3)
                
                // Inner face / icon
                buddyFace
                
                // Top specular highlight
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.5), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(width: 40, height: 20)
                    .offset(y: -18)
                    .blur(radius: 2)
            }
            .scaleEffect(buddyScale)
            .rotationEffect(.degrees(buddyRotation))
        }
        .frame(width: 130, height: 130)
    }
    
    // MARK: - Buddy Face
    
    @ViewBuilder
    private var buddyFace: some View {
        switch mood {
        case .idle:
            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .symbolEffect(.breathe, options: .repeating)
            
        case .listening:
            Image(systemName: "ear.and.waveform")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white)
                .symbolEffect(.variableColor.iterative, options: .repeating)
            
        case .thinking:
            ZStack {
                // Spinning dots
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(.white)
                        .frame(width: 5, height: 5)
                        .offset(x: cos(orbPhase * 3 + Double(i) * .pi * 2 / 3) * 14,
                                y: sin(orbPhase * 3 + Double(i) * .pi * 2 / 3) * 14)
                }
            }
            
        case .happy:
            Image(systemName: "face.smiling.inverse")
                .font(.system(size: 26))
                .foregroundStyle(.white)
            
        case .excited:
            Image(systemName: "sparkle")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .symbolEffect(.bounce, options: .repeating)
        }
    }
    
    // MARK: - Mood Gradient
    
    private var moodGradient: LinearGradient {
        switch mood {
        case .idle:      return LinearGradient(colors: [.holoPrimary, .holoSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .listening: return LinearGradient(colors: [.green, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .thinking:  return LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .happy:     return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .excited:   return LinearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    // MARK: - Chat Panel
    
    private var chatPanel: some View {
        VStack(spacing: 0) {
            // Mode selector
            HStack(spacing: 6) {
                ForEach(AIAssistantManager.AIMode.allCases, id: \.rawValue) { mode in
                    Button {
                        assistant.aiMode = mode
                        HapticManager.shared.selectionChanged()
                    } label: {
                        HStack(spacing: 3) {
                            Text(mode.emoji)
                                .font(.system(size: 10))
                            Text(mode.rawValue)
                                .font(.system(size: 9, weight: assistant.aiMode == mode ? .bold : .medium))
                                .foregroundStyle(assistant.aiMode == mode ? .white : .white.opacity(0.5))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            assistant.aiMode == mode
                            ? AnyShapeStyle(LinearGradient.accentGradient.opacity(0.3))
                            : AnyShapeStyle(Color.clear)
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                // Clear history
                Button {
                    assistant.clearHistory()
                    HapticManager.shared.lightTap()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            
            Divider().overlay(Color.white.opacity(0.06))
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(assistant.messageHistory) { msg in
                            chatBubble(msg)
                                .id(msg.id)
                        }
                        
                        if assistant.isThinking {
                            thinkingBubble
                        }
                    }
                    .padding(10)
                }
                .frame(height: 200)
                .onChange(of: assistant.messageHistory.count) { _, _ in
                    if let last = assistant.messageHistory.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
            
            Divider().overlay(Color.white.opacity(0.06))
            
            // Quick actions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    quickChip("🧑‍💻 Work", action: "set up work mode")
                    quickChip("📚 Study", action: "switch to study mode")
                    quickChip("🎬 Cinema", action: "cinema mode")
                    quickChip("💡 Advice", action: "give me productivity advice")
                    quickChip("🧹 Clear", action: "clear all windows")
                    quickChip("💾 Save", action: "save workspace")
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
            }
            
            // Input
            HStack(spacing: 6) {
                // Gemini indicator
                Circle()
                    .fill(assistant.useGeminiAPI ? .green : .orange)
                    .frame(width: 6, height: 6)
                
                TextField("Ask Gemini...", text: $userInput)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
                    .onSubmit { sendMessage() }
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(userInput.isEmpty ? .white.opacity(0.2) : .holoPrimary)
                }
                .buttonStyle(.plain)
                .disabled(userInput.isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .innerGlass(cornerRadius: 14)
            .padding(8)
        }
        .frame(width: 320)
        .glassBackground(cornerRadius: 20)
    }
    
    // MARK: - Chat Bubble
    
    private func chatBubble(_ msg: AIAssistantManager.AssistantMessage) -> some View {
        HStack {
            if msg.isUser { Spacer(minLength: 40) }
            
            VStack(alignment: msg.isUser ? .trailing : .leading, spacing: 2) {
                Text(msg.text)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(msg.isUser ? 0.9 : 0.85))
                    .textSelection(.enabled)
                
                Text(msg.timestamp, style: .time)
                    .font(.system(size: 8))
                    .foregroundStyle(.white.opacity(0.2))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                msg.isUser
                ? AnyShapeStyle(LinearGradient.accentGradient.opacity(0.25))
                : AnyShapeStyle(Color.white.opacity(0.06)),
                in: RoundedRectangle(cornerRadius: 14)
            )
            
            if !msg.isUser { Spacer(minLength: 40) }
        }
    }
    
    private var thinkingBubble: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(moodColor)
                        .frame(width: 6, height: 6)
                        .scaleEffect(assistant.isThinking ? 1.3 : 0.7)
                        .animation(
                            .easeInOut(duration: 0.4).repeatForever().delay(Double(i) * 0.12),
                            value: assistant.isThinking
                        )
                }
                
                Text("Thinking with Gemini...")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .innerGlass(cornerRadius: 12)
            
            Spacer()
        }
    }
    
    // MARK: - Quick Chip
    
    private func quickChip(_ label: String, action: String) -> some View {
        Button {
            assistant.processInput(action, store: store, windowManager: windowManager)
        } label: {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .innerGlass(cornerRadius: 8)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        guard !userInput.isEmpty else { return }
        withAnimation(.spatialInteract) { mood = .thinking }
        assistant.processInput(userInput, store: store, windowManager: windowManager)
        userInput = ""
    }
    
    // MARK: - Animations
    
    private func startAnimations() {
        // Breathing scale
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            buddyScale = 1.05
        }
        
        // Glow pulse
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            glowIntensity = 0.6
        }
        
        // Orbit rotation
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            orbPhase = .pi * 2
        }
        
        // Particle orbit
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            particlePhase = .pi * 2
        }
        
        // Mood color update
        updateMoodColor()
    }
    
    private func updateMoodColor() {
        switch mood {
        case .idle:      moodColor = .holoPrimary
        case .listening: moodColor = .green
        case .thinking:  moodColor = .purple
        case .happy:     moodColor = .yellow
        case .excited:   moodColor = .pink
        }
    }
}
