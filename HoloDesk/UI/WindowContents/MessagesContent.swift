// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Messages Window Content

/// Rich chat interface mimicking iMessage with contact sidebar.
struct MessagesContent: View {
    
    private let messages: [(sender: String, text: String, isMe: Bool, time: String)] = [
        ("Alex", "Hey, how's the report coming along?", false, "2:34 PM"),
        ("Me", "Just finishing up the last section now.", true, "2:35 PM"),
        ("Alex", "Can you send over the graphs?", false, "2:36 PM"),
        ("Me", "On it, sending now. 📊", true, "2:36 PM"),
    ]
    
    private let contacts: [(name: String, icon: String, color: Color)] = [
        ("Safari", "safari", .blue),
        ("Music", "music.note", .pink),
        ("Mail", "envelope.fill", .blue),
        ("Messages", "message.fill", .green),
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            // Contact sidebar
            contactSidebar
            
            // Chat area
            chatArea
        }
    }
    
    // MARK: - Contact Sidebar
    
    private var contactSidebar: some View {
        VStack(spacing: 12) {
            ForEach(contacts, id: \.name) { contact in
                Image(systemName: contact.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(contact.color)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(.black.opacity(0.15))
    }
    
    // MARK: - Chat Area
    
    private var chatArea: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Messages")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            
            Divider().overlay(Color.white.opacity(0.08))
            
            // Messages
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(Array(messages.enumerated()), id: \.offset) { _, message in
                        messageBubble(message)
                    }
                    
                    // Attachment
                    HStack {
                        Spacer()
                        attachmentView
                    }
                    .padding(.horizontal, 14)
                }
                .padding(.vertical, 10)
            }
        }
    }
    
    // MARK: - Message Bubble
    
    private func messageBubble(_ message: (sender: String, text: String, isMe: Bool, time: String)) -> some View {
        HStack {
            if message.isMe { Spacer(minLength: 40) }
            
            VStack(alignment: message.isMe ? .trailing : .leading, spacing: 3) {
                Text(message.text)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        message.isMe ? Color.messageSent : Color.messageReceived,
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                
                Text(message.time)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.35))
                    .padding(.horizontal, 4)
            }
            
            if !message.isMe { Spacer(minLength: 40) }
        }
        .padding(.horizontal, 14)
    }
    
    // MARK: - Attachment
    
    private var attachmentView: some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 16))
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 1) {
                Text("Q4_Charts.pptx")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white)
                Text("Preview")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(10)
        .innerGlass(cornerRadius: 12)
    }
}
