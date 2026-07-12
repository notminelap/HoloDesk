// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Workspace Timeline Manager

/// Tracks workspace history — undo/redo and session timeline.
@MainActor @Observable
final class WorkspaceTimelineManager {
    var history: [WorkspaceSnapshot] = []
    var currentIndex: Int = -1
    var maxHistory: Int = 50
    
    struct WorkspaceSnapshot: Identifiable {
        let id = UUID()
        var timestamp: Date
        var mode: WorkspaceMode
        var windowCount: Int
        var action: String  // "Mode switch", "Window added", "Layout saved", etc.
        var windows: [SpatialWindow]
    }
    
    var canUndo: Bool { currentIndex > 0 }
    var canRedo: Bool { currentIndex < history.count - 1 }
    
    func snapshot(mode: WorkspaceMode, windows: [SpatialWindow], action: String) {
        // Remove future history if we're not at the end
        if currentIndex < history.count - 1 {
            history = Array(history.prefix(currentIndex + 1))
        }
        
        // Deep copy the windows to prevent state mutation in snapshots
        let clonedWindows = windows.map { window in
            SpatialWindow(
                id: window.id,
                type: window.type,
                position: window.position,
                rotation: window.rotation,
                size: window.size,
                isVisible: window.isVisible,
                zIndex: window.zIndex
            )
        }
        
        let snap = WorkspaceSnapshot(
            timestamp: Date(),
            mode: mode,
            windowCount: windows.count,
            action: action,
            windows: clonedWindows
        )
        history.append(snap)
        
        // Trim to max
        if history.count > maxHistory {
            history.removeFirst()
        }
        currentIndex = history.count - 1
    }
    
    func undo() -> WorkspaceSnapshot? {
        guard canUndo else { return nil }
        currentIndex -= 1
        HapticManager.shared.lightTap()
        return history[currentIndex]
    }
    
    func redo() -> WorkspaceSnapshot? {
        guard canRedo else { return nil }
        currentIndex += 1
        HapticManager.shared.lightTap()
        return history[currentIndex]
    }
}

// MARK: - Timeline View

struct WorkspaceTimelineView: View {
    @Bindable var timeline: WorkspaceTimelineManager
    @Environment(WorkspaceStore.self) private var store
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.holoSecondary)
                Text("Timeline")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                // Undo / Redo
                HStack(spacing: 6) {
                    Button {
                        if let snap = timeline.undo() {
                            store.activeWindows = snap.windows.map { window in
                                SpatialWindow(
                                    id: window.id,
                                    type: window.type,
                                    position: window.position,
                                    rotation: window.rotation,
                                    size: window.size,
                                    isVisible: window.isVisible,
                                    zIndex: window.zIndex
                                )
                            }
                            store.currentMode = snap.mode
                        }
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 12))
                            .foregroundStyle(timeline.canUndo ? .white : .white.opacity(0.2))
                    }
                    .buttonStyle(.plain)
                    .disabled(!timeline.canUndo)
                    
                    Button {
                        if let snap = timeline.redo() {
                            store.activeWindows = snap.windows.map { window in
                                SpatialWindow(
                                    id: window.id,
                                    type: window.type,
                                    position: window.position,
                                    rotation: window.rotation,
                                    size: window.size,
                                    isVisible: window.isVisible,
                                    zIndex: window.zIndex
                                )
                            }
                            store.currentMode = snap.mode
                        }
                    } label: {
                        Image(systemName: "arrow.uturn.forward")
                            .font(.system(size: 12))
                            .foregroundStyle(timeline.canRedo ? .white : .white.opacity(0.2))
                    }
                    .buttonStyle(.plain)
                    .disabled(!timeline.canRedo)
                }
                
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
            
            if timeline.history.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.2))
                    Text("No history yet")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.vertical, 30)
            } else {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(Array(timeline.history.enumerated().reversed()), id: \.element.id) { index, snap in
                            timelineEntry(snap, index: index)
                        }
                    }
                }
                .frame(maxHeight: 250)
            }
        }
        .padding(20)
        .frame(width: 360)
        .glassBackground(cornerRadius: 24)
    }
    
    private func timelineEntry(_ snap: WorkspaceTimelineManager.WorkspaceSnapshot, index: Int) -> some View {
        let isCurrent = index == timeline.currentIndex
        
        return HStack(spacing: 10) {
            // Timeline dot + line
            VStack(spacing: 0) {
                Circle()
                    .fill(isCurrent ? Color.holoPrimary : .white.opacity(0.2))
                    .frame(width: 8, height: 8)
                if index > 0 {
                    Rectangle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 1, height: 20)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(snap.action)
                    .font(.system(size: 12, weight: isCurrent ? .semibold : .regular))
                    .foregroundStyle(.white.opacity(isCurrent ? 1 : 0.6))
                
                HStack(spacing: 8) {
                    Text(snap.mode.emoji + " " + snap.mode.displayName)
                        .font(.system(size: 9))
                        .foregroundStyle(Color.modeTint(for: snap.mode).opacity(0.7))
                    
                    Text("\(snap.windowCount) windows")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.3))
                    
                    Text(snap.timestamp, style: .time)
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            
            Spacer()
            
            // Restore button
            if !isCurrent {
                Button {
                    timeline.currentIndex = index
                    store.activeWindows = snap.windows.map { window in
                        SpatialWindow(
                            id: window.id,
                            type: window.type,
                            position: window.position,
                            rotation: window.rotation,
                            size: window.size,
                            isVisible: window.isVisible,
                            zIndex: window.zIndex
                        )
                    }
                    store.currentMode = snap.mode
                    HapticManager.shared.mediumTap()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.holoPrimary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
    }
}
