// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import Foundation
import SwiftUI
import Observation

// MARK: - Window Manager

/// Manages the lifecycle of spatial windows: spawning, positioning, transitions, and demo mode.
@Observable
final class WindowManager {
    
    /// Reference to the workspace store (set by environment)
    weak var store: WorkspaceStore?
    
    /// The window currently being placed (used for initial positioning)
    var pendingWindow: SpatialWindow?
    
    /// Whether mode transition animation is in progress
    var isTransitioning: Bool = false
    
    /// Current transition progress (0.0 - 1.0) for animations
    var transitionProgress: Double = 0
    
    // MARK: - Window Lookup
    
    /// Get a window by ID from the store
    func window(for id: UUID) -> SpatialWindow? {
        store?.activeWindows.first { $0.id == id }
    }
    
    // MARK: - Spawn Window
    
    /// Spawn a new window of the given type with animation.
    @MainActor
    func spawnWindow(type: WindowType, in store: WorkspaceStore) {
        self.store = store
        store.addWindow(type: type)
    }
    
    /// Dismiss a window with animation.
    @MainActor
    func dismissWindow(id: UUID, in store: WorkspaceStore) {
        self.store = store
        withAnimation(.spatialDismiss) {
            store.removeWindow(id: id)
        }
    }
    
    // MARK: - Mode Transitions
    
    /// Transition to a new workspace mode with staged animation.
    @MainActor
    func transitionToMode(_ mode: WorkspaceMode, in store: WorkspaceStore) async {
        self.store = store
        guard !isTransitioning else { return }
        
        isTransitioning = true
        transitionProgress = 0
        
        // Stage 1: Fly out current windows
        withAnimation(.spatialDismiss) {
            store.clearAllWindows()
        }
        
        // Wait for dismissal animation
        try? await Task.sleep(for: .milliseconds(400))
        transitionProgress = 0.3
        
        // Stage 2: Load new preset
        store.loadPreset(mode: mode)
        
        // Stage 3: Windows appear with staggered animation
        // The windows are added but initially need to animate in
        transitionProgress = 0.6
        
        try? await Task.sleep(for: .milliseconds(600))
        transitionProgress = 1.0
        
        try? await Task.sleep(for: .milliseconds(200))
        isTransitioning = false
    }
    
    // MARK: - Demo Mode
    
    /// Run the full demo sequence: cycles through all modes with dramatic transitions.
    @MainActor
    func runDemoSequence(in store: WorkspaceStore) async {
        self.store = store
        guard !store.isDemoRunning else { return }
        
        store.isDemoRunning = true
        
        let modes: [WorkspaceMode] = [.work, .study, .cinema, .gaming, .work]
        
        for mode in modes {
            await transitionToMode(mode, in: store)
            // Pause to showcase each mode
            try? await Task.sleep(for: .seconds(3))
        }
        
        store.isDemoRunning = false
    }
    
    // MARK: - Layout Helpers
    
    /// Rearrange all active windows into an arc layout
    @MainActor
    func rearrangeInArc(in store: WorkspaceStore) {
        self.store = store
        let count = store.activeWindows.count
        guard count > 0 else { return }
        
        let radius: Float = 1.8
        let arcSpan: Float = .pi * 0.7
        let startAngle: Float = -arcSpan / 2
        
        withAnimation(.spatialMove) {
            for i in 0..<count {
                let angle = startAngle + (arcSpan / Float(max(count - 1, 1))) * Float(i)
                let x = sin(angle) * radius
                let z = -cos(angle) * radius
                let y: Float = 1.4
                
                store.activeWindows[i].position = SIMD3(x, y, z)
            }
        }
    }
}
