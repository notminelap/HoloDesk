// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - HoloDesk Color Theme

extension Color {
    
    // MARK: - Primary Palette
    
    /// Vibrant blue — primary accent color
    static let holoPrimary = Color(hue: 0.58, saturation: 0.85, brightness: 0.95)
    
    /// Soft cyan — secondary accent
    static let holoSecondary = Color(hue: 0.52, saturation: 0.6, brightness: 0.9)
    
    /// Warm purple — tertiary accent
    static let holoTertiary = Color(hue: 0.75, saturation: 0.55, brightness: 0.85)
    
    // MARK: - Semantic Colors
    
    /// Message bubble — sent (blue)
    static let messageSent = Color(hue: 0.58, saturation: 0.75, brightness: 0.95)
    
    /// Message bubble — received (gray)
    static let messageReceived = Color(white: 0.35)
    
    /// Calendar highlight
    static let calendarHighlight = Color(hue: 0.58, saturation: 0.8, brightness: 0.95)
    
    /// Success / Completed
    static let holoSuccess = Color(hue: 0.35, saturation: 0.7, brightness: 0.8)
    
    /// Warning / Attention
    static let holoWarning = Color(hue: 0.1, saturation: 0.8, brightness: 0.95)
    
    // MARK: - Window Type Colors
    
    /// Color associated with each window type for icons/accents
    static func windowAccent(for type: WindowType) -> Color {
        switch type {
        case .messages:    return .green
        case .calendar:    return .red
        case .notes:       return .yellow
        case .music:       return .pink
        case .photos:      return .holoPrimary
        case .files:       return .holoPrimary
        case .weather:     return .cyan
        case .todo:        return .orange
        case .video:       return .purple
        case .browser:     return Color(hue: 0.58, saturation: 0.8, brightness: 0.95)
        case .whiteboard:  return .teal
        case .spotify:     return Color(hue: 0.38, saturation: 0.85, brightness: 0.75) // Spotify green
        case .podcast:     return Color(hue: 0.78, saturation: 0.6, brightness: 0.85)  // Purple
        case .kanban:      return Color(hue: 0.58, saturation: 0.5, brightness: 0.85)  // Sky blue
        case .mindMap:     return Color(hue: 0.85, saturation: 0.5, brightness: 0.85)  // Magenta
        case .codeEditor:  return .cyan
        case .terminal:    return .green
        case .meditation:  return Color(hue: 0.35, saturation: 0.45, brightness: 0.7)  // Sage
        case .visualizer:  return Color(hue: 0.8, saturation: 0.7, brightness: 0.9)    // Neon purple
        case .modelViewer: return Color(hue: 0.05, saturation: 0.6, brightness: 0.9)   // Warm orange
        case .ambienceMixer: return Color(hue: 0.3, saturation: 0.4, brightness: 0.7)  // Forest green
        case .facetime:    return .green
        case .stocks:      return Color(hue: 0.4, saturation: 0.7, brightness: 0.85)   // Market green
        case .habits:      return .orange
        case .translator:  return Color(hue: 0.6, saturation: 0.6, brightness: 0.9)    // Blue
        case .clipboard:   return .indigo
        case .chess:       return Color(hue: 0.1, saturation: 0.5, brightness: 0.85)    // Gold
        case .mail:        return .blue
        case .voiceMemos:  return .red
        case .spreadsheet: return Color(hue: 0.4, saturation: 0.6, brightness: 0.7)    // Excel green
        case .systemMonitor: return .cyan
        case .socialFeed:  return Color(hue: 0.55, saturation: 0.7, brightness: 0.95)   // Twitter blue
        case .colorPicker: return Color(hue: 0.9, saturation: 0.6, brightness: 0.9)     // Fuchsia
        }
    }
    
    // MARK: - Mode Colors
    
    /// Background tint for each workspace mode
    static func modeTint(for mode: WorkspaceMode) -> Color {
        switch mode {
        case .work:    return .holoPrimary
        case .study:   return .holoSuccess
        case .cinema:  return .holoTertiary
        case .gaming:  return .holoWarning
        case .custom:  return .holoSecondary
        }
    }
    
    // MARK: - Glass Colors
    
    /// Subtle white for glass borders
    static let glassBorder = Color.white.opacity(0.2)
    
    /// Dark tint for glass backgrounds in dark mode
    static let glassDark = Color(white: 0.1, opacity: 0.6)
}

// MARK: - Gradient Helpers

extension LinearGradient {
    /// A subtle glass gradient for window backgrounds
    static let glassGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.15),
            Color.white.opacity(0.05)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Accent gradient for buttons and highlights
    static let accentGradient = LinearGradient(
        colors: [
            Color.holoPrimary,
            Color.holoSecondary
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Mode transition gradient
    static func modeGradient(for mode: WorkspaceMode) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.modeTint(for: mode).opacity(0.6),
                Color.modeTint(for: mode).opacity(0.2)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Custom ShapeStyle Extensions

extension ShapeStyle where Self == Color {
    static var holoPrimary: Color { Color.holoPrimary }
    static var holoSecondary: Color { Color.holoSecondary }
    static var holoTertiary: Color { Color.holoTertiary }
    static var holoSuccess: Color { Color.holoSuccess }
    static var holoWarning: Color { Color.holoWarning }
}

