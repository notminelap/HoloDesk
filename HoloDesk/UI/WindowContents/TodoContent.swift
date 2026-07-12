// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Todo Window Content (Interactive)

/// Full-featured task list with add, complete, delete, priority colors, and progress.
struct TodoContent: View {
    @State private var items: [TodoItem] = [
        TodoItem(text: "Finish monthly report", done: false, priority: .high),
        TodoItem(text: "Review Q4 budget", done: false, priority: .medium),
        TodoItem(text: "Email design team", done: true, priority: .low),
        TodoItem(text: "Prepare client deck", done: false, priority: .high),
        TodoItem(text: "Update project timeline", done: true, priority: .medium),
        TodoItem(text: "Schedule team standup", done: false, priority: .low),
    ]
    @State private var newTaskText = ""
    @State private var newTaskPriority: Priority = .medium
    @State private var showAddField = false
    
    @Environment(SpatialAudioManager.self) private var audio
    
    struct TodoItem: Identifiable {
        let id = UUID()
        var text: String
        var done: Bool
        var priority: Priority
    }
    
    enum Priority: String, CaseIterable {
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var color: Color {
            switch self {
            case .high:   return .red
            case .medium: return .orange
            case .low:    return .green
            }
        }
        
        var icon: String {
            switch self {
            case .high:   return "exclamationmark.circle.fill"
            case .medium: return "minus.circle.fill"
            case .low:    return "arrow.down.circle.fill"
            }
        }
    }
    
    private var completedCount: Int { items.filter(\.done).count }
    private var progress: Double { items.isEmpty ? 0 : Double(completedCount) / Double(items.count) }
    
    // Tab switching and Pomodoro Timer States
    enum Tab {
        case tasks
        case focus
    }
    
