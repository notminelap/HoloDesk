// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Spatial Animation Presets

extension Animation {
    /// Bouncy spring — for window spawn
    static let spatialSpawn = Animation.spring(response: 0.55, dampingFraction: 0.7, blendDuration: 0)
    
    /// Smooth spring — for window repositioning
    static let spatialMove = Animation.spring(response: 0.45, dampingFraction: 0.85, blendDuration: 0)
    
    /// Quick spring — for UI interactions (buttons, hover)
    static let spatialInteract = Animation.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)
    
    /// Dramatic spring — for mode transitions
    static let spatialTransition = Animation.spring(response: 0.7, dampingFraction: 0.65, blendDuration: 0)
    
    /// Slow ease — for environment changes (lighting, atmosphere)
    static let spatialEnvironment = Animation.easeInOut(duration: 1.2)
    
    /// Fly out animation — fast exit
    static let spatialDismiss = Animation.spring(response: 0.35, dampingFraction: 0.9, blendDuration: 0)
    
    /// Gentle breathing — for meditation orbs, status indicators
    static let spatialBreathe = Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)
    
    /// Micro-feedback — for selection changes, minor interactions
    static let spatialMicro = Animation.spring(response: 0.15, dampingFraction: 0.9, blendDuration: 0)
    
    /// Parallax shift — subtle movement responding to head position
    static let spatialParallax = Animation.interpolatingSpring(stiffness: 300, damping: 30)
    
    /// Staggered spawn — creates staggered delay for multiple items
    static func spatialStagger(index: Int, total: Int) -> Animation {
        .spatialSpawn.delay(Double(index) * 0.06)
    }
    
    /// Custom delay helper
    static func spatialSpawn(delay: Double) -> Animation {
        .spatialSpawn.delay(delay)
    }
}

// MARK: - Transition Presets

extension AnyTransition {
    /// Window appears: scale + opacity from center
    static let spatialAppear = AnyTransition
        .scale(scale: 0.3)
        .combined(with: .opacity)
    
    /// Window flies in from below
    static let spatialFlyUp = AnyTransition
        .move(edge: .bottom)
        .combined(with: .opacity)
        .combined(with: .scale(scale: 0.8))
    
    /// Window shrinks and fades out
    static let spatialShrink = AnyTransition
        .scale(scale: 0.1)
        .combined(with: .opacity)
    
    /// Slide in from right (for panels)
    static let spatialSlideIn = AnyTransition
        .move(edge: .trailing)
        .combined(with: .opacity)
    
    /// Blur transition (for privacy mode)
    static let spatialBlur = AnyTransition
        .opacity
        .combined(with: .scale(scale: 1.05))
}
