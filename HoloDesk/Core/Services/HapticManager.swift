// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Haptic Feedback Manager

/// Provides haptic and audio feedback for spatial interactions.
/// On visionOS, uses system-level sensory feedback; gracefully no-ops
/// when UIKit feedback generators are unavailable.
final class HapticManager: @unchecked Sendable {
    
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Core Feedback
    
    /// Light tap — for button presses and selections
    func lightTap() {
        #if os(iOS)
        // UIImpactFeedbackGenerator not available on visionOS
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
    
    /// Medium tap — for window spawn and mode switch
    func mediumTap() {
        #if os(iOS)
        // UIImpactFeedbackGenerator not available on visionOS
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
    
    /// Heavy tap — for significant actions (save, reset)
    func heavyTap() {
        #if os(iOS)
        // UIImpactFeedbackGenerator not available on visionOS
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
    
    /// Success — workspace saved, mode loaded
    func success() {
        #if os(iOS)
        // UINotificationFeedbackGenerator not available on visionOS
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        #endif
    }
    
    /// Warning — about to delete or reset
    func warning() {
        #if os(iOS)
        // UINotificationFeedbackGenerator not available on visionOS
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
        #endif
    }
    
    /// Selection changed — for scrolling through modes/rooms
    func selectionChanged() {
        #if os(iOS)
        // UISelectionFeedbackGenerator not available on visionOS
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        #endif
    }
    
    // MARK: - Semantic Convenience
    
    func windowSpawned()          { mediumTap() }
    func windowDismissed()        { lightTap() }
    func workspaceSaved()         { success() }
    func voiceCommandRecognized() { mediumTap() }
    func objectGrabbed()          { lightTap() }
    func objectDropped()          { mediumTap() }
    
    /// Feedback for switching workspace modes
    func modeSwitched() {
        heavyTap()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.success()
        }
    }
}

