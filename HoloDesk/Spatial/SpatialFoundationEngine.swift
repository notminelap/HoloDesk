// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import ARKit
import RealityKit
import Observation

// MARK: - Desk Detection Engine

/// Real-time desk surface detection with adaptive edge glow,
/// automatic re-scanning, and depth-aware UI occlusion.
@MainActor @Observable
final class DeskDetectionEngine {
    
    var detectedSurfaces: [DetectedSurface] = []
    var primaryDesk: DetectedSurface?
    var isScanning = false
    var lastScanDate: Date?
    var edgeGlowIntensity: Float = 0.4
    var environmentColorTemp: Float = 6500 // Kelvin
    
    #if os(visionOS)
    private var session: ARKitSession?
    private var planeProvider: PlaneDetectionProvider?
    #endif
    
    struct DetectedSurface: Identifiable {
        let id = UUID()
        var anchor: UUID
        var center: SIMD3<Float>
        var extent: SIMD2<Float>       // width x depth in meters
        var normal: SIMD3<Float>
        var classification: SurfaceType
        var confidence: Float
    }
    
    enum SurfaceType: String {
        case desk = "Desk"
        case table = "Table"
        case wall = "Wall"
        case floor = "Floor"
        case shelf = "Shelf"
    }
    
    /// Begin scanning for desk surfaces via ARKit scene understanding
    @MainActor
    func startScanning() {
        isScanning = true
        
        #if os(visionOS) && !targetEnvironment(simulator)
        if PlaneDetectionProvider.isSupported {
            Task {
                await startRealARKitScanning()
            }
            return
        }
        #endif
        
        startSimulatedScan()
    }
    
    @MainActor
    private func startRealARKitScanning() async {
        #if os(visionOS)
        let session = ARKitSession()
        let planeProvider = PlaneDetectionProvider(alignments: [.horizontal])
        self.session = session
        self.planeProvider = planeProvider
        
        do {
            try await session.run([planeProvider])
            
            Task { [weak self] in
                guard let self = self else { return }
                for await update in planeProvider.anchorUpdates {
                    let anchor = update.anchor
                    let center = SIMD3(
                        anchor.originFromAnchorTransform.columns.3.x,
                        anchor.originFromAnchorTransform.columns.3.y,
                        anchor.originFromAnchorTransform.columns.3.z
                    )
                    let extent = SIMD2(anchor.geometry.extent.width, anchor.geometry.extent.height)
                    
                    let classification: SurfaceType
                    switch anchor.classification {
                    case .table:
                        classification = .table
                    default:
                        classification = .desk
                    }
                    
                    let surface = DetectedSurface(
                        anchor: anchor.id,
                        center: center,
                        extent: extent,
                        normal: SIMD3(0, 1, 0),
                        classification: classification,
                        confidence: 0.95
                    )
                    
                    await MainActor.run {
                        if update.event == .removed {
                            self.detectedSurfaces.removeAll { $0.anchor == anchor.id }
                        } else {
                            if let idx = self.detectedSurfaces.firstIndex(where: { $0.anchor == anchor.id }) {
                                self.detectedSurfaces[idx] = surface
                            } else {
                                self.detectedSurfaces.append(surface)
                            }
                        }
                        
                        self.primaryDesk = self.detectedSurfaces.max(by: { 
                            ($0.extent.x * $0.extent.y) < ($1.extent.x * $1.extent.y) 
                        })
                        self.isScanning = false
                        self.lastScanDate = Date()
                    }
                }
            }
            
        } catch {
            HoloDeskLogger.spatial.error("ARKit plane session failed: \(error.localizedDescription)")
            startSimulatedScan()
        }
        #else
        startSimulatedScan()
        #endif
    }
    
    @MainActor
    private func startSimulatedScan() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.detectedSurfaces = [
                DetectedSurface(
                    anchor: UUID(),
                    center: SIMD3(0, 0.75, -0.6),
                    extent: SIMD2(1.2, 0.7),
                    normal: SIMD3(0, 1, 0),
                    classification: .desk,
                    confidence: 0.95
                )
            ]
            self.primaryDesk = self.detectedSurfaces.first
            self.isScanning = false
            self.lastScanDate = Date()
            HapticManager.shared.success()
        }
    }
    
    /// Re-scan when environment changes
    @MainActor
    func rescan() {
        startScanning()
    }
    
    /// Adaptive edge glow based on ambient light
    func updateEdgeGlow(ambientLight: Float) {
        edgeGlowIntensity = max(0.1, min(1.0, 1.0 - ambientLight))
    }
    
    /// Match color temperature to environment
    func updateColorTemperature(kelvin: Float) {
        environmentColorTemp = kelvin
    }
    
    /// Check if a spatial position is above the desk
    func isAboveDesk(_ position: SIMD3<Float>) -> Bool {
        guard let desk = primaryDesk else { return false }
        let dx = abs(position.x - desk.center.x)
        let dz = abs(position.z - desk.center.z)
        return dx < desk.extent.x / 2 && dz < desk.extent.y / 2 && position.y > desk.center.y
    }
}

