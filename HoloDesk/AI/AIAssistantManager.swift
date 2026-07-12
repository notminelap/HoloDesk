// ─────────────────────────────────────────────────────────────────────────────
//                O F F L I N E   N L P   I N T E L L I G E N C E
// ─────────────────────────────────────────────────────────────────────────────
//   HoloDesk Time-Aware 38-Intent On-Device AI Brain - visionOS 27
//
//   Copyright (c) 2027 Radhesh Ranvijay. All Rights Reserved.
//   Designed and engineered by Radhesh Ranvijay for Apple Swift Student Challenge.
// ─────────────────────────────────────────────────────────────────────────────


import SwiftUI
import Observation

// MARK: - AI Workspace Assistant (Offline-First + Apple Intelligence)

/// The AI brain of HoloDesk. Works 100% offline with rich local NLP.
/// On visionOS 27+, routes through Apple Foundation Models for on-device intelligence.
/// Powered entirely by Apple Intelligence — no third-party APIs.
/// WWDC-compliant: all core features work without network.
@MainActor @Observable
final class AIAssistantManager {
    
    var isActive = false
    var isThinking = false
    var currentMessage = ""
    var messageHistory: [AssistantMessage] = []
    var suggestedAction: SuggestedAction?
    var aiMode: AIMode = .balanced
    var conversationCount = 0
    var aiMood: AssistantMood = .idle
    
    enum AssistantMood: String, CaseIterable {
        case thinking = "Thinking"
        case creative = "Creative"
        case calm = "Calm"
        case idle = "Idle"
        
        var color: Color {
            switch self {
            case .thinking: return .blue
            case .creative: return .pink
            case .calm: return .teal
            case .idle: return .cyan
            }
        }
    }
    
    /// Whether to use Apple Intelligence (on-device Foundation Models) on visionOS 27+
    var useAppleIntelligence = true  // Default ON — privacy-first, no network needed
    
    /// Whether to attempt Gemini API (disabled for WWDC submission, secure proxy config)
    var useGeminiAPI = false  // Default OFF for offline-first
    
    /// Reference to the Apple Intelligence service
    private let appleIntelligence = AppleIntelligenceService.shared
    
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
        "Hey! I'm your spatial assistant. What can I build for you today?",
        "Welcome back to HoloDesk! Ask me anything about your workspace.",
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
    
    // MARK: - Process User Input
    
