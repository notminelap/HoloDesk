// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Habit Tracker Content

/// Daily habit tracker with streak rings, check-ins, and weekly overview.
struct HabitTrackerContent: View {
    
    @State private var habits: [Habit] = Habit.defaults
    @State private var selectedDay = Calendar.current.component(.weekday, from: Date()) - 1
    
    struct Habit: Identifiable {
        let id = UUID()
        var name: String
        var emoji: String
        var color: Color
        var streak: Int
        var completedDays: Set<Int>  // 0=Sun .. 6=Sat
        var goal: String
    }
    
    private let dayNames = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 10) {
            // Header
            HStack {
                Text("🔥 Habits")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Text("Week \(Calendar.current.component(.weekOfYear, from: Date()))")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            
            // Week selector
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { day in
                    let isToday = day == Calendar.current.component(.weekday, from: Date()) - 1
                    Button {
                        selectedDay = day
                    } label: {
                        VStack(spacing: 3) {
                            Text(dayNames[day])
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(isToday ? .white : .white.opacity(0.3))
                            Circle()
                                .fill(isToday ? Color.orange : selectedDay == day ? .white.opacity(0.15) : .clear)
                                .frame(width: 6, height: 6)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            selectedDay == day ? Color.white.opacity(0.05) : .clear,
                            in: RoundedRectangle(cornerRadius: 6)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            
            // Habits list
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(Array(habits.enumerated()), id: \.element.id) { index, habit in
                        habitRow(habit, index: index)
                    }
                }
                .padding(.horizontal, 14)
            }
            
            // Overall progress
            HStack(spacing: 16) {
                let completedToday = habits.filter { $0.completedDays.contains(selectedDay) }.count
                VStack(spacing: 2) {
                    Text("\(completedToday)/\(habits.count)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Today")
                        .font(.system(size: 8))
                        .foregroundStyle(.white.opacity(0.3))
                }
                
                // Progress ring
                ZStack {
                    Circle()
                        .strokeBorder(.white.opacity(0.08), lineWidth: 4)
                        .frame(width: 36, height: 36)
                    Circle()
                        .trim(from: 0, to: Double(completedToday) / Double(max(habits.count, 1)))
                        .stroke(.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 36, height: 36)
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(Double(completedToday) / Double(max(habits.count, 1)) * 100))%")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: 2) {
                    Text("\(habits.map(\.streak).max() ?? 0)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.orange)
                    Text("Best Streak")
                        .font(.system(size: 8))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
        }
    }
    
    private func habitRow(_ habit: Habit, index: Int) -> some View {
        let isDone = habit.completedDays.contains(selectedDay)
        
        return HStack(spacing: 10) {
            // Check button
            Button {
                if habits[index].completedDays.contains(selectedDay) {
                    habits[index].completedDays.remove(selectedDay)
                    habits[index].streak = max(0, habits[index].streak - 1)
                } else {
                    habits[index].completedDays.insert(selectedDay)
                    habits[index].streak += 1
                }
                HapticManager.shared.lightTap()
            } label: {
                ZStack {
                    Circle()
                        .fill(isDone ? habit.color : .clear)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle().strokeBorder(isDone ? .clear : habit.color.opacity(0.3), lineWidth: 1.5)
                        )
                    if isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            
            Text(habit.emoji)
                .font(.system(size: 14))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.system(size: 12, weight: isDone ? .bold : .medium))
                    .foregroundStyle(.white.opacity(isDone ? 1 : 0.7))
                    .strikethrough(isDone, color: .white.opacity(0.3))
                Text(habit.goal)
                    .font(.system(size: 8))
                    .foregroundStyle(.white.opacity(0.3))
            }
            
            Spacer()
            
            // Streak
            HStack(spacing: 2) {
                Text("🔥")
                    .font(.system(size: 8))
                Text("\(habit.streak)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.orange)
            }
            
            // Week dots
            HStack(spacing: 2) {
                ForEach(0..<7, id: \.self) { day in
                    Circle()
                        .fill(habit.completedDays.contains(day) ? habit.color : .white.opacity(0.06))
                        .frame(width: 4, height: 4)
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .innerGlass(cornerRadius: 8)
    }
}

extension HabitTrackerContent.Habit {
    static var defaults: [HabitTrackerContent.Habit] {
        [
            .init(name: "Meditate", emoji: "🧘", color: .purple, streak: 12, completedDays: [1, 2, 3, 4], goal: "10 min daily"),
            .init(name: "Exercise", emoji: "💪", color: .red, streak: 8, completedDays: [1, 3, 5], goal: "30 min workout"),
            .init(name: "Read", emoji: "📚", color: .blue, streak: 15, completedDays: [0, 1, 2, 3, 4, 5], goal: "20 pages"),
            .init(name: "Journal", emoji: "📝", color: .yellow, streak: 5, completedDays: [1, 2, 4], goal: "Write 1 page"),
            .init(name: "Drink Water", emoji: "💧", color: .cyan, streak: 20, completedDays: [0, 1, 2, 3, 4, 5, 6], goal: "8 glasses"),
            .init(name: "No Social Media", emoji: "📵", color: .orange, streak: 3, completedDays: [2, 3, 4], goal: "Before noon"),
        ]
    }
}
