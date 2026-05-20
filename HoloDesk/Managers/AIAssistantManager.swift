// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - AI Workspace Assistant

/// The AI helper that lives in your room. Responds to natural language,
/// suggests workspace arrangements, and automates spatial tasks.
@Observable
final class AIAssistantManager {
    
    var isActive = false
    var isThinking = false
    var currentMessage = ""
    var messageHistory: [AssistantMessage] = []
    var suggestedAction: SuggestedAction?
    
    struct AssistantMessage: Identifiable {
        let id = UUID()
        let text: String
        let isUser: Bool
        let timestamp: Date
    }
    
    enum SuggestedAction {
        case switchMode(WorkspaceMode)
        case addWindow(WindowType)
        case saveWorkspace
        case rearrangeWindows
        case openImmersive
    }
    
    // MARK: - Greetings
    
    private let greetings = [
        "Hey! I'm your spatial assistant. What workspace would you like today?",
        "Welcome back to HoloDesk! Ready to set up your space?",
        "Good to see you! Shall I load your last workspace?",
    ]
    
    private let tips = [
        "💡 Try saying \"Prepare coding workspace\" to set up for development.",
        "💡 You can grab files with your hands and place them anywhere in your room.",
        "💡 Try Cinema mode — I'll dim the lights and set up a giant screen.",
        "💡 Save your workspace so it remembers where everything is tomorrow.",
        "💡 Different rooms can have different setups. Try the multi-room feature!",
    ]
    
    // MARK: - Activation
    
    func activate() {
        isActive = true
        let greeting = greetings.randomElement() ?? greetings[0]
        addAssistantMessage(greeting)
        
        // Add a tip after a delay
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            let tip = tips.randomElement() ?? tips[0]
            addAssistantMessage(tip)
        }
    }
    
    func deactivate() {
        isActive = false
    }
    
    // MARK: - Process User Input
    
    @MainActor
    func processInput(_ input: String, store: WorkspaceStore, windowManager: WindowManager) {
        let text = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        addUserMessage(input)
        
        isThinking = true
        
        // Simulated AI processing — in production, connect to LLM API
        Task {
            try? await Task.sleep(for: .milliseconds(800))
            
            let response = generateResponse(for: text, store: store)
            addAssistantMessage(response.message)
            
            if let action = response.action {
                suggestedAction = action
                executeAction(action, store: store, windowManager: windowManager)
            }
            
            isThinking = false
        }
    }
    
    // MARK: - Response Generation
    
    private struct AIResponse {
        let message: String
        let action: SuggestedAction?
    }
    
    private func generateResponse(for input: String, store: WorkspaceStore) -> AIResponse {
        // Intent matching
        if input.contains("work") && (input.contains("mode") || input.contains("setup") || input.contains("coding") || input.contains("productivity")) {
            return AIResponse(
                message: "Setting up Work mode — multiple monitors with all your productivity tools. 🧑‍💻",
                action: .switchMode(.work)
            )
        }
        
        if input.contains("study") || input.contains("learn") || input.contains("read") {
            return AIResponse(
                message: "Study mode coming up — notes front and center, minimal distractions. 📚",
                action: .switchMode(.study)
            )
        }
        
        if input.contains("cinema") || input.contains("movie") || input.contains("watch") || input.contains("film") {
            return AIResponse(
                message: "Cinema mode activated — dimming the lights and setting up the big screen. 🎬",
                action: .switchMode(.cinema)
            )
        }
        
        if input.contains("game") || input.contains("gaming") || input.contains("play") {
            return AIResponse(
                message: "Gaming mode! Ultra-wide display with minimal UI. Let's go! 🎮",
                action: .switchMode(.gaming)
            )
        }
        
        if input.contains("save") {
            return AIResponse(
                message: "Saving your current workspace layout. You can reload it anytime! 💾",
                action: .saveWorkspace
            )
        }
        
        if input.contains("add") || input.contains("open") {
            if input.contains("note") {
                return AIResponse(message: "Adding a Notes window for you. ✏️", action: .addWindow(.notes))
            }
            if input.contains("music") {
                return AIResponse(message: "Adding Music player. 🎵", action: .addWindow(.music))
            }
            if input.contains("calendar") {
                return AIResponse(message: "Here's your Calendar. 📅", action: .addWindow(.calendar))
            }
            if input.contains("message") {
                return AIResponse(message: "Opening Messages. 💬", action: .addWindow(.messages))
            }
            if input.contains("file") {
                return AIResponse(message: "Opening Files browser. 📂", action: .addWindow(.files))
            }
        }
        
        if input.contains("clean") || input.contains("reset") || input.contains("clear") {
            return AIResponse(
                message: "Clearing all windows. Fresh start! ✨",
                action: .rearrangeWindows
            )
        }
        
        if input.contains("immersive") || input.contains("3d") || input.contains("spatial") {
            return AIResponse(
                message: "Opening immersive space — your files will float around you as real objects! 🌌",
                action: .openImmersive
            )
        }
        
        // Default
        let defaults = [
            "I can help you set up workspaces! Try asking me to \"open work mode\" or \"add notes\".",
            "Want me to switch modes? Just say the mode name like \"cinema\" or \"study\".",
            "I can save your workspace, add windows, or switch between modes. What would you like?",
        ]
        return AIResponse(message: defaults.randomElement() ?? defaults[0], action: nil)
    }
    
    // MARK: - Action Execution
    
    @MainActor
    private func executeAction(_ action: SuggestedAction, store: WorkspaceStore, windowManager: WindowManager) {
        switch action {
        case .switchMode(let mode):
            Task {
                await windowManager.transitionToMode(mode, in: store)
            }
        case .addWindow(let type):
            windowManager.spawnWindow(type: type, in: store)
        case .saveWorkspace:
            store.saveCurrentWorkspace()
        case .rearrangeWindows:
            store.clearAllWindows()
        case .openImmersive:
            break // Handled by ContentView
        }
    }
    
    // MARK: - Helpers
    
    private func addUserMessage(_ text: String) {
        messageHistory.append(AssistantMessage(text: text, isUser: true, timestamp: Date()))
    }
    
    private func addAssistantMessage(_ text: String) {
        currentMessage = text
        messageHistory.append(AssistantMessage(text: text, isUser: false, timestamp: Date()))
    }
}
