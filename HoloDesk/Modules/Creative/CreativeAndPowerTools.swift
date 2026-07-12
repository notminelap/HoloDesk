// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Creative Toolkit Manager

/// Infinite canvas, mood board, reference pinning, layer stack, asset import.
@MainActor @Observable
final class CreativeToolkit {
    
    // MARK: - Infinite Sketch Canvas
    var canvasStrokes: [CanvasStroke] = []
    var currentColor: Color = .white
    var brushSize: CGFloat = 3
    var canvasOffset: CGSize = .zero
    var canvasScale: CGFloat = 1.0
    
    struct CanvasStroke: Identifiable {
        let id = UUID()
        var points: [CGPoint]
        var color: Color
        var width: CGFloat
    }
    
    func addStroke(_ stroke: CanvasStroke) {
        canvasStrokes.append(stroke)
    }
    
    func clearCanvas() {
        canvasStrokes.removeAll()
    }
    
    func undo() {
        guard !canvasStrokes.isEmpty else { return }
        canvasStrokes.removeLast()
    }
    
    // MARK: - Mood Board
    var moodBoardItems: [MoodBoardItem] = MoodBoardItem.defaults
    
    struct MoodBoardItem: Identifiable {
        let id = UUID()
        var content: String    // Text or description
        var color: Color
        var position: CGPoint
        var size: CGSize
        var type: ItemType
        var rotation: Double
        
        enum ItemType { case colorSwatch, textNote, imageRef, inspiration }
    }
    
    func addMoodBoardItem(_ item: MoodBoardItem) {
        moodBoardItems.append(item)
    }
    
    // MARK: - Reference Image Pinning
    var pinnedReferences: [PinnedReference] = []
    
    struct PinnedReference: Identifiable {
        let id = UUID()
        var name: String
        var position: SIMD3<Float>
        var opacity: Float
        var isPinned: Bool
    }
    
    func pinReference(name: String, at position: SIMD3<Float>) {
        pinnedReferences.append(PinnedReference(name: name, position: position, opacity: 0.8, isPinned: true))
    }
    
    // MARK: - Layer Stack
    var layers: [DesignLayer] = [
        DesignLayer(name: "Background", isVisible: true, opacity: 1.0, isLocked: true),
        DesignLayer(name: "Layout", isVisible: true, opacity: 1.0, isLocked: false),
        DesignLayer(name: "Typography", isVisible: true, opacity: 1.0, isLocked: false),
        DesignLayer(name: "Icons", isVisible: true, opacity: 0.9, isLocked: false),
        DesignLayer(name: "Effects", isVisible: false, opacity: 0.5, isLocked: false),
    ]
    
    struct DesignLayer: Identifiable {
        let id = UUID()
        var name: String
        var isVisible: Bool
        var opacity: Double
        var isLocked: Bool
    }
    
    func toggleLayerVisibility(_ id: UUID) {
        if let i = layers.firstIndex(where: { $0.id == id }) {
            layers[i].isVisible.toggle()
        }
    }
    
    // MARK: - Quick Asset Import Shelf
    var recentAssets: [AssetItem] = [
        AssetItem(name: "logo.svg", type: .vector, size: "24 KB"),
        AssetItem(name: "hero-bg.png", type: .image, size: "1.2 MB"),
        AssetItem(name: "icon-set.sketch", type: .design, size: "4.8 MB"),
        AssetItem(name: "mockup.usdz", type: .model3d, size: "12.3 MB"),
    ]
    
    struct AssetItem: Identifiable {
        let id = UUID()
        var name: String
        var type: AssetType
        var size: String
        
        enum AssetType: String {
            case image = "photo"
            case vector = "square.on.circle"
            case design = "paintpalette"
            case model3d = "cube"
            case video = "film"
        }
    }
    
    // MARK: - Video Editing Timeline
    var timelineClips: [TimelineClip] = [
        TimelineClip(name: "Intro", duration: 5.0, color: .blue, startTime: 0),
        TimelineClip(name: "Main", duration: 30.0, color: .green, startTime: 5),
        TimelineClip(name: "B-Roll", duration: 10.0, color: .orange, startTime: 35),
        TimelineClip(name: "Outro", duration: 5.0, color: .purple, startTime: 45),
    ]
    
    struct TimelineClip: Identifiable {
        let id = UUID()
        var name: String
        var duration: Double
        var color: Color
        var startTime: Double
    }
    
    // MARK: - Music Production Desk
    var tracks: [MusicTrack] = [
        MusicTrack(name: "Drums", instrument: "🥁", volume: 0.8, isMuted: false, isSolo: false),
        MusicTrack(name: "Bass", instrument: "🎸", volume: 0.7, isMuted: false, isSolo: false),
        MusicTrack(name: "Keys", instrument: "🎹", volume: 0.6, isMuted: false, isSolo: false),
        MusicTrack(name: "Vocals", instrument: "🎤", volume: 0.9, isMuted: false, isSolo: true),
        MusicTrack(name: "FX", instrument: "🎛️", volume: 0.4, isMuted: true, isSolo: false),
    ]
    
    struct MusicTrack: Identifiable {
        let id = UUID()
        var name: String
        var instrument: String
        var volume: Double
        var isMuted: Bool
        var isSolo: Bool
    }
}

