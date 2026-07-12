// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Time-Aware Atmosphere 🌅

/// Makes HoloDesk feel alive by shifting the workspace atmosphere based on time of day.
/// Glass tint, particle behavior, AI greeting, and ambient mood all evolve throughout the day.
/// Transitions are smooth 30-minute cross-fades — the user never sees a hard cut.
@MainActor @Observable
final class TimeAwareAtmosphere {
    
    // ────────────────────────────────────────
    // MARK: - Current State
    // ────────────────────────────────────────
    
    var currentPeriod: TimePeriod = .morning
    var glassColorTemperature: Double = 0.5  // 0.0 = cool blue, 1.0 = warm gold
    var ambientBrightness: Double = 0.8
    var particleSpeed: Double = 1.0
    var particleWarmth: Double = 0.5  // Tints particle colors warm/cool
    var greeting: String = ""
    var atmosphereEmoji: String = "☀️"
    
    // ────────────────────────────────────────
    // MARK: - Time Periods
    // ────────────────────────────────────────
    
    enum TimePeriod: String, CaseIterable {
        case dawn       = "Dawn"
        case morning    = "Morning"
        case afternoon  = "Afternoon"
        case goldenHour = "Golden Hour"
        case evening    = "Evening"
        case night      = "Night"
        
        var emoji: String {
            switch self {
            case .dawn:       return "🌅"
            case .morning:    return "☀️"
            case .afternoon:  return "🌤️"
            case .goldenHour: return "🌇"
            case .evening:    return "🌆"
            case .night:      return "🌙"
            }
        }
        
        /// Color temperature shift: 0.0 = cool, 1.0 = warm
        var colorTemperature: Double {
            switch self {
            case .dawn:       return 0.65
            case .morning:    return 0.3
            case .afternoon:  return 0.45
            case .goldenHour: return 0.9
            case .evening:    return 0.7
            case .night:      return 0.15
            }
        }
        
        /// Ambient brightness level
        var brightness: Double {
            switch self {
            case .dawn:       return 0.6
            case .morning:    return 0.9
            case .afternoon:  return 0.85
            case .goldenHour: return 0.7
            case .evening:    return 0.5
            case .night:      return 0.3
            }
        }
        
        /// How fast particles move
        var particleVelocity: Double {
            switch self {
            case .dawn:       return 0.5  // Gentle drift
            case .morning:    return 1.2  // Energetic
            case .afternoon:  return 0.9  // Steady
            case .goldenHour: return 0.6  // Slow, cinematic
            case .evening:    return 0.4  // Winding down
            case .night:      return 0.2  // Barely moving
            }
        }
        
        /// Tint overlay color for glass materials
        var glassTint: Color {
            switch self {
            case .dawn:       return Color(red: 1.0, green: 0.7, blue: 0.4)  // Warm amber
            case .morning:    return Color(red: 0.9, green: 0.95, blue: 1.0) // Clean blue-white
            case .afternoon:  return Color(red: 0.95, green: 0.95, blue: 0.9) // Neutral
            case .goldenHour: return Color(red: 1.0, green: 0.8, blue: 0.3)  // Rich gold
            case .evening:    return Color(red: 0.6, green: 0.5, blue: 0.9)  // Deep indigo
            case .night:      return Color(red: 0.2, green: 0.2, blue: 0.4)  // Ultra dark
            }
        }
        
        /// Greetings pool for this time period
        var greetings: [String] {
            switch self {
            case .dawn:
                return [
                    "Early riser! The world is still quiet. ☀️",
                    "Dawn breaks — your creative peak approaches. 🌅",
                    "The first light is yours. Make it count. ✨"
                ]
            case .morning:
                return [
                    "Good morning! Let's build something great today. ☀️",
                    "Fresh start, fresh workspace. Ready when you are! 💪",
                    "Morning energy is peak energy. Let's go! 🚀"
                ]
            case .afternoon:
                return [
                    "Afternoon momentum — keep pushing! 🌤️",
                    "You're in the zone. Need a break? Just ask. ⭐",
                    "Great progress today. Keep it flowing! 💫"
                ]
            case .goldenHour:
                return [
                    "Golden hour light — everything looks beautiful. 🌇",
                    "The magic hour. Your workspace glows. ✨",
                    "Sunset vibes. Perfect time to wrap up or get inspired. 🎨"
                ]
            case .evening:
                return [
                    "Evening mode — winding down or just getting started? 🌆",
                    "The quiet hours. Deep work awaits. 🌙",
                    "Night owl territory. I'll keep the lights dim. 🦉"
                ]
            case .night:
                return [
                    "Night owl mode activated. I'll keep it dark. 🌙",
                    "The world sleeps, but creators dream. 🦉",
                    "Late night coding session? I'm here for it. 💻"
                ]
            }
        }
        
        /// Determine period from hour
        static func from(hour: Int) -> TimePeriod {
            switch hour {
            case 5..<8:   return .dawn
            case 8..<12:  return .morning
            case 12..<17: return .afternoon
            case 17..<19: return .goldenHour
            case 19..<22: return .evening
            default:      return .night
            }
        }
    }
    
    // ────────────────────────────────────────
    // MARK: - Update
    // ────────────────────────────────────────
    
    /// Call periodically (e.g., every 60 seconds) to update the atmosphere.
    func updateAtmosphere() {
        let hour = Calendar.current.component(.hour, from: Date())
        let newPeriod = TimePeriod.from(hour: hour)
        
        if newPeriod != currentPeriod {
            currentPeriod = newPeriod
        }
        
        // Smooth interpolation toward target values
        let target = currentPeriod
        glassColorTemperature = lerp(glassColorTemperature, target.colorTemperature, t: 0.05)
        ambientBrightness = lerp(ambientBrightness, target.brightness, t: 0.05)
        particleSpeed = lerp(particleSpeed, target.particleVelocity, t: 0.05)
        particleWarmth = lerp(particleWarmth, target.colorTemperature, t: 0.05)
        atmosphereEmoji = target.emoji
        
        // Set greeting if empty
        if greeting.isEmpty {
            greeting = target.greetings.randomElement() ?? "Welcome! 👋"
        }
    }
    
    /// Force-refresh the greeting (e.g., on app launch).
    func refreshGreeting() {
        greeting = currentPeriod.greetings.randomElement() ?? "Welcome! 👋"
    }
    
    /// Linear interpolation helper.
    private func lerp(_ a: Double, _ b: Double, t: Double) -> Double {
        a + (b - a) * t
    }
}

// MARK: - Atmosphere Indicator View

/// A subtle ambient indicator that shows the current time period in the UI.
struct AtmosphereIndicator: View {
    let atmosphere: TimeAwareAtmosphere
    
    var body: some View {
        HStack(spacing: 4) {
            Text(atmosphere.atmosphereEmoji)
                .font(.system(size: 10))
            
            Text(atmosphere.currentPeriod.rawValue)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
            
            // Temperature bar
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.blue, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 24, height: 3)
                .overlay(alignment: .leading) {
                    Circle()
                        .fill(.white)
                        .frame(width: 5, height: 5)
                        .offset(x: CGFloat(atmosphere.glassColorTemperature) * 19)
                }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .innerGlass(cornerRadius: 8)
    }
}

// MARK: - Time-Aware Glass Tint Modifier

/// Applies a subtle color temperature shift to any glass surface based on time of day.
extension View {
    func timeAwareTint(_ atmosphere: TimeAwareAtmosphere) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 24)
                .fill(atmosphere.currentPeriod.glassTint.opacity(0.06 * atmosphere.glassColorTemperature))
                .allowsHitTesting(false)
        )
    }
}
