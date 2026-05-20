// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import Foundation
import Observation

// MARK: - Workspace Store

/// Central observable store managing all workspace state: active windows, saved presets, and current mode.
@Observable
final class WorkspaceStore {
    
    // MARK: - Active State
    
    /// Currently active workspace mode
    var currentMode: WorkspaceMode = .work
    
    /// All currently placed windows
    var activeWindows: [SpatialWindow] = []
    
    /// Whether the immersive space is open
    var isImmersiveSpaceOpen: Bool = false
    
    /// Whether demo mode is running
    var isDemoRunning: Bool = false
    
    /// Voice command transcript (for UI display)
    var voiceTranscript: String = ""
    
    /// Whether voice recognition is active
    var isListening: Bool = false
    
    // MARK: - Saved Workspaces
    
    /// All saved workspace presets (including built-in and custom)
    var savedWorkspaces: [Workspace] = []
    
    // MARK: - Initialization
    
    init() {
        loadSavedWorkspaces()
        if savedWorkspaces.isEmpty {
            createBuiltInPresets()
        }
    }
    
    // MARK: - Window Management
    
    /// Add a new window of the given type at a default position.
    func addWindow(type: WindowType) {
        let position = calculateNextPosition()
        let window = SpatialWindow(
            type: type,
            position: position,
            zIndex: activeWindows.count
        )
        activeWindows.append(window)
    }
    
    /// Remove a window by ID.
    func removeWindow(id: UUID) {
        activeWindows.removeAll { $0.id == id }
    }
    
    /// Update a window's position.
    func updateWindowPosition(id: UUID, position: SIMD3<Float>) {
        guard let index = activeWindows.firstIndex(where: { $0.id == id }) else { return }
        activeWindows[index].position = position
    }
    
    /// Update a window's size.
    func updateWindowSize(id: UUID, size: SIMD2<Float>) {
        guard let index = activeWindows.firstIndex(where: { $0.id == id }) else { return }
        activeWindows[index].size = size
    }
    
    /// Get a window by ID.
    func window(for id: UUID) -> SpatialWindow? {
        activeWindows.first { $0.id == id }
    }
    
    /// Remove all active windows.
    func clearAllWindows() {
        activeWindows.removeAll()
    }
    
    // MARK: - Position Calculation
    
    /// Calculate a comfortable position for the next window (arranged in an arc).
    private func calculateNextPosition() -> SIMD3<Float> {
        let count = activeWindows.count
        let radius: Float = 1.8  // meters from user
        let arcSpan: Float = .pi * 0.8  // 144 degrees total arc
        let startAngle: Float = -.pi * 0.4
        
        let maxSlots = 8
        let slot = count % maxSlots
        let angle = startAngle + (arcSpan / Float(maxSlots - 1)) * Float(slot)
        
        let x = sin(angle) * radius
        let z = -cos(angle) * radius
        let y: Float = 1.4 + Float(count / maxSlots) * 0.3  // stack vertically if > 8
        
        return SIMD3(x, y, z)
    }
    
    // MARK: - Workspace Presets
    
    /// Load a workspace preset by mode — animates transition.
    func loadPreset(mode: WorkspaceMode) {
        currentMode = mode
        
        guard let workspace = savedWorkspaces.first(where: { $0.mode == mode }) else { return }
        
        // Replace active windows with preset
        activeWindows = workspace.windows
    }
    
    /// Save the current layout as a workspace.
    func saveCurrentWorkspace(name: String? = nil) {
        let workspaceName = name ?? "\(currentMode.displayName) - \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))"
        
        let workspace = Workspace(
            name: workspaceName,
            mode: currentMode,
            windows: activeWindows
        )
        
        // Update existing or add new
        if let index = savedWorkspaces.firstIndex(where: { $0.mode == currentMode && $0.name == workspaceName }) {
            savedWorkspaces[index] = workspace
        } else {
            savedWorkspaces.append(workspace)
        }
        
        persistWorkspaces()
    }
    
    // MARK: - Persistence
    
    private var saveURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("holodesk_workspaces.json")
    }
    
    private func persistWorkspaces() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        guard let data = try? encoder.encode(savedWorkspaces) else { return }
        try? data.write(to: saveURL)
    }
    
    private func loadSavedWorkspaces() {
        guard let data = try? Data(contentsOf: saveURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        savedWorkspaces = (try? decoder.decode([Workspace].self, from: data)) ?? []
    }
    
    // MARK: - Built-in Presets
    
    private func createBuiltInPresets() {
        savedWorkspaces = [
            createWorkPreset(),
            createStudyPreset(),
            createCinemaPreset(),
            createGamingPreset()
        ]
        persistWorkspaces()
    }
    
    private func createWorkPreset() -> Workspace {
        Workspace(
            name: "Work Mode",
            mode: .work,
            windows: [
                SpatialWindow(type: .messages,  position: SIMD3(-1.3, 1.5, -1.8), size: SIMD2(350, 450)),
                SpatialWindow(type: .calendar,  position: SIMD3(-0.2, 1.6, -2.0), size: SIMD2(500, 400)),
                SpatialWindow(type: .notes,     position: SIMD3(1.0, 1.6, -1.8),  size: SIMD2(350, 420)),
                SpatialWindow(type: .todo,      position: SIMD3(0.2, 1.15, -1.6), size: SIMD2(320, 280)),
                SpatialWindow(type: .files,     position: SIMD3(0.0, 0.85, -1.4), size: SIMD2(450, 220)),
                SpatialWindow(type: .photos,    position: SIMD3(-1.0, 0.9, -1.5), size: SIMD2(380, 280)),
                SpatialWindow(type: .music,     position: SIMD3(1.1, 1.0, -1.5),  size: SIMD2(320, 340)),
                SpatialWindow(type: .weather,   position: SIMD3(0.6, 0.9, -1.3),  size: SIMD2(220, 200))
            ]
        )
    }
    
    private func createStudyPreset() -> Workspace {
        Workspace(
            name: "Study Mode",
            mode: .study,
            windows: [
                SpatialWindow(type: .notes,     position: SIMD3(0.0, 1.6, -2.0),  size: SIMD2(500, 550)),
                SpatialWindow(type: .calendar,  position: SIMD3(-1.0, 1.4, -1.8), size: SIMD2(400, 350)),
                SpatialWindow(type: .todo,      position: SIMD3(1.0, 1.4, -1.8),  size: SIMD2(350, 350)),
                SpatialWindow(type: .music,     position: SIMD3(0.0, 0.9, -1.4),  size: SIMD2(300, 280))
            ]
        )
    }
    
    private func createCinemaPreset() -> Workspace {
        Workspace(
            name: "Cinema Mode",
            mode: .cinema,
            windows: [
                SpatialWindow(type: .video, position: SIMD3(0.0, 1.6, -3.0), size: SIMD2(900, 520)),
                SpatialWindow(type: .music, position: SIMD3(-1.5, 1.0, -1.5), size: SIMD2(280, 260))
            ],
            environmentSettings: .cinemaDefault
        )
    }
    
    private func createGamingPreset() -> Workspace {
        Workspace(
            name: "Gaming Mode",
            mode: .gaming,
            windows: [
                SpatialWindow(type: .video,   position: SIMD3(0.0, 1.5, -2.5), size: SIMD2(1000, 450)),
                SpatialWindow(type: .music,   position: SIMD3(-1.8, 1.0, -1.5), size: SIMD2(260, 240)),
                SpatialWindow(type: .messages, position: SIMD3(1.8, 1.2, -1.5), size: SIMD2(280, 350))
            ],
            environmentSettings: .gamingDefault
        )
    }
}
