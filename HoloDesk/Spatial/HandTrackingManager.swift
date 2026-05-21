// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import ARKit
import Observation

// MARK: - Hand Tracking Manager

@Observable
final class HandTrackingManager {
    var isTracking = false
    var leftHandPosition: SIMD3<Float>?
    var rightHandPosition: SIMD3<Float>?
    var isPinching = false
    
    private var session: ARKitSession?
    private var handTracking: HandTrackingProvider?
    
    @MainActor
    func startTracking() async {
        guard HandTrackingProvider.isSupported else {
            print("Hand tracking not supported on this device")
            return
        }
        
        let session = ARKitSession()
        let handTracking = HandTrackingProvider()
        self.session = session
        self.handTracking = handTracking
        
        do {
            try await session.run([handTracking])
            isTracking = true
            
            for await update in handTracking.anchorUpdates {
                switch update.event {
                case .updated:
                    let anchor = update.anchor
                    if anchor.chirality == .left {
                        leftHandPosition = extractHandPosition(anchor)
                    } else {
                        rightHandPosition = extractHandPosition(anchor)
                    }
                    // Check for pinch gesture
                    isPinching = checkPinch(anchor)
                    
                case .added:
                    break
                case .removed:
                    if update.anchor.chirality == .left {
                        leftHandPosition = nil
                    } else {
                        rightHandPosition = nil
                    }
                }
            }
        } catch {
            print("Failed to start hand tracking: \(error)")
            isTracking = false
        }
    }
    
    func stopTracking() {
        session?.stop()
        isTracking = false
    }
    
    private func extractHandPosition(_ anchor: HandAnchor) -> SIMD3<Float> {
        let transform = anchor.originFromAnchorTransform
        return SIMD3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    
    private func checkPinch(_ anchor: HandAnchor) -> Bool {
        guard let skeleton = anchor.handSkeleton else { return false }
        let thumbTip = skeleton.joint(.thumbTip)
        let indexTip = skeleton.joint(.indexFingerTip)
        
        guard thumbTip.isTracked && indexTip.isTracked else { return false }
        
        let thumbPos = SIMD3<Float>(
            thumbTip.anchorFromJointTransform.columns.3.x,
            thumbTip.anchorFromJointTransform.columns.3.y,
            thumbTip.anchorFromJointTransform.columns.3.z
        )
        let indexPos = SIMD3<Float>(
            indexTip.anchorFromJointTransform.columns.3.x,
            indexTip.anchorFromJointTransform.columns.3.y,
            indexTip.anchorFromJointTransform.columns.3.z
        )
        
        let distance = simd_distance(thumbPos, indexPos)
        return distance < 0.02 // 2cm threshold for pinch
    }
}
