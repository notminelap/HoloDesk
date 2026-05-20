// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Handwriting Recognition Engine

/// Converts hand-drawn strokes to text using on-device ML.
@Observable
final class HandwritingEngine {
    
    var recognizedText = ""
    var isProcessing = false
    var confidence: Double = 0
    
    func recognize(strokes: [CreativeToolkit.CanvasStroke]) {
        isProcessing = true
        // Simulated on-device recognition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.recognizedText = "Hello World – recognized handwriting"
            self?.confidence = 0.92
            self?.isProcessing = false
        }
    }
}

// MARK: - Document Scanner

/// Scan paper → digital document using camera.
@Observable
final class DocumentScanner {
    
    var scannedDocuments: [ScannedDocument] = []
    var isScanning = false
    
    struct ScannedDocument: Identifiable {
        let id = UUID()
        var name: String
        var pageCount: Int
        var date: Date
        var textContent: String  // OCR result
        var size: String
    }
    
    func startScan() {
        isScanning = true
        // Simulated scan result
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            let doc = ScannedDocument(
                name: "Scanned Doc \(Date().formatted(date: .abbreviated, time: .shortened))",
                pageCount: 1,
                date: Date(),
                textContent: "This is the OCR-recognized text from the scanned document...",
                size: "1.2 MB"
            )
            self?.scannedDocuments.insert(doc, at: 0)
            self?.isScanning = false
            HapticManager.shared.success()
        }
    }
}

// MARK: - Object Scanner (3D)

/// Scan physical object → 3D asset using LiDAR.
@Observable
final class ObjectScanner {
    
    var scannedObjects: [Scanned3DObject] = []
    var isScanning = false
    var scanProgress: Double = 0
    
    struct Scanned3DObject: Identifiable {
        let id = UUID()
        var name: String
        var vertexCount: Int
        var date: Date
        var fileSize: String
    }
    
    func startScan(name: String) {
        isScanning = true
        scanProgress = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            self.scanProgress += 0.02
            if self.scanProgress >= 1.0 {
                timer.invalidate()
                let obj = Scanned3DObject(name: name, vertexCount: Int.random(in: 5000...50000), date: Date(), fileSize: "\(Int.random(in: 5...30)) MB")
                self.scannedObjects.insert(obj, at: 0)
                self.isScanning = false
                HapticManager.shared.success()
            }
        }
    }
}

// MARK: - Workspace Sharing

/// Share workspaces as cards with links.
@Observable
final class WorkspaceSharingManager {
    
    var sharedCards: [WorkspaceCard] = []
    
    struct WorkspaceCard: Identifiable {
        let id = UUID()
        var name: String
        var windowCount: Int
        var mode: String
        var shareDate: Date
        var shareLink: String
        var downloads: Int
    }
    
    func shareWorkspace(store: WorkspaceStore) -> WorkspaceCard {
        let card = WorkspaceCard(
            name: store.currentMode.displayName,
            windowCount: store.activeWindows.count,
            mode: store.currentMode.rawValue,
            shareDate: Date(),
            shareLink: "holodesk://share/\(UUID().uuidString.prefix(8))",
            downloads: 0
        )
        sharedCards.append(card)
        HapticManager.shared.success()
        return card
    }
}

// MARK: - Favorite Layouts Manager

/// Save and restore favorite window arrangements.
@Observable
final class FavoriteLayoutsManager {
    
    var favorites: [FavoriteLayout] = []
    
    struct FavoriteLayout: Identifiable {
        let id = UUID()
        var name: String
        var emoji: String
        var windowTypes: [WindowType]
        var savedDate: Date
    }
    
    func saveFavorite(name: String, emoji: String, from store: WorkspaceStore) {
        let layout = FavoriteLayout(
            name: name,
            emoji: emoji,
            windowTypes: store.activeWindows.map(\.type),
            savedDate: Date()
        )
        favorites.append(layout)
        HapticManager.shared.success()
    }
    
    func loadFavorite(_ layout: FavoriteLayout, to store: WorkspaceStore) {
        store.activeWindows.removeAll()
        for (i, type) in layout.windowTypes.enumerated() {
            let window = SpatialWindow(type: type, position: SIMD3(Float(i) * 0.5 - 0.5, 1.4, -1.8))
            store.activeWindows.append(window)
        }
    }
}

// MARK: - Sticky Notes Layer

/// Infinite floating sticky notes that persist across sessions.
@Observable
final class StickyNotesLayer {
    
    var notes: [StickyNote] = StickyNote.defaults
    
