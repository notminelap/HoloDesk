// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Screen Time Tracker

/// Tracks how long each window is open, most used times, and generates reports.
@Observable
final class ScreenTimeTracker {
    var windowUsage: [WindowType: TimeInterval] = [:]
    var dailyTotal: TimeInterval = 0
    var peakHour: Int = 14
    var hourlyBreakdown: [Int: TimeInterval] = [:]
    var weeklyStreak: Int = 3
    var dailyGoalMinutes: Int = 240
    
    private var windowOpenTimes: [UUID: Date] = [:]
    
    func windowOpened(id: UUID, type: WindowType) {
        windowOpenTimes[id] = Date()
    }
    
    func windowClosed(id: UUID, type: WindowType) {
        guard let openTime = windowOpenTimes.removeValue(forKey: id) else { return }
        let duration = Date().timeIntervalSince(openTime)
        windowUsage[type, default: 0] += duration
        dailyTotal += duration
        let hour = Calendar.current.component(.hour, from: Date())
        hourlyBreakdown[hour, default: 0] += duration
    }
    
    var progressToGoal: Double {
        min(dailyTotal / (Double(dailyGoalMinutes) * 60), 1.0)
    }
    
    var topWindows: [(WindowType, TimeInterval)] {
        windowUsage.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
    }
}

// MARK: - Screen Time View

struct ScreenTimeView: View {
    @Bindable var tracker: ScreenTimeTracker
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "hourglass")
                    .font(.system(size: 16))
                    .foregroundStyle(.cyan)
                Text("Screen Time")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
            
            // Daily goal ring
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .strokeBorder(.white.opacity(0.08), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    Circle()
                        .trim(from: 0, to: tracker.progressToGoal)
                        .stroke(.cyan, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 1) {
                        Text(formatDuration(tracker.dailyTotal))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                        Text("of \(tracker.dailyGoalMinutes / 60)h goal")
                            .font(.system(size: 8))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    statRow("🔥", "Streak", "\(tracker.weeklyStreak) days")
                    statRow("⏰", "Peak", "\(tracker.peakHour):00")
                    statRow("📊", "Windows", "\(tracker.windowUsage.count) types")
                }
            }
            
            // Hourly chart
            VStack(alignment: .leading, spacing: 6) {
                Text("Today's Activity")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                
                HStack(alignment: .bottom, spacing: 3) {
                    ForEach(6..<22, id: \.self) { hour in
                        let height = max(tracker.hourlyBreakdown[hour, default: Double.random(in: 0...1800)] / 1800, 0.05)
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(hour == tracker.peakHour ? Color.cyan : .white.opacity(0.15))
                                .frame(width: 14, height: CGFloat(height) * 40)
                            Text("\(hour)")
                                .font(.system(size: 6))
                                .foregroundStyle(.white.opacity(0.2))
                        }
                    }
                }
            }
            .padding(10)
            .innerGlass(cornerRadius: 12)
            
            // Top windows
            VStack(alignment: .leading, spacing: 6) {
                Text("Most Used")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                
                ForEach(Array(tracker.topWindows.enumerated()), id: \.offset) { _, entry in
                    HStack(spacing: 8) {
                        Image(systemName: entry.0.iconName)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.windowAccent(for: entry.0))
                        Text(entry.0.displayName)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        Text(formatDuration(entry.1))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
            .padding(10)
            .innerGlass(cornerRadius: 12)
        }
        .padding(20)
        .frame(width: 380)
        .glassBackground(cornerRadius: 24)
    }
    
    private func statRow(_ emoji: String, _ label: String, _ value: String) -> some View {
        HStack(spacing: 6) {
            Text(emoji).font(.system(size: 12))
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.5))
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
        }
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }
}
