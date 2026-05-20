// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - AI Assistant View

/// Floating AI assistant panel with chat interface and action buttons.
struct AIAssistantView: View {
    
    @Environment(WorkspaceStore.self) private var store
    @Environment(WindowManager.self) private var windowManager
    @Bindable var assistant: AIAssistantManager
    
    @State private var userInput = ""
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Toggle header
            Button {
                withAnimation(.spatialInteract) {
                    isExpanded.toggle()
                    if isExpanded && !assistant.isActive {
                        assistant.activate()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    // AI avatar
                    ZStack {
                        Circle()
                            .fill(LinearGradient.accentGradient)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    if isExpanded {
                        Text("HoloDesk AI")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .padding(.horizontal, isExpanded ? 12 : 0)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Divider().overlay(Color.white.opacity(0.08))
                
                // Chat messages
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(assistant.messageHistory) { message in
                            chatBubble(message)
                        }
                        
                        if assistant.isThinking {
                            thinkingIndicator
                        }
                    }
                    .padding(10)
                }
                .frame(height: 180)
                
                Divider().overlay(Color.white.opacity(0.08))
                
                // Quick actions
                quickActions
                
                // Input field
                HStack(spacing: 8) {
                    TextField("Ask me anything...", text: $userInput)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .innerGlass(cornerRadius: 12)
                    
                    Button {
                        guard !userInput.isEmpty else { return }
                        assistant.processInput(userInput, store: store, windowManager: windowManager)
                        userInput = ""
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.holoPrimary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(10)
            }
        }
        .frame(width: isExpanded ? 300 : 48)
        .glassBackground(cornerRadius: isExpanded ? 20 : 24)
        .animation(.spatialInteract, value: isExpanded)
    }
    
    // MARK: - Chat Bubble
    
    private func chatBubble(_ message: AIAssistantManager.AssistantMessage) -> some View {
        HStack {
            if message.isUser { Spacer(minLength: 30) }
            
            Text(message.text)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(message.isUser ? 0.9 : 0.8))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    message.isUser
                    ? Color.holoPrimary.opacity(0.3)
                    : Color.white.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 12)
                )
            
            if !message.isUser { Spacer(minLength: 30) }
        }
    }
    
    // MARK: - Thinking Indicator
    
    private var thinkingIndicator: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(.white.opacity(0.4))
                        .frame(width: 5, height: 5)
                        .scaleEffect(assistant.isThinking ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(i) * 0.15),
                            value: assistant.isThinking
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .innerGlass(cornerRadius: 12)
            Spacer()
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                quickActionChip("🧑‍💻 Work", action: "set up work mode")
                quickActionChip("📚 Study", action: "set up study mode")
                quickActionChip("🎬 Cinema", action: "start movie mode")
                quickActionChip("💾 Save", action: "save workspace")
                quickActionChip("✨ Reset", action: "clear everything")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
    }
    
    private func quickActionChip(_ label: String, action: String) -> some View {
        Button {
            assistant.processInput(action, store: store, windowManager: windowManager)
        } label: {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .innerGlass(cornerRadius: 10)
        }
        .buttonStyle(.plain)
    }
}
