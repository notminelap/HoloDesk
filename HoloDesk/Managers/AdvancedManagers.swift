// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Window Group Manager

/// Allows users to group windows into tabs or collections.
@Observable
final class WindowGroupManager {
    
    var groups: [WindowGroup] = []
    
    struct WindowGroup: Identifiable {
        let id = UUID()
        var name: String
        var emoji: String
        var windowIds: [UUID]
        var color: Color
    }
    
    func createGroup(name: String, emoji: String, windowIds: [UUID], color: Color = .holoPrimary) {
        groups.append(WindowGroup(name: name, emoji: emoji, windowIds: windowIds, color: color))
    }
    
    func addToGroup(groupId: UUID, windowId: UUID) {
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].windowIds.append(windowId)
        }
    }
    
    func removeFromGroup(groupId: UUID, windowId: UUID) {
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].windowIds.removeAll { $0 == windowId }
        }
    }
    
    func deleteGroup(_ id: UUID) {
        groups.removeAll { $0.id == id }
    }
    
    func groupsContaining(windowId: UUID) -> [WindowGroup] {
        groups.filter { $0.windowIds.contains(windowId) }
    }
}

// MARK: - Focus Lock Manager

/// Locks workspace to prevent accidental changes during focus sessions.
@Observable
final class FocusLockManager {
    var isLocked = false
    var lockReason: String?
    var unlockPin: String?
    var autoLockWithPomodoro = true
    
    func lock(reason: String? = nil) {
        isLocked = true
        lockReason = reason
        HapticManager.shared.mediumTap()
    }
    
    func unlock() {
        isLocked = false
        lockReason = nil
        HapticManager.shared.lightTap()
    }
    
    func toggleLock() {
        if isLocked { unlock() }
        else { lock(reason: "Focus session active") }
    }
}

// MARK: - Handoff Manager

/// Manages Apple Handoff — continue workspace on Mac/iPad.
@Observable
final class HandoffManager {
    var isHandoffAvailable = true
    var connectedDevices: [ConnectedDevice] = [
        ConnectedDevice(name: "MacBook Pro", type: .mac, isOnline: true),
        ConnectedDevice(name: "iPad Pro", type: .ipad, isOnline: true),
        ConnectedDevice(name: "iPhone 16 Pro", type: .iphone, isOnline: false),
    ]
    
    struct ConnectedDevice: Identifiable {
        let id = UUID()
        var name: String
        var type: DeviceType
        var isOnline: Bool
        
        enum DeviceType {
            case mac, ipad, iphone
            var icon: String {
                switch self {
                case .mac:    return "macbook"
                case .ipad:   return "ipad"
                case .iphone: return "iphone"
                }
            }
        }
    }
    
    func sendToDevice(_ device: ConnectedDevice) {
        // In production: NSUserActivity handoff
        HapticManager.shared.success()
    }
}

// MARK: - Quick Actions Manager

/// Spotlight-style quick action search — Cmd+K for any workspace action.
@Observable
final class QuickActionsManager {
    
    var isPresented = false
    var searchText = ""
    
    struct QuickAction: Identifiable {
        let id = UUID()
        var title: String
        var subtitle: String
        var icon: String
        var color: Color
        var action: () -> Void
    }
    
    func actions(for store: WorkspaceStore) -> [QuickAction] {
        var results: [QuickAction] = []
        
        // Window spawning
        for type in WindowType.allCases {
            results.append(QuickAction(
                title: "Open \(type.displayName)",
                subtitle: "Add window",
                icon: type.iconName,
                color: Color.windowAccent(for: type),
                action: { store.addWindow(type: type) }
            ))
        }
        
        // Mode switching
        for mode in WorkspaceMode.allCases where mode != .custom {
            results.append(QuickAction(
                title: "Switch to \(mode.displayName)",
                subtitle: "Workspace mode",
                icon: "rectangle.grid.2x2",
                color: Color.modeTint(for: mode),
                action: { store.loadPreset(mode: mode) }
            ))
        }
        
        // Actions
        results.append(QuickAction(title: "Save Workspace", subtitle: "Persistence", icon: "square.and.arrow.down", color: .blue, action: { store.saveCurrentWorkspace() }))
        results.append(QuickAction(title: "Clear All Windows", subtitle: "Reset", icon: "trash", color: .red, action: { store.activeWindows.removeAll() }))
        
        // Filter
        if !searchText.isEmpty {
            results = results.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        return results
    }
}

// MARK: - Quick Actions View (Cmd+K)

struct QuickActionsView: View {
    @Bindable var manager: QuickActionsManager
    @Environment(WorkspaceStore.self) private var store
    
    var body: some View {
        VStack(spacing: 10) {
            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.4))
                TextField("Search actions, windows, modes...", text: $manager.searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                
                Text("⌘K")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 4))
            }
            .padding(12)
            .innerGlass(cornerRadius: 12)
            
            // Results
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(manager.actions(for: store).prefix(10)) { action in
                        Button {
                            action.action()
                            manager.isPresented = false
                            HapticManager.shared.lightTap()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: action.icon)
                                    .font(.system(size: 14))
                                    .foregroundStyle(action.color)
                                    .frame(width: 28)
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(action.title)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.white)
                                    Text(action.subtitle)
                                        .font(.system(size: 9))
                                        .foregroundStyle(.white.opacity(0.3))
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .padding(16)
        .frame(width: 420)
        .glassBackground(cornerRadius: 20)
    }
}