    @State private var selectedTab: Tab = .tasks
    @State private var timeRemaining = 1500 // 25 minutes default
    @State private var isTimerRunning = false
    @State private var isWorkSession = true
    @State private var totalSessionTime = 1500
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Tabs Selector (Premium Glass Capsule)
            HStack(spacing: 4) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = .tasks
                    }
                    audio.playSFX(.softTick)
                    HapticManager.shared.lightTap()
                } label: {
                    Text("Tasks")
                        .font(.system(size: 10, weight: selectedTab == .tasks ? .bold : .medium))
                        .foregroundStyle(selectedTab == .tasks ? .white : .white.opacity(0.4))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(selectedTab == .tasks ? .white.opacity(0.1) : .clear, in: Capsule())
                }
                .buttonStyle(.plain)
                
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = .focus
                    }
                    audio.playSFX(.softTick)
                    HapticManager.shared.lightTap()
                } label: {
                    Text("Focus")
                        .font(.system(size: 10, weight: selectedTab == .focus ? .bold : .medium))
                        .foregroundStyle(selectedTab == .focus ? .white : .white.opacity(0.4))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(selectedTab == .focus ? .white.opacity(0.1) : .clear, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(3)
            .background(.white.opacity(0.04), in: Capsule())
            .padding(.top, 10)
            
            if selectedTab == .tasks {
                // Task list View
                VStack(spacing: 0) {
                    // Header with progress
                    VStack(spacing: 6) {
                        HStack {
                            Text("To-Do")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                            Spacer()
                            
                            Text("\(completedCount)/\(items.count)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.4))
                            
                            Button { withAnimation(.spring(response: 0.3)) { showAddField.toggle() } } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.holoPrimary)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(.white.opacity(0.08))
                                    .frame(height: 4)
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.holoPrimary, .holoSuccess],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * progress, height: 4)
                                    .animation(.spring(response: 0.4), value: progress)
                            }
                        }
                        .frame(height: 4)
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    
                    // Add task field
                    if showAddField {
                        HStack(spacing: 8) {
                            // Priority selector
                            Menu {
                                ForEach(Priority.allCases, id: \.self) { p in
                                    Button { newTaskPriority = p } label: {
                                        Label(p.rawValue, systemImage: p.icon)
                                    }
                                }
                            } label: {
                                Image(systemName: newTaskPriority.icon)
                                    .font(.system(size: 12))
                                    .foregroundStyle(newTaskPriority.color)
                            }
                            
                            TextField("New task...", text: $newTaskText)
                                .textFieldStyle(.plain)
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                                .onSubmit { addTask() }
                            
                            Button { addTask() } label: {
                                Text("Add")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(.holoPrimary, in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.03))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Divider().overlay(Color.white.opacity(0.06))
                    
                    // Task list
                    ScrollView {
                        VStack(spacing: 2) {
                            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                HStack(spacing: 10) {
                                    Button {
                                        audio.playSFX(.bubblePop)
                                        withAnimation(.spring(response: 0.3)) {
                                            items[index].done.toggle()
                                        }
                                        HapticManager.shared.lightTap()
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .strokeBorder(item.done ? Color.holoSuccess : item.priority.color.opacity(0.5), lineWidth: 1.5)
                                                .frame(width: 20, height: 20)
                                            
                                            if item.done {
                                                Circle()
                                                    .fill(Color.holoSuccess.opacity(0.2))
                                                    .frame(width: 20, height: 20)
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 9, weight: .bold))
                                                    .foregroundStyle(.holoSuccess)
                                                    .transition(.scale.combined(with: .opacity))
                                            }
                                        }
                                        .scaleEffect(item.done ? 1.1 : 1.0)
                                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: item.done)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    // Priority dot
                                    if !item.done {
                                        Circle()
                                            .fill(item.priority.color)
                                            .frame(width: 5, height: 5)
                                    }
                                    
                                    // Text
                                    Text(item.text)
                                        .font(.system(size: 13))
                                        .foregroundStyle(item.done ? .white.opacity(0.3) : .white.opacity(0.85))
                                        .strikethrough(item.done, color: .white.opacity(0.15))
                                    
                                    Spacer()
                                    
                                    Button {
                                        audio.playSFX(.bubblePop)
                                        withAnimation(.spring(response: 0.3)) {
                                            _ = items.remove(at: index)
                                        }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(.white.opacity(0.15))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(
                                    item.done ? Color.clear : item.priority == .high ? Color.red.opacity(0.03) : .clear,
                                    in: RoundedRectangle(cornerRadius: 6)
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            } else {
                // Spatial Pomodoro Focus View (Radial HSL gradient overlay)
                VStack(spacing: 8) {
                    Spacer(minLength: 4)
                    
                    ZStack {
                        // Background track circle
                        Circle()
                            .strokeBorder(.white.opacity(0.05), lineWidth: 8)
                            .frame(width: 120, height: 120)
                        
                        let progressFraction = Double(timeRemaining) / Double(totalSessionTime)
                        
                        // Sweeping progress ring
                        Circle()
                            .trim(from: 0.0, to: CGFloat(progressFraction))
                            .stroke(
                                LinearGradient(
                                    colors: isWorkSession ? [Color.red, Color.orange] : [Color.holoSuccess, Color.holoSecondary],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.5), value: timeRemaining)
                            .shadow(color: (isWorkSession ? Color.red : Color.holoSuccess).opacity(0.24), radius: 6)
                        
                        // Internal details
                        VStack(spacing: 1) {
                            Text(timeString(timeRemaining))
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)
                            
                            Text(isWorkSession ? "FOCUS" : "REST")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundStyle((isWorkSession ? Color.orange : Color.holoSuccess).opacity(0.8))
                                .tracking(1.5)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Mechanical visual feedback string
                    Text(isWorkSession ? "Keep flowing. Your environment is study-optimized." : "Take a breather. Let your mind recharge.")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .frame(height: 24)
                    
                    // Controls
                    HStack(spacing: 12) {
                        Button {
                            isTimerRunning.toggle()
                            audio.playSFX(.softTick)
                            HapticManager.shared.lightTap()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                                Text(isTimerRunning ? "Pause" : "Start")
                            }
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(isTimerRunning ? Color.orange.opacity(0.2) : Color.holoPrimary.opacity(0.2), in: Capsule())
                            .overlay(Capsule().strokeBorder(.white.opacity(0.12), lineWidth: 0.5))
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            isTimerRunning = false
                            timeRemaining = isWorkSession ? 1500 : 300
                            totalSessionTime = timeRemaining
                            audio.playSFX(.softTick)
                            HapticManager.shared.lightTap()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise")
                                Text("Reset")
                            }
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.04), in: Capsule())
                            .overlay(Capsule().strokeBorder(.white.opacity(0.08), lineWidth: 0.5))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer(minLength: 4)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        // Autoconnected 1Hz clock publisher for Todo focus timer
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard isTimerRunning else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
                // Play a mechanical soft tick every 5 seconds for immersive flow
                if timeRemaining % 5 == 0 {
                    audio.playSFX(.softTick)
                }
            } else {
                // Session completed! Toggle work/break session
                isTimerRunning = false
                isWorkSession.toggle()
                timeRemaining = isWorkSession ? 1500 : 300
                totalSessionTime = timeRemaining
                audio.playSFX(.success)
                HapticManager.shared.mediumTap()
            }
        }
    }
    
    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    private func addTask() {
        guard !newTaskText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        audio.playSFX(.success)
        withAnimation(.spring(response: 0.3)) {
            items.insert(TodoItem(text: newTaskText, done: false, priority: newTaskPriority), at: 0)
            newTaskText = ""
        }
        HapticManager.shared.lightTap()
    }
}
