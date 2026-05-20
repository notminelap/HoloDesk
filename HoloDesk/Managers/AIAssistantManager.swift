// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - AI Workspace Assistant (Gemini-Powered)

/// The AI brain of HoloDesk. Uses Google Gemini for free-form conversation
/// while maintaining instant local intent matching for workspace actions.
@Observable
final class AIAssistantManager {
    
    var isActive = false
    var isThinking = false
    var currentMessage = ""
    var messageHistory: [AssistantMessage] = []
    var suggestedAction: SuggestedAction?
    var aiMode: AIMode = .balanced
    var conversationCount = 0
    
    /// Whether to use Gemini API or local-only fallback
    var useGeminiAPI = true
    
    struct AssistantMessage: Identifiable {
        let id = UUID()
        let text: String
        let isUser: Bool
        let timestamp: Date
        var isStreaming: Bool = false
    }
    
    enum SuggestedAction {
        case switchMode(WorkspaceMode)
        case addWindow(WindowType)
        case saveWorkspace
        case rearrangeWindows
        case openImmersive
        case clearWindows
    }
    
    enum AIMode: String, CaseIterable {
        case creative = "Creative"
        case balanced = "Balanced"
        case precise = "Precise"
        
        var emoji: String {
            switch self {
            case .creative: return "🎨"
            case .balanced: return "⚖️"
            case .precise:  return "🎯"
            }
        }
    }
    
    // MARK: - Greetings
    
    private let greetings = [
        "Hey! I'm your Gemini-powered spatial assistant. What can I build for you today?",
        "Welcome back to HoloDesk! I'm running on Gemini AI — ask me anything.",
        "Your spatial workspace is ready. What would you like to set up?",
    ]
    
    // MARK: - Activation
    
    func activate() {
        isActive = true
        let greeting = greetings.randomElement() ?? greetings[0]
        addAssistantMessage(greeting)
    }
    
    func deactivate() {
        isActive = false
    }
    
    // MARK: - Process User Input (Gemini + Local Hybrid)
    
    @MainActor
    func processInput(_ input: String, store: WorkspaceStore, windowManager: WindowManager) {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        addUserMessage(text)
        isThinking = true
        conversationCount += 1
        
        Task {
            // Step 1: Try local intent matching first (instant, no API call)
            if let localResponse = matchLocalIntent(text.lowercased(), store: store) {
                addAssistantMessage(localResponse.message)
                if let action = localResponse.action {
                    suggestedAction = action
                    executeAction(action, store: store, windowManager: windowManager)
                }
                isThinking = false
                return
            }
            
            // Step 2: Use Gemini API for free-form queries
            if useGeminiAPI {
                do {
                    let context = GeminiService.buildContext(from: store)
                    let response = try await GeminiService.shared.chat(
                        message: text,
                        workspaceContext: context
                    )
                    
                    // Parse action tags from Gemini response
                    let (cleanMessage, action) = parseActionTags(from: response)
                    addAssistantMessage(cleanMessage)
                    
                    if let action = action {
                        suggestedAction = action
                        executeAction(action, store: store, windowManager: windowManager)
                    }
                } catch {
                    // Fallback to local response on API failure
                    addAssistantMessage("I couldn't reach Gemini right now, but I can still help! Try asking me to switch modes or open apps. 🛡️")
                }
            } else {
                addAssistantMessage("I can help with workspace actions! Try: \"open work mode\", \"add notes\", or \"save workspace\".")
            }
            
            isThinking = false
        }
    }
    
    // MARK: - Local Intent Matching (Instant)
    
    private struct LocalResponse {
        let message: String
        let action: SuggestedAction?
    }
    
