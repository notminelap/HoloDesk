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
    
    var body: some View {
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
            .padding(.top, 10)
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
                                    items.remove(at: index)
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
