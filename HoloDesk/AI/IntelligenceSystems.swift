// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - AI Workspace Intelligence

/// Context-aware layouts, time-of-day adaptation, predictive workspace prep.
@MainActor @Observable
final class AIWorkspaceIntelligence {
    
    var currentContext: WorkContext = .general
    var timeBasedMode: TimeMode = .morning
    var suggestedWindows: [WindowType] = []
    var dailyBriefing: DailyBriefing?
    var weeklyInsights: WeeklyInsights?
    var isAIEnabled = true
    
    enum WorkContext: String {
        case meeting = "Meeting"
        case coding = "Deep Work"
        case creative = "Creative"
        case study = "Study"
        case planning = "Planning"
        case general = "General"
    }
    
    enum TimeMode: String {
        case morning = "Morning"
        case focusHours = "Focus Hours"
        case afternoon = "Afternoon"
        case evening = "Wind Down"
        case night = "Night Owl"
        
        static func current() -> TimeMode {
            let hour = Calendar.current.component(.hour, from: Date())
            switch hour {
            case 5..<9:   return .morning
            case 9..<12:  return .focusHours
            case 12..<17: return .afternoon
            case 17..<21: return .evening
            default:      return .night
            }
        }
    }
    
    struct DailyBriefing {
        var greeting: String
        var weather: String
        var meetingCount: Int
        var topTasks: [String]
        var focusHoursAvailable: Int
        var motivationalQuote: String
    }
    
    struct WeeklyInsights {
        var totalFocusHours: Double
        var mostProductiveDay: String
        var topApps: [(String, Double)]
        var streakDays: Int
        var improvement: String
    }
    
    /// Generate time-based workspace suggestion
    func suggestLayout() -> [WindowType] {
        switch TimeMode.current() {
        case .morning:
            return [.weather, .calendar, .todo, .music, .messages]
        case .focusHours:
            return [.notes, .codeEditor, .terminal, .ambienceMixer]
        case .afternoon:
            return [.kanban, .calendar, .messages, .spreadsheet]
        case .evening:
            return [.spotify, .video, .socialFeed, .meditation]
        case .night:
            return [.ambienceMixer, .notes, .music]
        }
    }
    
    /// Generate daily briefing
    func generateBriefing() {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening"
        
        dailyBriefing = DailyBriefing(
            greeting: "\(greeting), Radhesh! 🌟",
            weather: "24°C, Partly Cloudy",
            meetingCount: 3,
            topTasks: ["Review PR #47", "Design review at 2pm", "Write API docs"],
            focusHoursAvailable: 4,
            motivationalQuote: "\"The best way to predict the future is to create it.\" — Alan Kay"
        )
    }
    
    /// Generate weekly insights
    func generateWeeklyInsights() {
        weeklyInsights = WeeklyInsights(
            totalFocusHours: 28.5,
            mostProductiveDay: "Wednesday",
            topApps: [("Notes", 4.2), ("Code", 3.8), ("Browser", 2.1)],
            streakDays: 5,
            improvement: "+12% focus time vs last week"
        )
    }
    
    /// Context-aware app grouping
    func groupApps(for context: WorkContext) -> [WindowType] {
        switch context {
        case .meeting:  return [.calendar, .notes, .messages, .facetime]
        case .coding:   return [.codeEditor, .terminal, .browser, .spotify]
        case .creative: return [.whiteboard, .colorPicker, .photos, .mindMap]
        case .study:    return [.notes, .browser, .todo, .ambienceMixer]
        case .planning: return [.kanban, .spreadsheet, .calendar, .mindMap]
        case .general:  return [.notes, .calendar, .todo, .music]
        }
    }
}

// MARK: - Collaboration Engine

/// Shared desk sessions, multi-user editing, privacy bubbles.
@MainActor @Observable
final class CollaborationEngine {
    
    var isSessionActive = false
    var participants: [Participant] = []
    var sharedWindows: [UUID] = []
    var isPresenting = false
    var meetingAgenda: [String] = []
    var sessionRecording = false
    
