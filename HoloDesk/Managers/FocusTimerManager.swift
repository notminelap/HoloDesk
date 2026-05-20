// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Focus Timer (Pomodoro)

/// Pomodoro focus timer built into your spatial workspace.
/// Visual countdown that integrates with workspace modes.
@Observable
final class FocusTimerManager {
    
    var isRunning = false
    var isPaused = false
    var currentPhase: FocusPhase = .work
    var remainingSeconds: Int = 25 * 60
    var completedPomodoros: Int = 0
    var totalFocusMinutesToday: Int = 0
    
    private var timer: Timer?
    
    enum FocusPhase: String {
        case work = "Focus"
        case shortBreak = "Short Break"
        case longBreak = "Long Break"
        
        var duration: Int {
            switch self {
            case .work:       return 25 * 60
            case .shortBreak: return 5 * 60
            case .longBreak:  return 15 * 60
            }
        }
        
        var color: Color {
            switch self {
            case .work:       return .holoPrimary
            case .shortBreak: return .holoSuccess
            case .longBreak:  return .holoTertiary
            }
        }
        
        var emoji: String {
            switch self {
            case .work:       return "🧠"
            case .shortBreak: return "☕"
            case .longBreak:  return "🌿"
            }
        }
    }
    
    var progress: Double {
        1.0 - (Double(remainingSeconds) / Double(currentPhase.duration))
    }
    
    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @MainActor
    func start() {
        isRunning = true
        isPaused = false
        remainingSeconds = currentPhase.duration
        startTimer()
        HapticManager.shared.mediumTap()
    }
    
    @MainActor
    func pause() {
        isPaused = true
        timer?.invalidate()
        HapticManager.shared.lightTap()
    }
    
    @MainActor
    func resume() {
        isPaused = false
        startTimer()
        HapticManager.shared.lightTap()
    }
    
    @MainActor
    func stop() {
        isRunning = false
        isPaused = false
        timer?.invalidate()
        remainingSeconds = currentPhase.duration
        HapticManager.shared.lightTap()
    }
    
    @MainActor
    func skip() {
        timer?.invalidate()
        advancePhase()
        HapticManager.shared.mediumTap()
    }
    
    @MainActor
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, !self.isPaused else { return }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                    if self.currentPhase == .work {
                        // Track every minute
                        if self.remainingSeconds % 60 == 0 {
                            self.totalFocusMinutesToday += 1
                        }
                    }
                } else {
                    self.advancePhase()
                }
            }
        }
    }
    
    @MainActor
    private func advancePhase() {
        timer?.invalidate()
        HapticManager.shared.success()
        
        switch currentPhase {
        case .work:
            completedPomodoros += 1
            currentPhase = completedPomodoros % 4 == 0 ? .longBreak : .shortBreak
        case .shortBreak, .longBreak:
            currentPhase = .work
        }
        
        remainingSeconds = currentPhase.duration
        startTimer()
    }
}

// MARK: - Focus Timer View

struct FocusTimerView: View {
    @Bindable var timer: FocusTimerManager
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Compact / Toggle
            Button {
                withAnimation(.spatialInteract) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 8) {
                    // Progress ring
                    ZStack {
                        Circle()
                            .strokeBorder(.white.opacity(0.1), lineWidth: 3)
                            .frame(width: 32, height: 32)
                        
                        Circle()
                            .trim(from: 0, to: timer.progress)
                            .stroke(timer.currentPhase.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 32, height: 32)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: timer.progress)
                        
                        Text(timer.currentPhase.emoji)
                            .font(.system(size: 12))
                    }
                    
                    if isExpanded || timer.isRunning {
                        Text(timer.formattedTime)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                    }
                    
                    if isExpanded {
                        Spacer()
                        Text(timer.currentPhase.rawValue)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(timer.currentPhase.color)
                    }
                }
                .padding(.horizontal, isExpanded ? 14 : 4)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Divider().overlay(Color.white.opacity(0.08))
                
                VStack(spacing: 12) {
                    // Stats
                    HStack(spacing: 16) {
                        statBadge("🍅 \(timer.completedPomodoros)", label: "Pomodoros")
                        statBadge("⏱️ \(timer.totalFocusMinutesToday)m", label: "Focus today")
                    }
                    
                    // Controls
                    HStack(spacing: 12) {
                        if !timer.isRunning {
                            timerButton("Start", icon: "play.fill", color: timer.currentPhase.color) {
                                timer.start()
                            }
                        } else {
                            if timer.isPaused {
                                timerButton("Resume", icon: "play.fill", color: .holoSuccess) {
                                    timer.resume()
                                }
                            } else {
                                timerButton("Pause", icon: "pause.fill", color: .holoWarning) {
                                    timer.pause()
                                }
                            }
                            
                            timerButton("Stop", icon: "stop.fill", color: .red.opacity(0.7)) {
                                timer.stop()
                            }
                            
                            timerButton("Skip", icon: "forward.fill", color: .white.opacity(0.5)) {
                                timer.skip()
                            }
                        }
                    }
                }
                .padding(12)
            }
        }
        .frame(width: isExpanded ? 260 : (timer.isRunning ? 140 : 48))
        .glassBackground(cornerRadius: isExpanded ? 20 : 24)
        .animation(.spatialInteract, value: isExpanded)
    }
    
    private func statBadge(_ value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .innerGlass(cornerRadius: 10)
    }
    
    private func timerButton(_ label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .innerGlass(cornerRadius: 10)
        }
        .buttonStyle(.plain)
    }
}
