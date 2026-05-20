// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import Foundation

// MARK: - Workspace Mode

/// Available workspace presets.
enum WorkspaceMode: String, Codable, CaseIterable, Identifiable {
    case work
    case study
    case cinema
    case gaming
    case custom
    
    var id: String { rawValue }
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .work:    return "Work"
        case .study:   return "Study"
        case .cinema:  return "Cinema"
        case .gaming:  return "Gaming"
        case .custom:  return "Custom"
        }
    }
    
    /// SF Symbol icon
    var iconName: String {
        switch self {
        case .work:    return "desktopcomputer"
        case .study:   return "book.fill"
        case .cinema:  return "film"
        case .gaming:  return "gamecontroller.fill"
        case .custom:  return "slider.horizontal.3"
        }
    }
    
    /// Emoji for quick display
    var emoji: String {
        switch self {
        case .work:    return "🧑‍💻"
        case .study:   return "📚"
        case .cinema:  return "🎬"
        case .gaming:  return "🎮"
        case .custom:  return "⚙️"
        }
    }
}

// MARK: - Environment Settings

/// Controls the immersive environment appearance per workspace mode.
struct EnvironmentSettings: Codable {
    var ambientIntensity: Float       // 0.0 - 1.0
    var tintColor: [Float]            // RGB array [r, g, b]
    var immersionLevel: Float         // 0.0 = passthrough, 1.0 = full immersion
    var particleDensity: Float        // 0.0 - 1.0
    
    static let workDefault = EnvironmentSettings(
        ambientIntensity: 0.8,
        tintColor: [0.9, 0.95, 1.0],
        immersionLevel: 0.0,
        particleDensity: 0.2
    )
    
    static let studyDefault = EnvironmentSettings(
        ambientIntensity: 0.7,
        tintColor: [0.95, 1.0, 0.9],
        immersionLevel: 0.0,
        particleDensity: 0.15
    )
    
    static let cinemaDefault = EnvironmentSettings(
        ambientIntensity: 0.2,
        tintColor: [0.3, 0.2, 0.5],
        immersionLevel: 0.6,
        particleDensity: 0.5
    )
    
    static let gamingDefault = EnvironmentSettings(
        ambientIntensity: 0.4,
        tintColor: [0.2, 0.8, 0.6],
        immersionLevel: 0.3,
        particleDensity: 0.4
    )
}

// MARK: - Workspace Model

/// A complete workspace configuration: windows + environment.
struct Workspace: Identifiable, Codable {
    let id: UUID
    var name: String
    var mode: WorkspaceMode
    var windows: [SpatialWindow]
    var environmentSettings: EnvironmentSettings
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        mode: WorkspaceMode,
        windows: [SpatialWindow],
        environmentSettings: EnvironmentSettings? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.mode = mode
        self.windows = windows
        
        // Use mode-specific defaults if not provided
        if let settings = environmentSettings {
            self.environmentSettings = settings
        } else {
            switch mode {
            case .work:    self.environmentSettings = .workDefault
            case .study:   self.environmentSettings = .studyDefault
            case .cinema:  self.environmentSettings = .cinemaDefault
            case .gaming:  self.environmentSettings = .gamingDefault
            case .custom:  self.environmentSettings = .workDefault
            }
        }
        
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
