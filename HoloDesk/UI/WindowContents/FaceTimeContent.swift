// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - FaceTime / Video Call Content

/// Spatial video call window — shows participant personas in spatial space.
struct FaceTimeContent: View {
    
    @State private var isMuted = false
    @State private var isVideoOn = true
    @State private var isCallActive = false
    @State private var callDuration = 0
    @State private var selectedContact: Int = 0
    @State private var isSpatialAudio = true
    @State private var showParticipants = false
    @State private var callTimer: Timer?
    
    private let contacts: [(name: String, initials: String, status: String, color: Color)] = [
        ("Alex Chen", "AC", "Available", .green),
        ("Sarah Kim", "SK", "In a meeting", .orange),
        ("James Wilson", "JW", "Away", .gray),
        ("Maria Lopez", "ML", "Available", .green),
        ("David Park", "DP", "Do Not Disturb", .red),
    ]
    
    private let participants: [(name: String, initials: String, isMuted: Bool)] = [
        ("You", "ME", false),
        ("Alex Chen", "AC", false),
        ("Sarah Kim", "SK", true),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            if isCallActive {
                activeCallView
            } else {
                contactsView
            }
        }
        .onDisappear {
            callTimer?.invalidate()
            callTimer = nil
        }
    }
    
    // MARK: - Contacts View
    
    private var contactsView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "video.fill")
                    .foregroundStyle(.green)
                Text("FaceTime")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.3))
                Text("Search contacts...")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.25))
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
            
            // Contacts list
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(Array(contacts.enumerated()), id: \.offset) { index, contact in
                        HStack(spacing: 12) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [contact.color.opacity(0.6), contact.color.opacity(0.3)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 40, height: 40)
                                Text(contact.initials)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(contact.name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(contact.color)
                                        .frame(width: 6, height: 6)
                                    Text(contact.status)
                                        .font(.system(size: 10))
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                            }
                            
                            Spacer()
                            
                            // Call buttons
                            Button {
                                selectedContact = index
                                startCall()
                            } label: {
                                Image(systemName: "video.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.green)
                                    .frame(width: 32, height: 32)
                                    .background(.green.opacity(0.15), in: Circle())
                            }
                            .buttonStyle(.plain)
                            
                            Button { } label: {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.green)
                                    .frame(width: 32, height: 32)
                                    .background(.green.opacity(0.15), in: Circle())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
    
    // MARK: - Active Call View
    
    private var activeCallView: some View {
        ZStack {
            // Video background
            LinearGradient(
                colors: [
                    Color(hue: 0.6, saturation: 0.2, brightness: 0.15),
                    Color(hue: 0.55, saturation: 0.15, brightness: 0.08)
                ],
                startPoint: .top, endPoint: .bottom
            )
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    // Spatial audio indicator
                    HStack(spacing: 4) {
                        Image(systemName: "spatial")
                            .font(.system(size: 10))
                        Text("Spatial Audio")
                            .font(.system(size: 9))
                    }
                    .foregroundStyle(isSpatialAudio ? .green : .white.opacity(0.3))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .innerGlass(cornerRadius: 6)
                    
                    Spacer()
                    
                    // Duration
                    Text(formatCallDuration(callDuration))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.5))
                    
                    Spacer()
                    
                    // Participants
                    Button { showParticipants.toggle() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2")
                                .font(.system(size: 10))
                            Text("\(participants.count)")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .innerGlass(cornerRadius: 6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                
                Spacer()
                
                // Participant grid
                if showParticipants {
                    HStack(spacing: 8) {
                        ForEach(Array(participants.enumerated()), id: \.offset) { _, p in
                            VStack(spacing: 4) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.white.opacity(0.05))
                                        .frame(width: 80, height: 80)
                                    Text(p.initials)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.5))
                                    if p.isMuted {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Image(systemName: "mic.slash.fill")
                                                    .font(.system(size: 8))
                                                    .foregroundStyle(.red)
                                                    .padding(4)
                                                    .background(.black.opacity(0.5), in: Circle())
                                            }
                                            Spacer()
                                        }
                                        .frame(width: 80, height: 80)
                                    }
                                }
                                Text(p.name)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                    }
                    .padding(.bottom, 12)
                } else {
                    // Main caller
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(contacts[selectedContact].color.opacity(0.3))
                                .frame(width: 80, height: 80)
                            Text(contacts[selectedContact].initials)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        Text(contacts[selectedContact].name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
                
                Spacer()
                
                // Controls
                HStack(spacing: 16) {
                    callControl(icon: isMuted ? "mic.slash.fill" : "mic.fill", label: "Mute", isActive: isMuted) {
                        isMuted.toggle()
                    }
                    callControl(icon: isVideoOn ? "video.fill" : "video.slash.fill", label: "Video", isActive: !isVideoOn) {
                        isVideoOn.toggle()
                    }
                    callControl(icon: "spatial", label: "Spatial", isActive: isSpatialAudio) {
                        isSpatialAudio.toggle()
                    }
                    callControl(icon: "rectangle.inset.filled.and.person.filled", label: "Effects", isActive: false) { }
                    
                    // End call
                    Button {
                        callTimer?.invalidate()
                        callTimer = nil
                        isCallActive = false
                    } label: {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                            .frame(width: 52, height: 40)
                            .background(.red, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 16)
            }
        }
    }
    
    private func callControl(icon: String, label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(isActive ? .white : .white.opacity(0.6))
                    .frame(width: 40, height: 36)
                    .background(isActive ? .white.opacity(0.2) : .white.opacity(0.08), in: Circle())
                Text(label)
                    .font(.system(size: 8))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .buttonStyle(.plain)
    }
    
    private func startCall() {
        isCallActive = true
        callDuration = 0
        callTimer?.invalidate()
        callTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                callDuration += 1
            }
        }
        HapticManager.shared.mediumTap()
    }
    
    private func formatCallDuration(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
