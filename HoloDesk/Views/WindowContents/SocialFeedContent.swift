// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Social Feed Content

/// Twitter/X style social feed with posts, likes, retweets, and compose.
struct SocialFeedContent: View {
    
    @State private var posts: [SocialPost] = SocialPost.defaults
    @State private var composeText = ""
    @State private var showCompose = false
    
    struct SocialPost: Identifiable {
        let id = UUID()
        var author: String
        var handle: String
        var avatar: String
        var content: String
        var time: String
        var likes: Int
        var reposts: Int
        var replies: Int
        var isLiked: Bool
        var color: Color
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Feed")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Button { showCompose.toggle() } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 14))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.black.opacity(0.15))
            
            // Compose
            if showCompose {
                VStack(spacing: 6) {
                    TextEditor(text: $composeText)
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .scrollContentBackground(.hidden)
                        .frame(height: 50)
                        .padding(8)
                        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
                    
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "photo").foregroundStyle(.blue.opacity(0.5))
                            Image(systemName: "face.smiling").foregroundStyle(.yellow.opacity(0.5))
                            Image(systemName: "location").foregroundStyle(.green.opacity(0.5))
                        }
                        .font(.system(size: 12))
                        
                        Spacer()
                        
                        Button {
                            if !composeText.isEmpty {
                                let post = SocialPost(author: "You", handle: "@holodesk_user", avatar: "ME", content: composeText, time: "now", likes: 0, reposts: 0, replies: 0, isLiked: false, color: .holoPrimary)
                                posts.insert(post, at: 0)
                                composeText = ""
                                showCompose = false
                                HapticManager.shared.success()
                            }
                        } label: {
                            Text("Post")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(.blue, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
                .background(.white.opacity(0.02))
            }
            
            // Posts
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
                        postView(post, index: index)
                        Divider().overlay(Color.white.opacity(0.04))
                    }
                }
            }
        }
    }
    
    private func postView(_ post: SocialPost, index: Int) -> some View {
        HStack(alignment: .top, spacing: 8) {
            // Avatar
            ZStack {
                Circle()
                    .fill(post.color.opacity(0.3))
                    .frame(width: 32, height: 32)
                Text(post.avatar)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(post.author)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                    Text(post.handle)
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.3))
                    Text("· \(post.time)")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.3))
                }
                
                Text(post.content)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(4)
                
                // Actions
                HStack(spacing: 16) {
                    actionButton(icon: "bubble.left", count: post.replies) { }
                    actionButton(icon: "arrow.2.squarepath", count: post.reposts) { }
                    actionButton(icon: post.isLiked ? "heart.fill" : "heart", count: post.likes, active: post.isLiked, activeColor: .red) {
                        posts[index].isLiked.toggle()
                        posts[index].likes += posts[index].isLiked ? 1 : -1
                    }
                    actionButton(icon: "square.and.arrow.up", count: 0) { }
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }
    
    private func actionButton(icon: String, count: Int, active: Bool = false, activeColor: Color = .blue, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(active ? activeColor : .white.opacity(0.3))
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

extension SocialFeedContent.SocialPost {
    static var defaults: [SocialFeedContent.SocialPost] {
        [
            .init(author: "Tim Cook", handle: "@tim_cook", avatar: "TC", content: "The future of spatial computing is here. Vision Pro is just the beginning. We can't wait to see what developers build with these incredible tools. 🚀", time: "2h", likes: 4521, reposts: 892, replies: 312, isLiked: true, color: .blue),
            .init(author: "Craig Federighi", handle: "@craig_f", avatar: "CF", content: "SwiftUI for visionOS is incredibly powerful. The way glassmorphism and spatial layouts just work — it's like magic. ✨", time: "4h", likes: 2103, reposts: 456, replies: 189, isLiked: false, color: .purple),
            .init(author: "HoloDesk", handle: "@holodesk_app", avatar: "HD", content: "Just shipped 29 spatial window types! Kanban boards, 3D model viewers, music visualizers, and chess — all floating in your room. What should we add next? 🧊", time: "6h", likes: 892, reposts: 234, replies: 156, isLiked: true, color: .holoPrimary),
            .init(author: "MKBHD", handle: "@MKBHD", avatar: "MK", content: "HoloDesk is the first app that made me feel like I'm living in the future. The workspace memory feature alone is worth it. Full review dropping tomorrow.", time: "8h", likes: 12400, reposts: 3200, replies: 890, isLiked: false, color: .red),
        ]
    }
}
