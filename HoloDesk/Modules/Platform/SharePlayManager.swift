// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import GroupActivities
import Observation

// MARK: - SharePlay Manager

/// SharePlay integration — share your spatial workspace with others.
@MainActor @Observable
final class SharePlayManager {
    var isSharing = false
    var participants: [Participant] = []
    var sharedWorkspace: Workspace?
    
    struct Participant: Identifiable {
        let id = UUID()
        var name: String
        var avatar: String  // SF Symbol
        var color: Color
        var isHost: Bool
    }
    
    struct SharedWorkspaceActivity: GroupActivity {
        var metadata: GroupActivityMetadata {
            var meta = GroupActivityMetadata()
            meta.title = "HoloDesk Workspace"
            meta.subtitle = "Collaborate in spatial computing"
            meta.type = .generic
            return meta
        }
    }
    
    @MainActor
    func startSharing(workspace: Workspace) {
        isSharing = true
        sharedWorkspace = workspace
        
        // Add demo participants
        participants = [
            Participant(name: "You", avatar: "person.fill", color: .holoPrimary, isHost: true),
            Participant(name: "Alex", avatar: "person.fill", color: .orange, isHost: false),
        ]
        
        HapticManager.shared.success()
    }
    
    func stopSharing() {
        isSharing = false
        participants.removeAll()
        sharedWorkspace = nil
    }
    
    func inviteParticipant(name: String) {
        let colors: [Color] = [.pink, .green, .cyan, .purple, .yellow]
        let participant = Participant(
            name: name,
            avatar: "person.fill",
            color: colors[participants.count % colors.count],
            isHost: false
        )
        participants.append(participant)
    }
}

// MARK: - SharePlay View

struct SharePlayView: View {
    @Bindable var manager: SharePlayManager
    @Environment(WorkspaceStore.self) private var store
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.cyan)
                Text("SharePlay")
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
            
            if manager.isSharing {
                // Active session
                VStack(spacing: 10) {
                    HStack {
                        Circle().fill(.green).frame(width: 8, height: 8)
                        Text("Session Active")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.green)
                        Spacer()
                        Text("\(manager.participants.count) people")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    
                    // Participants
                    ForEach(manager.participants) { p in
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(p.color.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                Image(systemName: p.avatar)
                                    .font(.system(size: 14))
                                    .foregroundStyle(p.color)
                            }
                            
                            Text(p.name)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white)
                            
                            if p.isHost {
                                Text("Host")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.cyan)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .innerGlass(cornerRadius: 6)
                            }
                            
                            Spacer()
                        }
                        .padding(6)
                        .innerGlass(cornerRadius: 10)
                    }
                    
                    Button {
                        manager.stopSharing()
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle")
                            Text("End Session")
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .innerGlass(cornerRadius: 12)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                // Start sharing
                VStack(spacing: 12) {
                    Image(systemName: "shareplay")
                        .font(.system(size: 36))
                        .foregroundStyle(.cyan)
                    
                    Text("Share your workspace")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Text("Collaborate with others in real-time spatial computing")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                    
                    Button {
                        let workspace = Workspace(name: "Shared", mode: .work, windows: [])
                        manager.startSharing(workspace: workspace)
                    } label: {
                        HStack {
                            Image(systemName: "shareplay")
                            Text("Start SharePlay")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(.cyan.gradient, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 10)
            }
        }
        .padding(20)
        .frame(width: 340)
        .glassBackground(cornerRadius: 24)
    }
}