    struct Participant: Identifiable {
        let id = UUID()
        var name: String
        var avatar: String
        var color: Color
        var isOnline: Bool
        var pointerPosition: SIMD3<Float>?
        var isInPrivacyBubble: Bool
    }
    
    func startSession(name: String) {
        isSessionActive = true
        participants = [
            Participant(name: "You", avatar: "ME", color: .blue, isOnline: true, pointerPosition: nil, isInPrivacyBubble: false),
        ]
        HapticManager.shared.success()
    }
    
    func inviteParticipant(name: String, avatar: String) {
        let p = Participant(name: name, avatar: avatar, color: [Color.green, .orange, .purple, .pink].randomElement() ?? .green, isOnline: true, pointerPosition: nil, isInPrivacyBubble: false)
        participants.append(p)
    }
    
    func shareWindow(_ windowId: UUID) {
        sharedWindows.append(windowId)
    }
    
    func unshareWindow(_ windowId: UUID) {
        sharedWindows.removeAll { $0 == windowId }
    }
    
    func togglePresentation() {
        isPresenting.toggle()
    }
    
    func enablePrivacyBubble(for participantId: UUID) {
        if let i = participants.firstIndex(where: { $0.id == participantId }) {
            participants[i].isInPrivacyBubble = true
        }
    }
    
    func endSession() {
        isSessionActive = false
        participants.removeAll()
        sharedWindows.removeAll()
        isPresenting = false
    }
}

// MARK: - Automation Script Engine

/// User-defined automation scripts and custom gesture creation.
@MainActor @Observable
final class AutomationEngine {
    
    var scripts: [AutoScript] = AutoScript.defaults
    var customGestures: [CustomGesture] = CustomGesture.defaults
    
    struct AutoScript: Identifiable {
        let id = UUID()
        var name: String
        var trigger: String
        var actions: [String]
        var isEnabled: Bool
        var emoji: String
    }
    
    struct CustomGesture: Identifiable {
        let id = UUID()
        var name: String
        var gesture: String
        var action: String
        var isEnabled: Bool
    }
    
    func executeScript(_ script: AutoScript, store: WorkspaceStore) {
        for action in script.actions {
            // Parse and execute action strings
            if action.starts(with: "open:") {
                let typeStr = String(action.dropFirst(5))
                if let type = WindowType(rawValue: typeStr) {
                    store.addWindow(type: type)
                }
            } else if action == "save" {
                store.saveCurrentWorkspace()
            }
        }
        HapticManager.shared.success()
    }
}

extension AutomationEngine.AutoScript {
    static var defaults: [AutomationEngine.AutoScript] {
        [
            .init(name: "Morning Setup", trigger: "When I say 'Good morning'", actions: ["open:calendar", "open:weather", "open:todo", "open:music"], isEnabled: true, emoji: "☀️"),
            .init(name: "Code Mode", trigger: "When I open Terminal", actions: ["open:codeEditor", "open:browser"], isEnabled: true, emoji: "💻"),
            .init(name: "Auto Save", trigger: "Every 5 minutes", actions: ["save"], isEnabled: true, emoji: "💾"),
            .init(name: "Meeting Prep", trigger: "15 min before calendar event", actions: ["open:calendar", "open:notes", "open:facetime"], isEnabled: false, emoji: "📋"),
        ]
    }
}

extension AutomationEngine.CustomGesture {
    static var defaults: [AutomationEngine.CustomGesture] {
        [
            .init(name: "Double Pinch", gesture: "Pinch both hands", action: "Save workspace", isEnabled: true),
            .init(name: "Fist Close", gesture: "Close both fists", action: "Privacy mode", isEnabled: true),
            .init(name: "Palm Up", gesture: "Open palm facing up", action: "Open launcher", isEnabled: true),
            .init(name: "Circle Draw", gesture: "Draw circle in air", action: "Quick capture", isEnabled: false),
        ]
    }
}