    struct StickyNote: Identifiable {
        let id = UUID()
        var text: String
        var color: Color
        var position: SIMD3<Float>
        var rotation: Float  // degrees
        var isPinned: Bool
    }
    
    func addNote(text: String, color: Color, at position: SIMD3<Float>) {
        let note = StickyNote(text: text, color: color, position: position, rotation: Float.random(in: -5...5), isPinned: false)
        notes.append(note)
        HapticManager.shared.lightTap()
    }
    
    func removeNote(_ id: UUID) {
        notes.removeAll { $0.id == id }
    }
    
    func updateText(_ id: UUID, text: String) {
        if let i = notes.firstIndex(where: { $0.id == id }) {
            notes[i].text = text
        }
    }
}

extension StickyNotesLayer.StickyNote {
    static var defaults: [StickyNotesLayer.StickyNote] {
        [
            .init(text: "🚀 Ship HoloDesk v2!", color: .yellow, position: SIMD3(-0.3, 1.6, -1.0), rotation: -3, isPinned: true),
            .init(text: "Review PR #47", color: .green, position: SIMD3(0.2, 1.5, -0.9), rotation: 2, isPinned: false),
            .init(text: "Call Alex re: design", color: .pink, position: SIMD3(0.5, 1.7, -1.1), rotation: -1, isPinned: false),
        ]
    }
}

// MARK: - Quick Capture Inbox

/// Quick capture tray for fast idea/link/note capture.
@Observable
final class QuickCaptureInbox {
    
    var items: [CaptureItem] = []
    var isOpen = false
    
    struct CaptureItem: Identifiable {
        let id = UUID()
        var content: String
        var type: CaptureType
        var timestamp: Date
        var isProcessed: Bool
        
        enum CaptureType: String {
            case note = "doc.text"
            case link = "link"
            case voice = "waveform"
            case photo = "camera"
            case idea = "lightbulb"
        }
    }
    
    func capture(content: String, type: CaptureItem.CaptureType) {
        let item = CaptureItem(content: content, type: type, timestamp: Date(), isProcessed: false)
        items.insert(item, at: 0)
        HapticManager.shared.lightTap()
    }
    
    func processItem(_ id: UUID) {
        if let i = items.firstIndex(where: { $0.id == id }) {
            items[i].isProcessed = true
        }
    }
}

// MARK: - Version History Timeline

/// Scrub through past versions of workspace arrangements.
@Observable
final class VersionHistoryManager {
    
    var history: [VersionSnapshot] = []
    var currentIndex: Int = 0
    var maxHistory = 50
    
    struct VersionSnapshot: Identifiable {
        let id = UUID()
        var timestamp: Date
        var windowTypes: [WindowType]
        var mode: WorkspaceMode
        var label: String
    }
    
    func saveVersion(from store: WorkspaceStore, label: String = "Auto-save") {
        let snap = VersionSnapshot(
            timestamp: Date(),
            windowTypes: store.activeWindows.map(\.type),
            mode: store.currentMode,
            label: label
        )
        history.append(snap)
        if history.count > maxHistory { history.removeFirst() }
        currentIndex = history.count - 1
    }
    
    func restore(_ snapshot: VersionSnapshot, to store: WorkspaceStore) {
        store.activeWindows.removeAll()
        store.currentMode = snapshot.mode
        for (i, type) in snapshot.windowTypes.enumerated() {
            store.activeWindows.append(SpatialWindow(type: type, position: SIMD3(Float(i) * 0.5 - 1, 1.4, -1.8)))
        }
    }
}

// MARK: - Smart Tagging System

/// Auto-tag windows and workspaces for organization.
@Observable
final class SmartTaggingSystem {
    
    var tags: [Tag] = Tag.defaults
    var windowTags: [UUID: [UUID]] = [:]  // windowId: [tagIds]
    
    struct Tag: Identifiable {
        let id = UUID()
        var name: String
        var color: Color
        var emoji: String
    }
    
    func tagWindow(_ windowId: UUID, with tagId: UUID) {
        windowTags[windowId, default: []].append(tagId)
    }
    
    func windowsWithTag(_ tagId: UUID) -> [UUID] {
        windowTags.filter { $0.value.contains(tagId) }.map(\.key)
    }
}

extension SmartTaggingSystem.Tag {
    static var defaults: [SmartTaggingSystem.Tag] {
        [
            .init(name: "Urgent", color: .red, emoji: "🔴"),
            .init(name: "Work", color: .blue, emoji: "💼"),
            .init(name: "Personal", color: .green, emoji: "🏠"),
            .init(name: "Creative", color: .purple, emoji: "🎨"),
            .init(name: "Reference", color: .orange, emoji: "📌"),
        ]
    }
}
