// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Productivity Dashboard

/// Tracks and displays productivity metrics — focus time, mode usage, window stats.
@MainActor @Observable
final class ProductivityTracker {
    var sessions: [FocusSession] = []
    var modeUsage: [WorkspaceMode: TimeInterval] = [:]
    var windowSpawnCount: [WindowType: Int] = [:]
    var currentSessionStart: Date?
    var totalFocusToday: TimeInterval = 0
    
    struct FocusSession: Identifiable, Codable {
        let id: UUID
        var mode: WorkspaceMode
        var duration: TimeInterval
        var windowCount: Int
        var date: Date
    }
    
    func startSession(mode: WorkspaceMode) {
        currentSessionStart = Date()
    }
    
    func endSession(mode: WorkspaceMode, windowCount: Int) {
        guard let start = currentSessionStart else { return }
        let duration = Date().timeIntervalSince(start)
        let session = FocusSession(id: UUID(), mode: mode, duration: duration, windowCount: windowCount, date: Date())
        sessions.append(session)
        modeUsage[mode, default: 0] += duration
        totalFocusToday += duration
        currentSessionStart = nil
    }
    
    func trackWindowSpawn(_ type: WindowType) {
        windowSpawnCount[type, default: 0] += 1
    }
    
    var focusHoursToday: Double { totalFocusToday / 3600 }
    var mostUsedMode: WorkspaceMode? { modeUsage.max(by: { $0.value < $1.value })?.key }
    var totalSessions: Int { sessions.count }
}

// MARK: - Productivity Dashboard View

struct ProductivityDashboardView: View {
    @Bindable var tracker: ProductivityTracker
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.holoSuccess)
                Text("Productivity")
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
            
            // Stats cards
            HStack(spacing: 10) {
                statCard("⏱️", value: String(format: "%.1fh", tracker.focusHoursToday), label: "Focus Today")
                statCard("🔄", value: "\(tracker.totalSessions)", label: "Sessions")
                statCard("🪟", value: "\(tracker.windowSpawnCount.values.reduce(0, +))", label: "Windows Used")
            }
            
            // Mode usage chart
            VStack(alignment: .leading, spacing: 8) {
                Text("Mode Usage")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .textCase(.uppercase)
                
                ForEach(WorkspaceMode.allCases.filter { $0 != .custom }) { mode in
                    modeBar(mode)
                }
            }
            .padding(12)
            .innerGlass(cornerRadius: 14)
            
            // Most used windows
            VStack(alignment: .leading, spacing: 8) {
                Text("Most Used Windows")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .textCase(.uppercase)
                
                let sorted = tracker.windowSpawnCount.sorted { $0.value > $1.value }.prefix(5)
                ForEach(Array(sorted.enumerated()), id: \.offset) { _, entry in
                    HStack {
                        Image(systemName: entry.key.iconName)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.windowAccent(for: entry.key))
                        Text(entry.key.displayName)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        Text("\(entry.value)×")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                
                if sorted.isEmpty {
                    Text("No data yet — start using windows!")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            .padding(12)
            .innerGlass(cornerRadius: 14)
            
            // Streak
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("Keep going! You've been productive today.")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(10)
            .innerGlass(cornerRadius: 10)
        }
        .padding(20)
        .frame(width: 400)
        .glassBackground(cornerRadius: 24)
    }
    
    private func statCard(_ emoji: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji).font(.system(size: 18))
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .innerGlass(cornerRadius: 12)
    }
    
    private func modeBar(_ mode: WorkspaceMode) -> some View {
        let total = tracker.modeUsage.values.reduce(0, +)
        let usage = tracker.modeUsage[mode, default: 0]
        let fraction = total > 0 ? usage / total : 0
        
        return HStack(spacing: 8) {
            Text(mode.emoji).font(.system(size: 12))
            Text(mode.displayName)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 55, alignment: .leading)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.08)).frame(height: 6)
                    Capsule().fill(Color.modeTint(for: mode)).frame(width: max(geo.size.width * fraction, 2), height: 6)
                }
            }
            .frame(height: 6)
            
            Text(String(format: "%.0f%%", fraction * 100))
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.4))
                .frame(width: 30, alignment: .trailing)
        }
    }
}
