// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import Foundation
import simd

// MARK: - Window Type

/// The type of content a spatial window displays.
enum WindowType: String, Codable, CaseIterable, Identifiable {
    case messages
    case calendar
    case notes
    case music
    case photos
    case files
    case weather
    case todo
    case video
    case browser
    case whiteboard
    case spotify
    case podcast
    case kanban
    case mindMap
    case codeEditor
    case terminal
    case meditation
    case visualizer
    case modelViewer
    case ambienceMixer
    case facetime
    case stocks
    case habits
    case translator
    case clipboard
    case chess
    case mail
    case voiceMemos
    case spreadsheet
    case systemMonitor
    case socialFeed
    case colorPicker
    
    var id: String { rawValue }
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .messages:    return "Messages"
        case .calendar:    return "Calendar"
        case .notes:       return "Notes"
        case .music:       return "Music"
        case .photos:      return "Photos"
        case .files:       return "Files"
        case .weather:     return "Weather"
        case .todo:        return "To-Do"
        case .video:       return "Video"
        case .browser:     return "Browser"
        case .whiteboard:  return "Whiteboard"
        case .spotify:     return "Spotify"
        case .podcast:     return "Podcasts"
        case .kanban:      return "Kanban"
        case .mindMap:     return "Mind Map"
        case .codeEditor:  return "Code"
        case .terminal:    return "Terminal"
        case .meditation:  return "Meditation"
        case .visualizer:  return "Visualizer"
        case .modelViewer: return "3D Viewer"
        case .ambienceMixer: return "Ambience"
        case .facetime:    return "FaceTime"
        case .stocks:      return "Stocks"
        case .habits:      return "Habits"
        case .translator:  return "Translate"
        case .clipboard:   return "Clipboard"
        case .chess:       return "Chess"
        case .mail:        return "Mail"
        case .voiceMemos:  return "Voice Memos"
        case .spreadsheet: return "Spreadsheet"
        case .systemMonitor: return "System"
        case .socialFeed:  return "Social"
        case .colorPicker: return "Colors"
        }
    }
    
    /// SF Symbol icon name
    var iconName: String {
        switch self {
        case .messages:    return "message.fill"
        case .calendar:    return "calendar"
        case .notes:       return "note.text"
        case .music:       return "music.note"
        case .photos:      return "photo.fill"
        case .files:       return "folder.fill"
        case .weather:     return "sun.max.fill"
        case .todo:        return "checklist"
        case .video:       return "play.rectangle.fill"
        case .browser:     return "safari"
        case .whiteboard:  return "pencil.tip.crop.circle"
        case .spotify:     return "music.note.list"
        case .podcast:     return "mic.circle.fill"
        case .kanban:      return "rectangle.split.3x1"
        case .mindMap:     return "point.3.connected.trianglepath.dotted"
        case .codeEditor:  return "chevron.left.forwardslash.chevron.right"
        case .terminal:    return "terminal"
        case .meditation:  return "leaf.fill"
        case .visualizer:  return "waveform.path.ecg"
        case .modelViewer: return "rotate.3d"
        case .ambienceMixer: return "waveform"
        case .facetime:    return "video.fill"
        case .stocks:      return "chart.line.uptrend.xyaxis"
        case .habits:      return "flame.fill"
        case .translator:  return "globe"
        case .clipboard:   return "clipboard.fill"
        case .chess:       return "crown.fill"
        case .mail:        return "envelope.fill"
        case .voiceMemos:  return "waveform.circle"
        case .spreadsheet: return "tablecells"
        case .systemMonitor: return "gauge.with.dots.needle.33percent"
        case .socialFeed:  return "bubble.left.and.text.bubble.right"
        case .colorPicker: return "paintpalette.fill"
        }
    }
    
    /// Default window size (width, height) in points
    var defaultSize: SIMD2<Float> {
        switch self {
        case .messages:    return SIMD2(350, 450)
        case .calendar:    return SIMD2(500, 400)
        case .notes:       return SIMD2(350, 420)
        case .music:       return SIMD2(320, 350)
        case .photos:      return SIMD2(400, 320)
        case .files:       return SIMD2(450, 250)
        case .weather:     return SIMD2(220, 200)
        case .todo:        return SIMD2(320, 300)
        case .video:       return SIMD2(600, 380)
        case .browser:     return SIMD2(550, 450)
        case .whiteboard:  return SIMD2(600, 450)
        case .spotify:     return SIMD2(380, 520)
        case .podcast:     return SIMD2(380, 480)
        case .kanban:      return SIMD2(800, 420)
        case .mindMap:     return SIMD2(500, 380)
        case .codeEditor:  return SIMD2(550, 450)
        case .terminal:    return SIMD2(500, 350)
        case .meditation:  return SIMD2(350, 400)
        case .visualizer:  return SIMD2(500, 350)
        case .modelViewer: return SIMD2(450, 400)
        case .ambienceMixer: return SIMD2(350, 420)
        case .facetime:    return SIMD2(400, 500)
        case .stocks:      return SIMD2(420, 480)
        case .habits:      return SIMD2(380, 450)
        case .translator:  return SIMD2(380, 480)
        case .clipboard:   return SIMD2(350, 420)
        case .chess:       return SIMD2(480, 380)
        case .mail:        return SIMD2(550, 420)
        case .voiceMemos:  return SIMD2(350, 450)
        case .spreadsheet: return SIMD2(600, 420)
        case .systemMonitor: return SIMD2(380, 480)
        case .socialFeed:  return SIMD2(400, 520)
        case .colorPicker: return SIMD2(320, 440)
        }
    }
}

// MARK: - Spatial Window Model

/// Represents a single window placed in spatial space.
struct SpatialWindow: Identifiable, Codable, Equatable {
    let id: UUID
    var type: WindowType
    var position: SIMD3<Float>      // 3D position in meters relative to user
    var rotation: SIMD4<Float>      // Quaternion as [x, y, z, w]
    var size: SIMD2<Float>          // Width × Height in points
    var isVisible: Bool
    var zIndex: Int
    
    init(
        id: UUID = UUID(),
        type: WindowType,
        position: SIMD3<Float> = SIMD3(0, 1.5, -1.5),
        rotation: SIMD4<Float> = SIMD4(0, 0, 0, 1),
        size: SIMD2<Float>? = nil,
        isVisible: Bool = true,
        zIndex: Int = 0
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.rotation = rotation
        self.size = size ?? type.defaultSize
        self.isVisible = isVisible
        self.zIndex = zIndex
    }
    
    /// Convenience: width in CGFloat
    var width: CGFloat { CGFloat(size.x) }
    
    /// Convenience: height in CGFloat
    var height: CGFloat { CGFloat(size.y) }
    
    static func == (lhs: SpatialWindow, rhs: SpatialWindow) -> Bool {
        lhs.id == rhs.id
    }
}
