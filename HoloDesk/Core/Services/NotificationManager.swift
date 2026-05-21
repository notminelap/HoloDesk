// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Notification Center

/// Spatial notification system — toasts and notification history.
@Observable
final class NotificationManager {
    
    var notifications: [SpatialNotification] = []
    var activeToast: SpatialNotification?
    var unreadCount: Int { notifications.filter { !$0.isRead }.count }
    
    struct SpatialNotification: Identifiable {
        let id = UUID()
        var title: String
        var body: String
        var icon: String
        var color: Color
        var timestamp: Date
        var isRead: Bool = false
        var category: Category
        
        enum Category: String {
            case workspace = "Workspace"
            case system = "System"
            case timer = "Timer"
            case assistant = "Assistant"
            case reminder = "Reminder"
        }
    }
    
    @MainActor
    func send(title: String, body: String, icon: String = "bell.fill", color: Color = .holoPrimary, category: SpatialNotification.Category = .system) {
        let notification = SpatialNotification(
            title: title, body: body, icon: icon, color: color,
            timestamp: Date(), category: category
        )
        notifications.insert(notification, at: 0)
        activeToast = notification
        HapticManager.shared.lightTap()
        
        // Auto-dismiss toast
        Task {
            try? await Task.sleep(for: .seconds(3))
            if activeToast?.id == notification.id {
                activeToast = nil
            }
        }
    }
    
    func markRead(_ id: UUID) {
        if let i = notifications.firstIndex(where: { $0.id == id }) {
            notifications[i].isRead = true
        }
    }
    
    func markAllRead() {
        for i in notifications.indices {
            notifications[i].isRead = true
        }
    }
    
    func clear() {
        notifications.removeAll()
    }
}

// MARK: - Toast View

struct NotificationToastView: View {
    let notification: NotificationManager.SpatialNotification
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: notification.icon)
                .font(.system(size: 16))
                .foregroundStyle(notification.color)
                .frame(width: 32, height: 32)
                .background(notification.color.opacity(0.15), in: Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                Text(notification.body)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(12)
        .frame(width: 300)
        .glassBackground(cornerRadius: 16)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Notification Center View

struct NotificationCenterView: View {
    @Bindable var manager: NotificationManager
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "bell.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.holoWarning)
                
                Text("Notifications")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                if manager.unreadCount > 0 {
                    Text("\(manager.unreadCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.red, in: Capsule())
                }
                
                Spacer()
                
                Button {
                    manager.markAllRead()
                } label: {
                    Text("Read All")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.holoPrimary)
                }
                .buttonStyle(.plain)
                
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
            
            if manager.notifications.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.2))
                    Text("No notifications")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.vertical, 30)
            } else {
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(manager.notifications) { notification in
                            notificationRow(notification)
                        }
                    }
                }
                .frame(maxHeight: 250)
            }
        }
        .padding(18)
        .frame(width: 340)
        .glassBackground(cornerRadius: 24)
    }
    
    private func notificationRow(_ n: NotificationManager.SpatialNotification) -> some View {
        HStack(spacing: 10) {
            Image(systemName: n.icon)
                .font(.system(size: 14))
                .foregroundStyle(n.color)
                .frame(width: 28, height: 28)
                .background(n.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(n.title)
                    .font(.system(size: 12, weight: n.isRead ? .regular : .semibold))
                    .foregroundStyle(.white.opacity(n.isRead ? 0.6 : 1))
                Text(n.body)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.4))
                    .lineLimit(1)
            }
            
            Spacer()
            
            if !n.isRead {
                Circle().fill(.holoPrimary).frame(width: 6, height: 6)
            }
        }
        .padding(8)
        .innerGlass(cornerRadius: 10)
        .onTapGesture { manager.markRead(n.id) }
    }
}