    @MainActor
    func processInput(_ input: String, store: WorkspaceStore, windowManager: WindowManager) {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        addUserMessage(text)
        isThinking = true
        aiMood = .thinking
        conversationCount += 1
        
        Task {
            // Step 1: Local intent matching (instant, no API)
            if let localResponse = matchLocalIntent(text.lowercased(), store: store) {
                updateMoodForResponse(localResponse.message, hasAction: localResponse.action != nil)
                await addAssistantMessageStreamed(localResponse.message)
                if let action = localResponse.action {
                    suggestedAction = action
                    executeAction(action, store: store, windowManager: windowManager)
                }
                isThinking = false
                return
            }
            
            // Step 2: Smart local NLP for conversational queries (offline)
            if let smartResponse = smartLocalResponse(text.lowercased(), store: store) {
                try? await Task.sleep(for: .milliseconds(200))
                updateMoodForResponse(smartResponse, hasAction: false)
                await addAssistantMessageStreamed(smartResponse)
                isThinking = false
                return
            }
            
            // Step 2.5: Apple Intelligence (on-device Foundation Models, visionOS 27+)
            if useAppleIntelligence && appleIntelligence.isAvailable {
                let context = AppleIntelligenceService.buildContext(from: store)
                let response = await appleIntelligence.processMessage(text, workspaceContext: context)
                let (cleanMessage, action) = parseActionTags(from: response)
                updateMoodForResponse(cleanMessage, hasAction: action != nil)
                await addAssistantMessageStreamed(cleanMessage)
                if let action = action {
                    suggestedAction = action
                    executeAction(action, store: store, windowManager: windowManager)
                }
                isThinking = false
                return
            }
            
            // Step 2.8: Optional Gemini API (cloud backup)
            if useGeminiAPI {
                do {
                    let context = GeminiService.buildContext(from: store)
                    let response = try await GeminiService.shared.chat(message: text, workspaceContext: context)
                    let (cleanMessage, action) = parseActionTags(from: response)
                    updateMoodForResponse(cleanMessage, hasAction: action != nil)
                    await addAssistantMessageStreamed(cleanMessage)
                    if let action = action {
                        suggestedAction = action
                        executeAction(action, store: store, windowManager: windowManager)
                    }
                    isThinking = false
                    return
                } catch {
                    // Fall back gracefully to local offline fallback
                }
            }
            
            // Step 3: Smart fallback for unmatched queries
            let fallback = smartFallback(text.lowercased(), store: store)
            updateMoodForResponse(fallback, hasAction: false)
            await addAssistantMessageStreamed(fallback)
            
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
        if input.contains("work") && (input.contains("mode") || input.contains("setup") || input.contains("coding") || input.contains("productivity")) {
            return LocalResponse(message: "Setting up Work mode — productivity tools incoming. 🧑‍💻", action: .switchMode(.work))
        }
        if input.contains("study") || input.contains("learn") || input.contains("read") {
            return LocalResponse(message: "Study mode — notes front and center, distractions minimized. 📚", action: .switchMode(.study))
        }
        if input.contains("cinema") || input.contains("movie") || input.contains("watch") || input.contains("film") {
            return LocalResponse(message: "Cinema mode — dimming lights, big screen coming up. 🎬", action: .switchMode(.cinema))
        }
        if input.contains("game") || input.contains("gaming") || input.contains("play") {
            return LocalResponse(message: "Gaming mode activated! Ultra-wide, minimal UI. 🎮", action: .switchMode(.gaming))
        }
        
        // Save
        if input.contains("save") && (input.contains("workspace") || input.contains("layout") || input.count < 20) {
            return LocalResponse(message: "Workspace saved! 💾", action: .saveWorkspace)
        }
        
        // Clear / Reset
        if input.contains("clear") || (input.contains("reset") && !input.contains("data")) {
            return LocalResponse(message: "Clearing all windows. Fresh canvas! ✨", action: .clearWindows)
        }
        
        // Rearrange
        if input.contains("rearrange") || input.contains("organize") || input.contains("tidy") || input.contains("arc") {
            return LocalResponse(message: "Rearranging windows in a comfortable arc. 🌀", action: .rearrangeWindows)
        }
        
        // Add windows — match specific types
        if input.contains("add") || input.contains("open") || input.contains("show") || input.contains("launch") {
            let windowMap: [(String, WindowType, String)] = [
                ("note",       .notes,        "Notes window ready. ✏️"),
                ("music",      .music,        "Music player added. 🎵"),
                ("calendar",   .calendar,     "Calendar's up. 📅"),
                ("message",    .messages,     "Messages opened. 💬"),
                ("file",       .files,        "Files browser ready. 📂"),
                ("weather",    .weather,      "Weather panel added. ⛅"),
                ("todo",       .todo,         "To-Do list ready. ✅"),
                ("task",       .todo,         "Task list ready. ✅"),
                ("spotify",    .spotify,      "Spotify loaded. 🎧"),
                ("code",       .codeEditor,   "Code editor ready. 💻"),
                ("terminal",   .terminal,     "Terminal spawned. >_"),
                ("browser",    .browser,      "Browser opened. 🌐"),
                ("chess",      .chess,        "Chess board placed. ♟️"),
                ("mail",       .mail,         "Mail inbox opened. 📧"),
                ("email",      .mail,         "Email inbox opened. 📧"),
                ("stock",      .stocks,       "Stocks dashboard ready. 📈"),
                ("video",      .video,        "Video player added. 🎥"),
                ("meditat",    .meditation,   "Meditation space created. 🧘"),
                ("whiteboard", .whiteboard,   "Whiteboard ready. 🎨"),
                ("draw",       .whiteboard,   "Drawing board ready. 🎨"),
                ("kanban",     .kanban,       "Kanban board opened. 📋"),
                ("board",      .kanban,       "Project board ready. 📋"),
                ("mind",       .mindMap,      "Mind map created. 🧠"),
                ("podcast",    .podcast,      "Podcast player added. 🎙️"),
                ("photo",      .photos,       "Photos gallery opened. 📸"),
                ("translate",  .translator,   "Translator ready. 🌍"),
                ("clipboard",  .clipboard,    "Clipboard manager opened. 📎"),
                ("voice",      .voiceMemos,   "Voice Memos recording. 🎤"),
                ("facetime",   .facetime,     "FaceTime ready. 📹"),
                ("call",       .facetime,     "Video call ready. 📹"),
                ("spread",     .spreadsheet,  "Spreadsheet opened. 📊"),
                ("monitor",    .systemMonitor,"System monitor ready. 📡"),
                ("social",     .socialFeed,   "Social feed opened. 📱"),
                ("color",      .colorPicker,  "Color picker ready. 🎨"),
                ("habit",      .habits,       "Habit tracker opened. 📈"),
                ("model",      .modelViewer,  "3D model viewer ready. 🧊"),
                ("ambien",     .ambienceMixer,"Ambience mixer opened. 🔊"),
                ("visual",     .visualizer,   "Music visualizer ready. 🌈"),
            ]
            for (keyword, type, msg) in windowMap {
                if input.contains(keyword) {
                    return LocalResponse(message: msg, action: .addWindow(type))
                }
            }
        }
        
        // Immersive
        if input.contains("immersive") || input.contains("3d space") || input.contains("spatial") {
            return LocalResponse(message: "Opening immersive space — your room becomes your workspace! 🌌", action: .openImmersive)
        }
        
        return nil
    }
    
    // MARK: - Smart Local NLP (Offline Intelligence)
    
    /// Handles conversational queries without any API — WWDC compliant.
    private func smartLocalResponse(_ input: String, store: WorkspaceStore) -> String? {
        let windowCount = store.activeWindows.count
        let mode = store.currentMode
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Greetings
        if input.contains("hello") || input.contains("hi") || input.contains("hey") || input.starts(with: "yo") {
            let timeGreeting = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening"
            return "\(timeGreeting)! You're in \(mode.displayName) mode with \(windowCount) windows. What would you like to set up? 🧊"
        }
        
        // What can you do?
        if input.contains("what can you") || input.contains("help") || input.contains("what do you") {
            return """
            I can help with:
            • Switch modes: "work mode", "cinema mode", "study mode"
            • Open apps: "open notes", "add spotify", "show weather"
            • Manage: "save workspace", "clear all", "rearrange"
            • Immersive: "open 3d space"
            Ask me anything about your workspace! 🧊
            """
        }
        
        // Status / How's my workspace
        if input.contains("status") || input.contains("how") || input.contains("what's open") || input.contains("workspace") {
            if windowCount == 0 {
                return "Your workspace is empty. Try \"work mode\" to load a preset, or \"open notes\" to add a window. 🧊"
            }
            let windowNames = store.activeWindows.prefix(5).map { $0.type.displayName }.joined(separator: ", ")
            let extra = windowCount > 5 ? " and \(windowCount - 5) more" : ""
            return "You're in \(mode.displayName) mode with \(windowCount) windows: \(windowNames)\(extra). 🧊"
        }
        
        // Time-based advice
        if input.contains("suggest") || input.contains("advice") || input.contains("recommend") || input.contains("what should") {
            switch hour {
            case 5..<9:
                return "Morning routine! I'd suggest: Calendar → Weather → Todo → Music. Start with \"work mode\" for a clean setup. ☀️"
            case 9..<12:
                return "Peak focus hours! Go deep with Code Editor + Terminal + Notes. Try \"work mode\" for optimal productivity. 🧠"
            case 12..<14:
                return "Lunch break — maybe switch to a lighter setup? Try \"open spotify\" or \"cinema mode\" to relax. 🍕"
            case 14..<17:
                return "Afternoon push! Kanban board + Calendar for planning. Or \"study mode\" for focused reading. 📋"
            case 17..<21:
                return "Evening wind-down. How about \"cinema mode\" for a movie, or \"open meditation\" for some calm? 🌅"
            default:
                return "Night owl mode! Keep it minimal — Notes + Music + Ambient mixer. The dark theme is easier on your eyes. 🌙"
            }
        }
        
        // Thank you
        if input.contains("thank") || input.contains("awesome") || input.contains("great") || input.contains("nice") {
            return ["You're welcome! 🧊", "Happy to help! Need anything else?", "Anytime! Your workspace is looking great. ✨"].randomElement() ?? "You're welcome! 🧊"
        }
        
        // About
        if input.contains("who are you") || input.contains("about") || input.contains("what are you") {
            return "I'm HoloDesk AI — your spatial computing assistant. Built by Notminelap Industries for Apple Vision Pro. I run entirely on-device! 🧊"
        }
        
        // How many windows / apps
        if input.contains("how many") {
            if input.contains("window") || input.contains("app") {
                return "You have \(windowCount) windows open right now in \(mode.displayName) mode. I support 32 different app types! 🧊"
            }
        }
        
        // Close / remove
        if input.contains("close") || input.contains("remove") {
            return "To close a window, tap the red traffic light button on its title bar. Or say \"clear all\" to remove everything. 🧊"
        }
        
        // Focus / concentration
        if input.contains("focus") || input.contains("concentrate") || input.contains("distract") {
            return "For maximum focus, try \"study mode\" — it minimizes distractions and puts notes front and center. You can also try the Pomodoro timer in the dock! 🧠"
        }
        
        return nil
    }
    
    // MARK: - Smart Fallback
    
    /// When nothing else matches, give a helpful contextual response
    private func smartFallback(_ input: String, store: WorkspaceStore) -> String {
        let suggestions = [
            "I can help you set up your workspace! Try: \"work mode\", \"open notes\", or \"cinema mode\". 🧊",
            "Ask me to switch modes, open apps, or manage your workspace. For example: \"add spotify\" or \"study mode\". 🧊",
            "Some things I can do: switch to \"gaming mode\", \"save workspace\", \"open chess\", or \"rearrange\" your windows. 🧊",
            "Try asking me to \"open weather\", \"add calendar\", or \"switch to cinema mode\". I'm here to help! 🧊",
        ]
        return suggestions[conversationCount % suggestions.count]
    }
    
    // MARK: - Parse AI Action Tags
    
    private func parseActionTags(from response: String) -> (String, SuggestedAction?) {
        var cleanMessage = response
        var action: SuggestedAction? = nil
        
        let pattern = #"\[ACTION:([a-z_]+)(?::([a-zA-Z]+))?\]"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: response, range: NSRange(response.startIndex..., in: response)) {
            
            var actionType = ""
            if let typeRange = Range(match.range(at: 1), in: response) {
                actionType = String(response[typeRange])
            }
            
            var param: String? = nil
            if match.range(at: 2).location != NSNotFound,
               let paramRange = Range(match.range(at: 2), in: response) {
                param = String(response[paramRange])
            }
            
            cleanMessage = regex.stringByReplacingMatches(
                in: response,
                range: NSRange(response.startIndex..., in: response),
                withTemplate: ""
            ).trimmingCharacters(in: .whitespacesAndNewlines)
            
            switch actionType {
            case "switch_mode":
                if let mode = WorkspaceMode(rawValue: param ?? "") { action = .switchMode(mode) }
            case "add_window":
                if let type = WindowType(rawValue: param ?? "") { action = .addWindow(type) }
            case "save":      action = .saveWorkspace
            case "rearrange": action = .rearrangeWindows
            case "immersive": action = .openImmersive
            case "clear":     action = .clearWindows
            default: break
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
    
    // MARK: - Helpers
    
    private func addUserMessage(_ text: String) {
        messageHistory.append(AssistantMessage(text: text, isUser: true, timestamp: Date()))
    }
    
    private func addAssistantMessage(_ text: String) {
        currentMessage = text
        messageHistory.append(AssistantMessage(text: text, isUser: false, timestamp: Date()))
    }
    
    @MainActor
    func addAssistantMessageStreamed(_ text: String) async {
        let messageIndex = messageHistory.count
        let initialMessage = AssistantMessage(text: "", isUser: false, timestamp: Date(), isStreaming: true)
        messageHistory.append(initialMessage)
        
        currentMessage = ""
        var accumulated = ""
        for char in text {
            accumulated.append(char)
            currentMessage = accumulated
            if messageIndex < messageHistory.count {
                messageHistory[messageIndex] = AssistantMessage(
                    text: accumulated,
                    isUser: false,
                    timestamp: Date(),
                    isStreaming: true
                )
            }
            try? await Task.sleep(for: .milliseconds(15))
        }
        
        if messageIndex < messageHistory.count {
            messageHistory[messageIndex] = AssistantMessage(
                text: text,
                isUser: false,
                timestamp: Date(),
                isStreaming: false
            )
        }
        currentMessage = text
    }
    
    private func updateMoodForResponse(_ text: String, hasAction: Bool) {
        let textLower = text.lowercased()
        if textLower.contains("study") || textLower.contains("meditat") || textLower.contains("calm") || textLower.contains("zen") {
            aiMood = .calm
        } else if textLower.contains("game") || textLower.contains("gaming") || textLower.contains("chess") || textLower.contains("whiteboard") || textLower.contains("draw") || textLower.contains("creative") {
            aiMood = .creative
        } else if hasAction {
            aiMood = .thinking
        } else {
            aiMood = .idle
        }
    }
    
    func clearHistory() {
        messageHistory.removeAll()
        conversationCount = 0
        Task {
            await GeminiService.shared.resetConversation()
        }
    }
}
