// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Accessibility

// MARK: - Accessibility Manager

/// Accessibility support — VoiceOver labels, reduced motion, dynamic type.
struct AccessibilityConfig {
    
    /// Add comprehensive VoiceOver labels to window views.
    static func accessibilityLabel(for windowType: WindowType) -> String {
        switch windowType {
        case .messages:    return "Messages window showing recent conversations"
        case .calendar:    return "Calendar window showing today's schedule"
        case .notes:       return "Notes window for writing and organizing ideas"
        case .music:       return "Music player window with playback controls"
        case .photos:      return "Photos gallery window"
        case .files:       return "File browser window showing folders and documents"
        case .weather:     return "Weather widget showing current conditions"
        case .todo:        return "To-do list window with checkable items"
        case .video:       return "Video player window"
        case .browser:     return "Web browser window"
        case .whiteboard:  return "Drawing whiteboard window"
        case .spotify:     return "Spotify music player with playlists and controls"
        case .podcast:     return "Podcast player with episodes and playback"
        case .kanban:      return "Kanban board with draggable task cards"
        case .mindMap:     return "Mind map with connected idea nodes"
        case .codeEditor:  return "Code editor with syntax highlighting"
        case .terminal:    return "Terminal command line interface"
        case .meditation:  return "Guided meditation with breathing exercises"
        case .visualizer:  return "Music visualizer with animated bars and waveforms"
        case .modelViewer: return "3D model viewer with rotation and zoom"
        case .ambienceMixer: return "Ambient soundscape mixer with multiple channels"
        case .facetime:    return "FaceTime video call with contacts and spatial audio"
        case .stocks:      return "Stock market dashboard with charts and watchlist"
        case .habits:      return "Daily habit tracker with streaks and check-ins"
        case .translator:  return "Language translator with 12 languages"
        case .clipboard:   return "Clipboard history manager with search and categories"
        case .chess:       return "Interactive chess game with timers and move history"
        case .mail:        return "Email inbox with folders and compose"
        case .voiceMemos:  return "Voice recorder with waveform and playback"
        case .spreadsheet: return "Spreadsheet with formula bar and cell editing"
        case .systemMonitor: return "System performance monitor with CPU and memory"
        case .socialFeed:  return "Social feed with posts and interactions"
        case .colorPicker: return "Professional color picker with gradients and palettes"
        }
    }
    
    static func accessibilityLabel(for mode: WorkspaceMode) -> String {
        switch mode {
        case .work:    return "Work mode: Multiple productivity windows in an arc layout"
        case .study:   return "Study mode: Focused layout centered on notes"
        case .cinema:  return "Cinema mode: Large video display with dimmed environment"
        case .gaming:  return "Gaming mode: Ultra-wide display with minimal interface"
        case .custom:  return "Custom workspace mode"
        }
    }
    
    static func accessibilityHint(for action: String) -> String {
        switch action {
        case "addWindow":       return "Double tap to add a new spatial window"
        case "switchMode":      return "Double tap to switch workspace mode"
        case "save":            return "Double tap to save current workspace layout"
        case "voice":           return "Double tap to toggle voice commands"
        case "immersive":       return "Double tap to enter immersive space"
        case "demo":            return "Double tap to start demo mode"
        default:                return "Double tap to activate"
        }
    }
}

// MARK: - Accessibility Modifiers

extension View {
    /// Apply accessibility label for a window type.
    func windowAccessibility(type: WindowType) -> some View {
        self
            .accessibilityLabel(AccessibilityConfig.accessibilityLabel(for: type))
            .accessibilityAddTraits(.isButton)
    }
    
    /// Apply accessibility for workspace mode buttons.
    func modeAccessibility(mode: WorkspaceMode, isSelected: Bool) -> some View {
        self
            .accessibilityLabel(AccessibilityConfig.accessibilityLabel(for: mode))
            .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : [.isButton])
    }
    
    /// Apply reduced motion preference.
    func respectReducedMotion() -> some View {
        self.transaction { transaction in
            if UIAccessibility.isReduceMotionEnabled {
                transaction.animation = nil
            }
        }
    }
}
