// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Desk Plant System

/// Growing virtual desk plants that evolve with your productivity.
@Observable
final class DeskPlantSystem {
    
    var plants: [DeskPlant] = DeskPlant.defaults
    var totalGrowthPoints = 0
    
    struct DeskPlant: Identifiable {
        let id = UUID()
        var name: String
        var emoji: String
        var stage: Int        // 0-4 (seed → full bloom)
        var growthPoints: Int
        var pointsToNext: Int
        var position: SIMD3<Float>
        var lastWatered: Date
        
        var stageEmoji: String {
            switch stage {
            case 0: return "🌱"
            case 1: return "🌿"
            case 2: return "☘️"
            case 3: return emoji
            case 4: return "🌸"
            default: return emoji
            }
        }
        
        var stageName: String {
            switch stage {
            case 0: return "Sprout"
            case 1: return "Growing"
            case 2: return "Maturing"
            case 3: return "Blooming"
            case 4: return "Full Bloom"
            default: return "Mature"
            }
        }
    }
    
    func addGrowth(points: Int) {
        totalGrowthPoints += points
        for i in 0..<plants.count {
            plants[i].growthPoints += points / plants.count
            if plants[i].growthPoints >= plants[i].pointsToNext && plants[i].stage < 4 {
                plants[i].stage += 1
                plants[i].growthPoints = 0
                plants[i].pointsToNext = Int(Double(plants[i].pointsToNext) * 1.5)
            }
        }
    }
    
    func waterPlant(_ id: UUID) {
        if let i = plants.firstIndex(where: { $0.id == id }) {
            plants[i].lastWatered = Date()
            plants[i].growthPoints += 10
            HapticManager.shared.lightTap()
        }
    }
}

extension DeskPlantSystem.DeskPlant {
    static var defaults: [DeskPlantSystem.DeskPlant] {
        [
            .init(name: "Focus Fern", emoji: "🌿", stage: 2, growthPoints: 30, pointsToNext: 50, position: SIMD3(-0.5, 0.8, -0.8), lastWatered: Date()),
            .init(name: "Zen Bonsai", emoji: "🌳", stage: 1, growthPoints: 15, pointsToNext: 40, position: SIMD3(0.5, 0.8, -0.8), lastWatered: Date().addingTimeInterval(-3600)),
            .init(name: "Productivity Bloom", emoji: "🌺", stage: 3, growthPoints: 45, pointsToNext: 75, position: SIMD3(0, 0.8, -1.2), lastWatered: Date().addingTimeInterval(-7200)),
        ]
    }
}

// MARK: - Daily Quote Engine

/// Motivational quotes that rotate daily.
struct DailyQuoteEngine {
    
    struct Quote {
        var text: String
        var author: String
    }
    
    static let quotes: [Quote] = [
        Quote(text: "The best way to predict the future is to create it.", author: "Alan Kay"),
        Quote(text: "Simplicity is the ultimate sophistication.", author: "Leonardo da Vinci"),
        Quote(text: "Design is not just what it looks like. Design is how it works.", author: "Steve Jobs"),
        Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
        Quote(text: "Innovation distinguishes between a leader and a follower.", author: "Steve Jobs"),
        Quote(text: "Stay hungry, stay foolish.", author: "Stewart Brand"),
        Quote(text: "Think different.", author: "Apple"),
        Quote(text: "Good artists copy, great artists steal.", author: "Pablo Picasso"),
        Quote(text: "Everything you can imagine is real.", author: "Pablo Picasso"),
        Quote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt"),
        Quote(text: "Code is poetry.", author: "WordPress"),
        Quote(text: "First, solve the problem. Then, write the code.", author: "John Johnson"),
        Quote(text: "Make it work, make it right, make it fast.", author: "Kent Beck"),
        Quote(text: "The computer was born to solve problems that did not exist before.", author: "Bill Gates"),
    ]
    
    static func todaysQuote() -> Quote {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return quotes[dayOfYear % quotes.count]
    }
}

// MARK: - Spatial Magic Features

/// Digital twin, workspace memory replay, infinite desk, teleport.
@Observable
final class SpatialMagicEngine {
    
    var isInfiniteDesk = false
    var deskExpansionRadius: Float = 1.0
    var workspaceTimeline: [TimelineSnapshot] = []
    var portalDestinations: [PortalDestination] = PortalDestination.defaults
    
    struct TimelineSnapshot: Identifiable {
        let id = UUID()
        var timestamp: Date
        var windowCount: Int
        var mode: String
        var thumbnail: String  // Emoji representation
    }
    
    struct PortalDestination: Identifiable {
        let id = UUID()
        var name: String
        var emoji: String
        var description: String
        var linkedWorkspaceId: UUID?
    }
    
    /// Expand desk infinitely
    func expandDesk() {
        isInfiniteDesk = true
        deskExpansionRadius = 5.0
    }
    
    func contractDesk() {
        isInfiniteDesk = false
        deskExpansionRadius = 1.0
    }
    
    /// Save current state to timeline
    func saveSnapshot(windowCount: Int, mode: String) {
        let snap = TimelineSnapshot(timestamp: Date(), windowCount: windowCount, mode: mode, thumbnail: "📸")
        workspaceTimeline.append(snap)
        if workspaceTimeline.count > 100 { workspaceTimeline.removeFirst() }
    }
    
    /// Teleport workspace to portal destination
    func teleport(to destination: PortalDestination) {
        HapticManager.shared.success()
    }
}

extension SpatialMagicEngine.PortalDestination {
    static var defaults: [SpatialMagicEngine.PortalDestination] {
        [
            .init(name: "Home Office", emoji: "🏠", description: "Your primary workspace"),
            .init(name: "Coffee Shop", emoji: "☕", description: "Casual working space"),
            .init(name: "Library", emoji: "📚", description: "Quiet study environment"),
            .init(name: "Rooftop", emoji: "🌆", description: "Inspiring city views"),
        ]
    }
}

// MARK: - Delight System

/// Celebration animations, milestone memories, daily greeting.
@Observable
final class DelightSystem {
    
    var showCelebration = false
    var celebrationEmoji = "🎉"
    var dailyGreeting: String = ""
    var milestones: [Milestone] = []
    
    struct Milestone: Identifiable {
        let id = UUID()
        var title: String
        var date: Date
        var emoji: String
    }
    
    func celebrate(emoji: String = "🎉") {
        celebrationEmoji = emoji
        showCelebration = true
        HapticManager.shared.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showCelebration = false
        }
    }
    
    func generateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        let greetings = hour < 12 ? ["Good morning! ☀️", "Rise and shine! 🌅", "Let's crush it today! 💪"]
            : hour < 17 ? ["Good afternoon! 🌤️", "Keep going strong! 🚀", "You're doing great! ⭐"]
            : ["Good evening! 🌙", "Wind down time 🧘", "Reflect on today's wins 🏆"]
        dailyGreeting = greetings.randomElement() ?? "Welcome back! 👋"
    }
}
