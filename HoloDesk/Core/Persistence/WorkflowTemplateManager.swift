// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Workflow Templates

/// Pre-built workspace templates for common tasks with auto-window spawning.
@Observable
final class WorkflowTemplateManager {
    
    struct WorkflowTemplate: Identifiable {
        let id = UUID()
        var name: String
        var emoji: String
        var description: String
        var windows: [WindowType]
        var suggestedMode: WorkspaceMode
        var color: Color
        var layout: WindowSnapSystem.SnapLayout
    }
    
    let templates: [WorkflowTemplate] = [
        WorkflowTemplate(
            name: "Deep Work",
            emoji: "🧠",
            description: "Distraction-free focus session with notes, todo, and Pomodoro timer",
            windows: [.notes, .todo, .music, .ambienceMixer],
            suggestedMode: .study,
            color: .purple,
            layout: .leftRight
        ),
        WorkflowTemplate(
            name: "Design Review",
            emoji: "🎨",
            description: "Visual workspace for reviewing designs and collecting feedback",
            windows: [.whiteboard, .photos, .browser, .kanban],
            suggestedMode: .work,
            color: .pink,
            layout: .grid
        ),
        WorkflowTemplate(
            name: "Coding Session",
            emoji: "💻",
            description: "Full dev environment with code, terminal, and docs",
            windows: [.codeEditor, .terminal, .browser, .spotify],
            suggestedMode: .work,
            color: .cyan,
            layout: .leftRight
        ),
        WorkflowTemplate(
            name: "Meeting Prep",
            emoji: "📋",
            description: "Organize agenda, notes, and calendar before your meeting",
            windows: [.calendar, .notes, .todo, .messages],
            suggestedMode: .work,
            color: .blue,
            layout: .grid
        ),
        WorkflowTemplate(
            name: "Brainstorm",
            emoji: "💡",
            description: "Creative ideation with mind map, whiteboard, and inspiration",
            windows: [.mindMap, .whiteboard, .notes, .photos],
            suggestedMode: .work,
            color: .orange,
            layout: .arc
        ),
        WorkflowTemplate(
            name: "Content Creation",
            emoji: "🎬",
            description: "Video editing workspace with media, notes, and music",
            windows: [.video, .photos, .spotify, .notes],
            suggestedMode: .cinema,
            color: .red,
            layout: .leftRight
        ),
        WorkflowTemplate(
            name: "Relax & Recharge",
            emoji: "🧘",
            description: "Wind down with meditation, ambient sounds, and music",
            windows: [.meditation, .ambienceMixer, .spotify, .visualizer],
            suggestedMode: .cinema,
            color: .green,
            layout: .arc
        ),
        WorkflowTemplate(
            name: "Morning Routine",
            emoji: "☀️",
            description: "Start your day with weather, calendar, news, and music",
            windows: [.weather, .calendar, .todo, .music, .messages],
            suggestedMode: .work,
            color: .yellow,
            layout: .arc
        ),
    ]
    
    @MainActor
    func applyTemplate(_ template: WorkflowTemplate, to store: WorkspaceStore) async {
        // Clear current windows
        store.activeWindows.removeAll()
        store.currentMode = template.suggestedMode
        
        // Spawn windows in layout
        let positions = WindowSnapSystem.positions(for: template.layout, windowCount: template.windows.count)
        
        for (i, windowType) in template.windows.enumerated() {
            let position = i < positions.count ? positions[i] : SIMD3(Float(i) * 0.5 - 0.5, 1.4, -1.8)
            let window = SpatialWindow(type: windowType, position: position, zIndex: i)
            store.activeWindows.append(window)
            try? await Task.sleep(for: .milliseconds(100))
        }
        
        HapticManager.shared.success()
    }
}

// MARK: - Workflow Template Picker View

struct WorkflowTemplatePickerView: View {
    @Bindable var manager: WorkflowTemplateManager
    @Environment(WorkspaceStore.self) private var store
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "sparkle.magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundStyle(.yellow)
                Text("Workflow Templates")
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
            
            Text("One-tap workspace setups for common tasks")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.4))
            
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(manager.templates) { template in
                        templateCard(template)
                    }
                }
            }
            .frame(maxHeight: 350)
        }
        .padding(20)
        .frame(width: 400)
        .glassBackground(cornerRadius: 24)
    }
    
    private func templateCard(_ template: WorkflowTemplateManager.WorkflowTemplate) -> some View {
        Button {
            Task {
                await manager.applyTemplate(template, to: store)
                isPresented = false
            }
        } label: {
            HStack(spacing: 12) {
                Text(template.emoji)
                    .font(.system(size: 24))
                    .frame(width: 44, height: 44)
                    .background(template.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(template.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                    Text(template.description)
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.4))
                        .lineLimit(2)
                    
                    // Window icons
                    HStack(spacing: 4) {
                        ForEach(template.windows, id: \.self) { type in
                            Image(systemName: type.iconName)
                                .font(.system(size: 8))
                                .foregroundStyle(Color.windowAccent(for: type))
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(template.color.opacity(0.5))
            }
            .padding(10)
            .innerGlass(cornerRadius: 12)
        }
        .buttonStyle(.plain)
    }
}
