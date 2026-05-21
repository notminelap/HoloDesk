// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Mail / Email Content

/// Full email client — inbox, compose, folders, read view.
struct MailContent: View {
    
    @State private var selectedEmail: Int? = 0
    @State private var isComposing = false
    @State private var selectedFolder = "Inbox"
    
    private let folders: [(name: String, icon: String, count: Int)] = [
        ("Inbox", "tray.fill", 12),
        ("Starred", "star.fill", 3),
        ("Sent", "paperplane.fill", 0),
        ("Drafts", "doc.text", 1),
        ("Archive", "archivebox", 0),
        ("Trash", "trash", 0),
    ]
    
    private let emails: [(from: String, initials: String, subject: String, preview: String, time: String, isRead: Bool, isStarred: Bool, color: Color)] = [
        ("Tim Cook", "TC", "Vision Pro Developer Preview", "Hi team, I'm excited to announce the next phase of our spatial computing...", "10:24 AM", false, true, .blue),
        ("App Review", "AR", "Your app has been approved", "Congratulations! HoloDesk has been approved for the App Store...", "9:15 AM", false, false, .green),
        ("GitHub", "GH", "[HoloDesk] PR #47 merged", "The pull request 'Add spatial audio manager' has been merged into main...", "8:42 AM", true, false, .purple),
        ("Figma", "Fi", "Sarah shared 'HoloDesk UI Kit'", "Sarah Kim shared a new design file with you. Click to open in Figma...", "Yesterday", true, false, .orange),
        ("Apple Developer", "AD", "WWDC25 Invitation", "You're invited to Apple's Worldwide Developer Conference 2025...", "Yesterday", false, true, .red),
        ("Jira", "Ji", "Sprint 14 starts tomorrow", "5 stories assigned to you for the upcoming sprint. Review your tasks...", "2 days ago", true, false, .blue),
        ("Slack", "Sl", "3 new messages in #holodesk", "Alex: Has anyone tested the hand tracking on device? | Sarah: Yes...", "2 days ago", true, false, .pink),
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: 2) {
                ForEach(Array(folders.enumerated()), id: \.offset) { _, folder in
                    Button {
                        selectedFolder = folder.name
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: folder.icon)
                                .font(.system(size: 10))
                                .foregroundStyle(selectedFolder == folder.name ? .blue : .white.opacity(0.4))
                                .frame(width: 16)
                            Text(folder.name)
                                .font(.system(size: 10, weight: selectedFolder == folder.name ? .bold : .regular))
                                .foregroundStyle(selectedFolder == folder.name ? .white : .white.opacity(0.5))
                            Spacer()
                            if folder.count > 0 {
                                Text("\(folder.count)")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(selectedFolder == folder.name ? Color.blue.opacity(0.1) : .clear, in: RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Button { isComposing = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.pencil")
                        Text("Compose")
                    }
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(.blue.opacity(0.4), in: RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
            .padding(8)
            .frame(width: 100)
            .background(.white.opacity(0.02))
            
            Divider().overlay(Color.white.opacity(0.04))
            
            // Email list
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(emails.enumerated()), id: \.offset) { index, email in
                        Button { selectedEmail = index } label: {
                            HStack(spacing: 8) {
                                // Avatar
                                ZStack {
                                    Circle()
                                        .fill(email.color.opacity(0.3))
                                        .frame(width: 28, height: 28)
                                    Text(email.initials)
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(email.from)
                                            .font(.system(size: 10, weight: email.isRead ? .regular : .bold))
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Text(email.time)
                                            .font(.system(size: 7))
                                            .foregroundStyle(.white.opacity(0.3))
                                    }
                                    Text(email.subject)
                                        .font(.system(size: 9, weight: email.isRead ? .regular : .semibold))
                                        .foregroundStyle(.white.opacity(email.isRead ? 0.6 : 0.9))
                                        .lineLimit(1)
                                    Text(email.preview)
                                        .font(.system(size: 8))
                                        .foregroundStyle(.white.opacity(0.3))
                                        .lineLimit(1)
                                }
                                
                                if email.isStarred {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 8))
                                        .foregroundStyle(.yellow)
                                }
                                
                                if !email.isRead {
                                    Circle()
                                        .fill(.blue)
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(selectedEmail == index ? Color.blue.opacity(0.08) : .clear)
                        }
                        .buttonStyle(.plain)
                        
                        if index < emails.count - 1 {
                            Divider().overlay(Color.white.opacity(0.03)).padding(.leading, 46)
                        }
                    }
                }
            }
        }
    }
}
