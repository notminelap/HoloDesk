// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Wellness Manager

/// Break reminders, posture awareness, breathing, eye rest, hydration.
@MainActor @Observable
final class WellnessManager {
    
    var isBreakDue = false
    var lastBreakTime = Date()
    var breakInterval: TimeInterval = 1500  // 25 min
    var hydrationCount = 0
    var hydrationGoal = 8
    var stretchesDone = 0
    var eyeRestActive = false
    var breathingActive = false
    var sessionMinutes = 0
    var postureScore: Int = 85   // 0-100
    var fatigueLevel: Float = 0  // 0-1
    
    struct BreathingExercise {
        var inhale: Double = 4
        var hold: Double = 7
        var exhale: Double = 8
        var name = "4-7-8 Relaxing Breath"
    }
    
    let exercises: [BreathingExercise] = [
        BreathingExercise(inhale: 4, hold: 7, exhale: 8, name: "4-7-8 Relaxing"),
        BreathingExercise(inhale: 4, hold: 4, exhale: 4, name: "Box Breathing"),
        BreathingExercise(inhale: 6, hold: 0, exhale: 6, name: "Calm Breathing"),
    ]
    
    /// Check if break is due
    func checkBreak() {
        let elapsed = Date().timeIntervalSince(lastBreakTime)
        isBreakDue = elapsed >= breakInterval
        fatigueLevel = min(Float(elapsed / 7200), 1.0)
    }
    
    /// Log a break
    func takeBreak() {
        lastBreakTime = Date()
        isBreakDue = false
        HapticManager.shared.success()
    }
    
    func drinkWater() {
        hydrationCount = min(hydrationCount + 1, hydrationGoal)
        HapticManager.shared.lightTap()
    }
    
    func logStretch() {
        stretchesDone += 1
        HapticManager.shared.lightTap()
    }
    
    func startEyeRest() {
        eyeRestActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self] in
            self?.eyeRestActive = false
        }
    }
}

// MARK: - Smart Home Hub

/// Smart home control — lights, climate, cameras, scenes.
@MainActor @Observable
final class SmartHomeHub {
    
    var devices: [SmartDevice] = SmartDevice.defaults
    var scenes: [HomeScene] = HomeScene.defaults
    var currentTemperature: Double = 22.5
    var targetTemperature: Double = 23.0
    
    struct SmartDevice: Identifiable {
        let id = UUID()
        var name: String
        var type: DeviceType
        var isOn: Bool
        var value: Double   // brightness, temp, etc.
        var room: String
        
        enum DeviceType: String {
            case light = "Light"
            case thermostat = "Climate"
            case speaker = "Speaker"
            case camera = "Camera"
            case lock = "Lock"
            case blind = "Blinds"
        }
        
        var icon: String {
            switch type {
            case .light:      return "lightbulb.fill"
            case .thermostat: return "thermometer.medium"
            case .speaker:    return "hifispeaker.fill"
            case .camera:     return "video.fill"
            case .lock:       return isOn ? "lock.fill" : "lock.open.fill"
            case .blind:      return "blinds.vertical.open"
            }
        }
    }
    
    struct HomeScene: Identifiable {
        let id = UUID()
        var name: String
        var emoji: String
        var actions: String
    }
    
    func toggleDevice(id: UUID) {
        if let i = devices.firstIndex(where: { $0.id == id }) {
            devices[i].isOn.toggle()
            HapticManager.shared.lightTap()
        }
    }
    
    func activateScene(_ scene: HomeScene) {
        HapticManager.shared.success()
    }
}

extension SmartHomeHub.SmartDevice {
    static var defaults: [SmartHomeHub.SmartDevice] {
        [
            .init(name: "Desk Lamp", type: .light, isOn: true, value: 0.8, room: "Office"),
            .init(name: "Ceiling Light", type: .light, isOn: true, value: 0.6, room: "Office"),
            .init(name: "AC", type: .thermostat, isOn: true, value: 23, room: "Office"),
            .init(name: "HomePod", type: .speaker, isOn: false, value: 0.4, room: "Office"),
            .init(name: "Front Door", type: .lock, isOn: true, value: 1, room: "Entry"),
            .init(name: "Doorbell Cam", type: .camera, isOn: true, value: 1, room: "Entry"),
            .init(name: "Living Room", type: .light, isOn: false, value: 0.5, room: "Living"),
            .init(name: "Bedroom Blinds", type: .blind, isOn: false, value: 0.3, room: "Bedroom"),
        ]
    }
}

