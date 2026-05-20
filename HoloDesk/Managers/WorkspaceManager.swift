// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Workspace Manager

/// Orchestrates save/load/switch of workspace presets.
/// Separate from WorkspaceStore to handle transition logic and preset bundling.
@Observable
final class WorkspaceManager {
    
    private let presetFileNames: [WorkspaceMode: String] = [
        .work:   "WorkMode",
        .study:  "StudyMode",
        .cinema: "CinemaMode",
        .gaming: "GamingMode"
    ]
    
    // MARK: - Load Bundled Preset
    
    /// Load a preset from a bundled JSON file.
    func loadBundledPreset(mode: WorkspaceMode) -> Workspace? {
        guard let fileName = presetFileNames[mode],
              let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(Workspace.self, from: data)
    }
    
    // MARK: - Switch Preset
    
    /// Orchestrate a full mode transition with animated window removal/spawn.
    @MainActor
    func switchPreset(to mode: WorkspaceMode, store: WorkspaceStore) async {
        // 1. Animate out current windows
        let previousMode = store.currentMode
        store.currentMode = mode
        
        // 2. Clear existing windows with stagger
        let windowCount = store.activeWindows.count
        for i in stride(from: windowCount - 1, through: 0, by: -1) {
            if i < store.activeWindows.count {
                store.activeWindows[i].isVisible = false
            }
            try? await Task.sleep(for: .milliseconds(50))
        }
        
        try? await Task.sleep(for: .milliseconds(200))
        store.activeWindows.removeAll()
        
        // 3. Load new preset (try bundled first, then saved)
        if let bundled = loadBundledPreset(mode: mode) {
            store.activeWindows = bundled.windows
        } else {
            // Fall back to WorkspaceStore's built-in presets
            store.loadPreset(mode: mode)
        }
        
        // 4. Animate in new windows with stagger
        for i in 0..<store.activeWindows.count {
            store.activeWindows[i].isVisible = true
            try? await Task.sleep(for: .milliseconds(80))
        }
        
        HapticManager.shared.modeSwitched()
    }
    
    // MARK: - Export Workspace
    
    /// Export a workspace to a sharable JSON file.
    func exportWorkspace(_ workspace: Workspace) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(workspace)
    }
    
    // MARK: - Import Workspace
    
    /// Import a workspace from JSON data.
    func importWorkspace(from data: Data) -> Workspace? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(Workspace.self, from: data)
    }
}