    private func matchLocalIntent(_ input: String, store: WorkspaceStore) -> LocalResponse? {
        // Mode switching
        if input.contains("work") && (input.contains("mode") || input.contains("setup") || input.contains("coding")) {
            return LocalResponse(message: "Setting up Work mode — productivity tools incoming. 🧑‍💻", action: .switchMode(.work))
        }
        if input.contains("study") || input.contains("learn") {
            return LocalResponse(message: "Study mode — notes front and center, distractions minimized. 📚", action: .switchMode(.study))
        }
        if input.contains("cinema") || input.contains("movie") || input.contains("watch") {
            return LocalResponse(message: "Cinema mode — dimming lights, big screen coming up. 🎬", action: .switchMode(.cinema))
        }
        if input.contains("game") || input.contains("gaming") {
            return LocalResponse(message: "Gaming mode activated! Ultra-wide, minimal UI. 🎮", action: .switchMode(.gaming))
        }
        
        // Save
        if input.contains("save") && (input.contains("workspace") || input.contains("layout") || input.count < 20) {
            return LocalResponse(message: "Workspace saved! 💾", action: .saveWorkspace)
        }
        
        // Clear
        if input.contains("clear") || input.contains("reset") {
            return LocalResponse(message: "Clearing all windows. Fresh canvas! ✨", action: .clearWindows)
        }
        
        // Add windows — match specific types
        if input.contains("add") || input.contains("open") {
            let windowMap: [(String, WindowType, String)] = [
                ("note",      .notes,       "Notes window ready. ✏️"),
                ("music",     .music,       "Music player added. 🎵"),
                ("calendar",  .calendar,    "Calendar's up. 📅"),
                ("message",   .messages,    "Messages opened. 💬"),
                ("file",      .files,       "Files browser ready. 📂"),
                ("weather",   .weather,     "Weather panel added. ⛅"),
                ("todo",      .todo,        "To-Do list ready. ✅"),
                ("spotify",   .spotify,     "Spotify loaded. 🎧"),
                ("code",      .codeEditor,  "Code editor ready. 💻"),
                ("terminal",  .terminal,    "Terminal spawned. >_"),
                ("browser",   .browser,     "Browser opened. 🌐"),
                ("chess",     .chess,       "Chess board placed. ♟️"),
                ("mail",      .mail,        "Mail inbox opened. 📧"),
                ("stock",     .stocks,      "Stocks dashboard ready. 📈"),
                ("video",     .video,       "Video player added. 🎥"),
                ("meditat",   .meditation,  "Meditation space created. 🧘"),
                ("whiteboard",.whiteboard,  "Whiteboard ready. 🎨"),
            ]
            for (keyword, type, msg) in windowMap {
                if input.contains(keyword) {
                    return LocalResponse(message: msg, action: .addWindow(type))
                }
            }
        }
        
        // Immersive
        if input.contains("immersive") || input.contains("3d space") {
            return LocalResponse(message: "Opening immersive space — your room becomes your workspace! 🌌", action: .openImmersive)
        }
        
        // Not a local intent — let Gemini handle it
        return nil
    }
    
    // MARK: - Parse Gemini Action Tags
    
    /// Extracts [ACTION:...] tags from Gemini's response
    private func parseActionTags(from response: String) -> (String, SuggestedAction?) {
        var cleanMessage = response
        var action: SuggestedAction? = nil
        
        // Match [ACTION:type:param] pattern
        let pattern = #"\[ACTION:([a-z_]+)(?::([a-zA-Z]+))?\]"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: response, range: NSRange(response.startIndex..., in: response)) {
            
            let actionType = String(response[Range(match.range(at: 1), in: response)!])
            let param = match.range(at: 2).location != NSNotFound
                ? String(response[Range(match.range(at: 2), in: response)!])
                : nil
            
            // Remove action tag from visible message
            cleanMessage = regex.stringByReplacingMatches(
                in: response,
                range: NSRange(response.startIndex..., in: response),
                withTemplate: ""
            ).trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Map to action
            switch actionType {
            case "switch_mode":
                if let mode = WorkspaceMode(rawValue: param ?? "") {
                    action = .switchMode(mode)
                }
            case "add_window":
                if let type = WindowType(rawValue: param ?? "") {
                    action = .addWindow(type)
                }
            case "save":
                action = .saveWorkspace
            case "rearrange":
                action = .rearrangeWindows
            case "immersive":
                action = .openImmersive
            case "clear":
                action = .clearWindows
            default:
                break
            }
        }
        
        return (cleanMessage, action)
    }
    
    // MARK: - Action Execution
    
    @MainActor
    private func executeAction(_ action: SuggestedAction, store: WorkspaceStore, windowManager: WindowManager) {
        HapticManager.shared.mediumTap()
        switch action {
        case .switchMode(let mode):
            Task { await windowManager.transitionToMode(mode, in: store) }
        case .addWindow(let type):
            windowManager.spawnWindow(type: type, in: store)
        case .saveWorkspace:
            store.saveCurrentWorkspace()
            HapticManager.shared.success()
        case .rearrangeWindows:
            windowManager.rearrangeInArc(in: store)
        case .clearWindows:
            store.clearAllWindows()
        case .openImmersive:
            break // Handled by ContentView
        }
    }
    
    // MARK: - Special Queries
    
    /// Ask Gemini for productivity advice
    @MainActor
    func askForAdvice(store: WorkspaceStore) {
        processInput(
            "Based on the current time of day and my workspace, what should I focus on?",
            store: store,
            windowManager: WindowManager()
        )
    }
    
    /// Ask Gemini to suggest a layout
    @MainActor
    func suggestLayout(store: WorkspaceStore) {
        processInput(
            "Suggest the ideal window arrangement for my current workflow.",
            store: store,
            windowManager: WindowManager()
        )
    }
    
    // MARK: - Helpers
    
    private func addUserMessage(_ text: String) {
        messageHistory.append(AssistantMessage(text: text, isUser: true, timestamp: Date()))
    }
    
    private func addAssistantMessage(_ text: String) {
        currentMessage = text
        messageHistory.append(AssistantMessage(text: text, isUser: false, timestamp: Date()))
    }
    
    /// Reset conversation
    func clearHistory() {
        messageHistory.removeAll()
        conversationCount = 0
        Task { await GeminiService.shared.resetConversation() }
    }
}
