// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Apple Ecosystem Integration Manager

/// Mac Virtual Display, Universal Clipboard, AirDrop, Handoff, iCloud sync.
@Observable
final class AppleEcosystemManager {
    
    // MARK: - Mac Virtual Display
    var isMacDisplayConnected = false
    var macDisplayName = "MacBook Pro"
    var macDisplayResolution = "2560×1600"
    var macDisplayPosition: SIMD3<Float> = SIMD3(0, 1.4, -2.0)
    
    func connectMacDisplay() {
        isMacDisplayConnected = true
        HapticManager.shared.success()
    }
    
    func disconnectMacDisplay() {
        isMacDisplayConnected = false
    }
    
    // MARK: - Universal Clipboard Spatial Tray
    var clipboardTrayItems: [ClipboardTrayItem] = []
    var isTrayVisible = false
    
    struct ClipboardTrayItem: Identifiable {
        let id = UUID()
        var content: String
        var source: String  // "Mac", "iPhone", "iPad"
        var type: ItemType
        var timestamp: Date
        
        enum ItemType { case text, image, url, file }
        
        var icon: String {
            switch type {
            case .text: return "doc.text"
            case .image: return "photo"
            case .url: return "link"
            case .file: return "doc"
            }
        }
    }
    
    func pasteFromClipboardTray(_ item: ClipboardTrayItem) {
        HapticManager.shared.lightTap()
    }
    
    // MARK: - AirDrop Throw Gesture
    var airdropTargets: [AirDropTarget] = [
        AirDropTarget(name: "MacBook Pro", icon: "macbook", isAvailable: true),
        AirDropTarget(name: "iPhone 16 Pro", icon: "iphone", isAvailable: true),
        AirDropTarget(name: "iPad Pro", icon: "ipad", isAvailable: false),
    ]
    
    struct AirDropTarget: Identifiable {
        let id = UUID()
        var name: String
        var icon: String
        var isAvailable: Bool
    }
    
    func airdropThrow(windowId: UUID, to target: AirDropTarget) {
        HapticManager.shared.success()
    }
    
    // MARK: - iCloud Workspace Sync
    var iCloudSyncEnabled = false
    var lastSyncDate: Date?
    var syncStatus: SyncStatus = .idle
    
    enum SyncStatus: String {
        case idle = "Up to date"
        case syncing = "Syncing..."
        case error = "Sync error"
        case offline = "Offline"
    }
    
    func syncToiCloud() {
        syncStatus = .syncing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.syncStatus = .idle
            self?.lastSyncDate = Date()
        }
    }
    
    // MARK: - Safari Spatial Tab Shelf
    var safariTabs: [SafariTab] = [
        SafariTab(title: "Apple Developer", url: "developer.apple.com", favicon: "safari"),
        SafariTab(title: "Swift Documentation", url: "swift.org/documentation", favicon: "doc.text"),
        SafariTab(title: "GitHub", url: "github.com", favicon: "chevron.left.forwardslash.chevron.right"),
    ]
    
    struct SafariTab: Identifiable {
        let id = UUID()
        var title: String
        var url: String
        var favicon: String
    }
    
    // MARK: - Reminders Floating Cards
    var floatingReminders: [FloatingReminder] = [
        FloatingReminder(text: "Review PR #47", dueTime: "2:00 PM", priority: .high),
        FloatingReminder(text: "Buy groceries", dueTime: "6:00 PM", priority: .medium),
        FloatingReminder(text: "Call dentist", dueTime: "Tomorrow", priority: .low),
    ]
    
    struct FloatingReminder: Identifiable {
        let id = UUID()
        var text: String
        var dueTime: String
        var priority: Priority
        var isComplete = false
        
        enum Priority { case high, medium, low
            var color: Color {
                switch self { case .high: return .red; case .medium: return .orange; case .low: return .green }
            }
        }
    }
    
    func completeReminder(_ id: UUID) {
        if let i = floatingReminders.firstIndex(where: { $0.id == id }) {
            floatingReminders[i].isComplete = true
            HapticManager.shared.lightTap()
        }
    }
}

// MARK: - Spotlight Spatial Search

/// Spotlight-style search across all windows, files, and workspaces.
@Observable
final class SpotlightSpatialSearch {
    
    var isActive = false
    var query = ""
    var results: [SearchResult] = []
    
    struct SearchResult: Identifiable {
        let id = UUID()
        var title: String
        var subtitle: String
        var icon: String
        var color: Color
        var type: ResultType
        
        enum ResultType { case window, file, workspace, action, contact }
    }
    
    func search(_ query: String) {
        guard !query.isEmpty else { results = []; return }
        
        // Search windows
        var r: [SearchResult] = []
        for type in WindowType.allCases {
            if type.displayName.localizedCaseInsensitiveContains(query) {
                r.append(SearchResult(title: type.displayName, subtitle: "Open window", icon: type.iconName, color: Color.windowAccent(for: type), type: .window))
            }
        }
        
        // Search workspaces
        for mode in WorkspaceMode.allCases {
            if mode.displayName.localizedCaseInsensitiveContains(query) {
                r.append(SearchResult(title: mode.displayName, subtitle: "Workspace mode", icon: "rectangle.grid.2x2", color: Color.modeTint(for: mode), type: .workspace))
            }
        }
        
        // Common actions
        let actions = [("Save", "square.and.arrow.down", Color.blue), ("Screenshot", "camera", .orange), ("Focus", "moon", .indigo)]
        for (name, icon, color) in actions {
            if name.localizedCaseInsensitiveContains(query) {
                r.append(SearchResult(title: name, subtitle: "Action", icon: icon, color: color, type: .action))
            }
        }
        
        results = r
    }
}
