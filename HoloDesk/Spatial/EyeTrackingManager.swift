// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import ARKit
import Observation

// MARK: - Eye Tracking Gaze Manager

/// Tracks where the user is looking and highlights the closest spatial window.
/// Uses ARKit's eye tracking to create a natural "focus follows gaze" experience.
@MainActor @Observable
final class EyeTrackingManager {
    
    var gazeTarget: UUID?          // Currently gazed window
    var gazePosition: SIMD3<Float> = .zero
    var isTrackingActive = false
    var dwellProgress: Double = 0  // 0..1 for dwell-to-select
    var dwellThreshold: TimeInterval = 1.5
    
    private var dwellStart: Date?
    private var lastGazeTarget: UUID?
    
    /// Update gaze from ARKit world tracking.
    @MainActor
    func updateGaze(rayOrigin: SIMD3<Float>, rayDirection: SIMD3<Float>, windows: [SpatialWindow]) {
        isTrackingActive = true
        gazePosition = rayOrigin + rayDirection * 2.0
        
        // Find closest window to gaze ray
        var closest: (UUID, Float)? = nil
        for window in windows {
            let dist = distance(gazePosition, window.position)
            if dist < 0.5 {
                if closest == nil || dist < closest!.1 {
                    closest = (window.id, dist)
                }
            }
        }
        
        let newTarget = closest?.0
        if newTarget != gazeTarget {
            gazeTarget = newTarget
            dwellStart = newTarget != nil ? Date() : nil
            dwellProgress = 0
            if newTarget != nil { HapticManager.shared.lightTap() }
        }
        
        // Dwell progress
        if let start = dwellStart, gazeTarget != nil {
            let elapsed = Date().timeIntervalSince(start)
            dwellProgress = min(elapsed / dwellThreshold, 1.0)
        }
    }
    
    func isGazedAt(_ windowId: UUID) -> Bool {
        gazeTarget == windowId
    }
}
