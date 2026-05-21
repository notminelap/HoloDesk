// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import ARKit
import Observation

// MARK: - Spatial Anchor Manager

@Observable
final class SpatialAnchorManager {
    var anchors: [UUID: WorldAnchor] = [:]
    var isAvailable = false
    
    private var session: ARKitSession?
    private var worldTracking: WorldTrackingProvider?
    
    @MainActor
    func loadAnchors() async {
        guard WorldTrackingProvider.isSupported else {
            HoloDeskLogger.spatial.warning("World tracking not supported")
            return
        }
        
        let session = ARKitSession()
        let worldTracking = WorldTrackingProvider()
        self.session = session
        self.worldTracking = worldTracking
        
        do {
            try await session.run([worldTracking])
            isAvailable = true
            
            for await update in worldTracking.anchorUpdates {
                switch update.event {
                case .added, .updated:
                    anchors[update.anchor.id] = update.anchor
                case .removed:
                    anchors.removeValue(forKey: update.anchor.id)
                }
            }
        } catch {
            HoloDeskLogger.spatial.error("Failed to start world tracking: \(error.localizedDescription)")
        }
    }
    
    func addAnchor(at transform: simd_float4x4) async -> UUID? {
        guard let worldTracking else { return nil }
        let anchor = WorldAnchor(originFromAnchorTransform: transform)
        do {
            try await worldTracking.addAnchor(anchor)
            return anchor.id
        } catch {
            HoloDeskLogger.spatial.error("Failed to add anchor: \(error.localizedDescription)")
            return nil
        }
    }
    
    func removeAnchor(id: UUID) async {
        guard let worldTracking else { return }
        if let anchor = anchors[id] {
            do {
                try await worldTracking.removeAnchor(anchor)
            } catch {
                HoloDeskLogger.spatial.error("Failed to remove anchor: \(error.localizedDescription)")
            }
        }
    }
}