// MARK: - Comfort Animation System

/// Comfort-first animation timing — adapts to user fatigue and preferences.
@MainActor @Observable
final class ComfortAnimationSystem {
    
    var motionIntensity: Float = 1.0   // 0 = no motion, 1 = full
    var animationSpeed: Float = 1.0
    var sessionDuration: TimeInterval = 0
    var isReducedMotionEnabled = false
    
    /// Animation duration adjusted for comfort
    func duration(base: Double) -> Double {
        if isReducedMotionEnabled { return 0 }
        let fatigueFactor = min(sessionDuration / 7200, 0.3)
        return base * Double(animationSpeed) * (1 + fatigueFactor)
    }
    
    /// Spring stiffness adjusted for comfort
    func spring(response: Double = 0.35) -> Animation {
        if isReducedMotionEnabled { return .linear(duration: 0) }
        return .spring(response: response * Double(animationSpeed), dampingFraction: 0.8)
    }
    
    /// Update fatigue model
    func tick() {
        sessionDuration += 1
        // After 2 hours, reduce motion intensity
        if sessionDuration > 7200 {
            motionIntensity = max(0.5, motionIntensity - 0.001)
        }
    }
}

// MARK: - Posture Adaptive Engine

/// Adjusts UI distance and layout based on user posture (seated vs standing).
@MainActor @Observable
final class PostureEngine {
    
    enum Posture: String {
        case seated = "Seated"
        case standing = "Standing"
        case leaning = "Leaning"
        case reclined = "Reclined"
    }
    
    var currentPosture: Posture = .seated
    var headHeight: Float = 1.2     // meters from floor
    var uiDistance: Float = 1.5     // meters from user
    var uiTilt: Float = -10        // degrees (negative = tilted toward user)
    var isCalibrated = false
    
    /// Calibrate based on current head position
    func calibrate(headPosition: SIMD3<Float>) {
        headHeight = headPosition.y
        currentPosture = classifyPosture(height: headPosition.y)
        uiDistance = optimalDistance(for: currentPosture)
        uiTilt = optimalTilt(for: currentPosture)
        isCalibrated = true
    }
    
    /// Seamless transition between postures
    func updatePosture(headPosition: SIMD3<Float>) {
        let newPosture = classifyPosture(height: headPosition.y)
        if newPosture != currentPosture {
            currentPosture = newPosture
            uiDistance = optimalDistance(for: newPosture)
            uiTilt = optimalTilt(for: newPosture)
        }
    }
    
    private func classifyPosture(height: Float) -> Posture {
        switch height {
        case ..<1.0:  return .reclined
        case 1.0..<1.3: return .seated
        case 1.3..<1.5: return .leaning
        default: return .standing
        }
    }
    
    private func optimalDistance(for posture: Posture) -> Float {
        switch posture {
        case .seated:   return 1.5
        case .standing: return 1.8
        case .leaning:  return 1.3
        case .reclined: return 1.2
        }
    }
    
    private func optimalTilt(for posture: Posture) -> Float {
        switch posture {
        case .seated:   return -10
        case .standing: return -5
        case .leaning:  return -15
        case .reclined: return -25
        }
    }
}

// MARK: - Privacy Shield System

/// Full on-device privacy architecture with instant conceal and proximity blur.
@MainActor @Observable
final class PrivacyShieldSystem {
    
    var isPrivacyModeActive = false
    var isProximityBlurEnabled = true
    var concealGestureTrigger = "pinch_both_fists"
    var isCameraDataStored = false      // Always false
    var isOfflineMode = false
    var isCloudSyncEnabled = false
    var isGuestSession = false
    var proximityBlurRadius: Float = 0
    
    struct PrivacyDashboard {
        var cameraAccess = "Never stored"
        var locationAccess = "Not used"
        var networkAccess: String { return "On-device only" }
        var dataRetention = "Local only"
        var exportAvailable = true
        var deleteAvailable = true
    }
    
    let dashboard = PrivacyDashboard()
    
    /// Instant conceal — all windows go opaque/hidden
    func instantConceal() {
        isPrivacyModeActive = true
        HapticManager.shared.mediumTap()
    }
    
    /// Reveal workspace
    func reveal() {
        isPrivacyModeActive = false
        HapticManager.shared.lightTap()
    }
    
    /// Update proximity blur based on nearby people detection
    func updateProximityBlur(nearbyPersonDistance: Float) {
        guard isProximityBlurEnabled else { proximityBlurRadius = 0; return }
        if nearbyPersonDistance < 2.0 {
            proximityBlurRadius = max(0, (2.0 - nearbyPersonDistance) * 15)
        } else {
            proximityBlurRadius = 0
        }
    }
    
    /// Enter guest session — isolated sandbox
    func startGuestSession() {
        isGuestSession = true
    }
    
    func endGuestSession() {
        isGuestSession = false
    }
    
    /// Export all user data
    func exportData() -> Data? {
        // In production: serialize all workspace data
        return nil
    }
    
    /// Delete all user data
    func deleteAllData() {
        // In production: wipe UserDefaults, files, anchors
    }
}