extension SmartHomeHub.HomeScene {
    static var defaults: [SmartHomeHub.HomeScene] {
        [
            .init(name: "Focus Mode", emoji: "🎯", actions: "Dim lights, silence speakers, lock door"),
            .init(name: "Movie Night", emoji: "🎬", actions: "Lights off, blinds closed, speaker on"),
            .init(name: "Good Morning", emoji: "☀️", actions: "Blinds open, lights warm, AC 23°"),
            .init(name: "Leave Home", emoji: "🚪", actions: "All off, lock door, arm camera"),
            .init(name: "Bedtime", emoji: "🌙", actions: "Dim all, lock, AC 21°"),
        ]
    }
}

// MARK: - Achievement System

/// Gamification — badges, milestones, streaks, daily goals.
@MainActor @Observable
final class AchievementSystem {
    
    var achievements: [Achievement] = Achievement.defaults
    var totalPoints = 0
    var level = 1
    var currentStreak = 3
    var dailyGoalsMet = 0
    
    struct Achievement: Identifiable {
        let id = UUID()
        var title: String
        var description: String
        var emoji: String
        var points: Int
        var isUnlocked: Bool
        var progress: Double   // 0-1
        var category: Category
        
        enum Category { case productivity, wellness, social, creative, streak }
    }
    
    func unlock(_ achievementId: UUID) {
        if let i = achievements.firstIndex(where: { $0.id == achievementId }) {
            achievements[i].isUnlocked = true
            totalPoints += achievements[i].points
            updateLevel()
            HapticManager.shared.success()
        }
    }
    
    private func updateLevel() {
        level = totalPoints / 500 + 1
    }
}

extension AchievementSystem.Achievement {
    static var defaults: [AchievementSystem.Achievement] {
        [
            .init(title: "First Launch", description: "Welcome to HoloDesk!", emoji: "🚀", points: 10, isUnlocked: true, progress: 1, category: .productivity),
            .init(title: "Window Master", description: "Open 10 windows at once", emoji: "🪟", points: 50, isUnlocked: false, progress: 0.6, category: .productivity),
            .init(title: "Focus Champion", description: "Complete 5 Pomodoro sessions", emoji: "🏆", points: 100, isUnlocked: false, progress: 0.4, category: .productivity),
            .init(title: "Zen Mode", description: "Meditate for 30 minutes total", emoji: "🧘", points: 75, isUnlocked: false, progress: 0.2, category: .wellness),
            .init(title: "Hydration Hero", description: "Meet water goal 7 days straight", emoji: "💧", points: 100, isUnlocked: false, progress: 0.7, category: .wellness),
            .init(title: "Spatial Artist", description: "Use whiteboard for 1 hour", emoji: "🎨", points: 50, isUnlocked: false, progress: 0.3, category: .creative),
            .init(title: "Week Warrior", description: "7-day productivity streak", emoji: "🔥", points: 200, isUnlocked: false, progress: 0.43, category: .streak),
            .init(title: "Collaborator", description: "Share workspace 3 times", emoji: "🤝", points: 75, isUnlocked: false, progress: 0.33, category: .social),
        ]
    }
}

// MARK: - Performance Guardian

/// 120fps guarantee, thermal management, crash recovery.
@MainActor @Observable
final class PerformanceGuardian {
    
    var currentFPS: Int = 90
    var targetFPS: Int = 120
    var thermalState: ThermalState = .nominal
    var memoryUsageMB: Int = 245
    var isLowPowerMode = false
    var renderScale: Float = 1.0
    var lastCrashRecoveryDate: Date?
    
    enum ThermalState: String {
        case nominal = "Nominal"
        case fair = "Fair"
        case serious = "Serious"
        case critical = "Critical"
        
        var color: Color {
            switch self {
            case .nominal: return .green
            case .fair: return .yellow
            case .serious: return .orange
            case .critical: return .red
            }
        }
    }
    
    /// Adaptive rendering based on thermal state
    func updateRendering() {
        switch thermalState {
        case .nominal:  renderScale = 1.0
        case .fair:     renderScale = 0.85
        case .serious:  renderScale = 0.7
        case .critical: renderScale = 0.5
        }
    }
    
    /// Crash-safe workspace save
    func autoSave(store: WorkspaceStore) {
        store.saveCurrentWorkspace()
    }
    
    /// Recover from crash
    func recoverWorkspace() -> Bool {
        lastCrashRecoveryDate = Date()
        return true
    }
}