extension CreativeToolkit.MoodBoardItem {
    static var defaults: [CreativeToolkit.MoodBoardItem] {
        [
            .init(content: "Glassmorphism", color: .cyan.opacity(0.3), position: CGPoint(x: 80, y: 60), size: CGSize(width: 100, height: 40), type: .textNote, rotation: -3),
            .init(content: "#1A1A2E", color: Color(hex: 0x1A1A2E), position: CGPoint(x: 200, y: 50), size: CGSize(width: 50, height: 50), type: .colorSwatch, rotation: 0),
            .init(content: "#E94560", color: Color(hex: 0xE94560), position: CGPoint(x: 260, y: 50), size: CGSize(width: 50, height: 50), type: .colorSwatch, rotation: 0),
            .init(content: "Subtle depth + motion", color: .purple.opacity(0.2), position: CGPoint(x: 150, y: 130), size: CGSize(width: 120, height: 35), type: .inspiration, rotation: 2),
        ]
    }
}

extension Color {
    init(hex: UInt) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
}

// MARK: - Power User Tools

/// Multiple desk layouts, custom gestures, plugin architecture, keyboard shortcuts.
@MainActor @Observable
final class PowerUserTools {
    
    // MARK: - Multiple Desk Layouts
    var deskLayouts: [DeskLayout] = DeskLayout.defaults
    var activeDeskLayout: UUID?
    
    struct DeskLayout: Identifiable {
        let id = UUID()
        var name: String
        var emoji: String
        var description: String
        var windowArrangement: String
    }
    
    // MARK: - Keyboard Shortcut HUD
    var isShortcutHUDVisible = false
    var shortcuts: [KeyboardShortcut] = KeyboardShortcut.defaults
    
    struct KeyboardShortcut: Identifiable {
        let id = UUID()
        var keys: String
        var action: String
        var category: String
    }
    
    // MARK: - Plugin Marketplace
    var installedPlugins: [Plugin] = []
    var availablePlugins: [Plugin] = Plugin.marketplace
    
    struct Plugin: Identifiable {
        let id = UUID()
        var name: String
        var author: String
        var description: String
        var emoji: String
        var isInstalled: Bool
        var version: String
    }
    
    // MARK: - Debug Overlay
    var isDebugMode = false
    var debugInfo: [String: String] {
        [
            "FPS": "90",
            "Windows": "12",
            "Memory": "245 MB",
            "Thermal": "Nominal",
            "Anchors": "8",
            "Tracking": "Active",
        ]
    }
    
    // MARK: - Developer API
    var isAPIEnabled = false
    var apiVersion = "1.0.0"
    var apiEndpoints: [String] = [
        "GET /api/workspaces",
        "POST /api/windows",
        "PUT /api/layout",
        "DELETE /api/windows/:id",
        "GET /api/themes",
        "POST /api/automation",
    ]
    
    // MARK: - Workspace Export/Import
    func exportWorkspace(store: WorkspaceStore) -> Data? {
        try? JSONEncoder().encode(store.activeWindows)
    }
    
    func importWorkspace(data: Data, store: WorkspaceStore) {
        if let windows = try? JSONDecoder().decode([SpatialWindow].self, from: data) {
            store.activeWindows = windows
        }
    }
}

extension PowerUserTools.DeskLayout {
    static var defaults: [PowerUserTools.DeskLayout] {
        [
            .init(name: "Single Desk", emoji: "🖥️", description: "Standard single desk layout", windowArrangement: "arc"),
            .init(name: "L-Shape", emoji: "📐", description: "L-shaped dual desk", windowArrangement: "l-shape"),
            .init(name: "Dual Monitor", emoji: "🖥️🖥️", description: "Two desks side by side", windowArrangement: "dual"),
            .init(name: "U-Shape", emoji: "🏗️", description: "Surround workspace", windowArrangement: "surround"),
            .init(name: "Standing Shelf", emoji: "📚", description: "Vertical stack layout", windowArrangement: "vertical"),
        ]
    }
}

extension PowerUserTools.KeyboardShortcut {
    static var defaults: [PowerUserTools.KeyboardShortcut] {
        [
            .init(keys: "⌘ K", action: "Quick Actions", category: "General"),
            .init(keys: "⌘ S", action: "Save Workspace", category: "General"),
            .init(keys: "⌘ N", action: "New Window", category: "Windows"),
            .init(keys: "⌘ W", action: "Close Window", category: "Windows"),
            .init(keys: "⌘ 1-5", action: "Switch Mode", category: "Workspace"),
            .init(keys: "⌘ ⇧ F", action: "Toggle Focus", category: "Workspace"),
            .init(keys: "⌘ ⇧ P", action: "Privacy Mode", category: "Privacy"),
            .init(keys: "⌘ Space", action: "Spotlight Search", category: "General"),
            .init(keys: "⌘ ⇧ S", action: "Screenshot", category: "Capture"),
            .init(keys: "⌘ ⇧ R", action: "Record", category: "Capture"),
        ]
    }
}

extension PowerUserTools.Plugin {
    static var marketplace: [PowerUserTools.Plugin] {
        [
            .init(name: "Notion Sync", author: "HoloDesk Labs", description: "Sync your Notion pages as spatial cards", emoji: "📋", isInstalled: false, version: "1.0.0"),
            .init(name: "Figma Preview", author: "Design Tools", description: "Live Figma frame previews in spatial space", emoji: "🎨", isInstalled: false, version: "0.9.0"),
            .init(name: "GitHub Gist", author: "Dev Tools", description: "Quick gist creation from code editor", emoji: "🐙", isInstalled: false, version: "1.2.0"),
            .init(name: "Pomodoro Pro", author: "Productivity+", description: "Advanced Pomodoro with analytics", emoji: "🍅", isInstalled: true, version: "2.0.0"),
            .init(name: "Spatial Widgets", author: "Widget Co", description: "Custom widget creation toolkit", emoji: "🧩", isInstalled: false, version: "1.1.0"),
        ]
    }
}
