// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Room Selector View

/// Room selector — lets users switch between room-specific workspace setups.
struct RoomSelectorView: View {
    
    @Bindable var roomManager: RoomManager
    @State private var showAddRoom = false
    @State private var newRoomName = ""
    @State private var newRoomEmoji = "🏠"
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "building.2")
                    .font(.system(size: 14))
                    .foregroundStyle(.holoSecondary)
                
                Text("Rooms")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button {
                    showAddRoom = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.holoPrimary)
                }
                .buttonStyle(.plain)
            }
            
            // Room list
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(roomManager.rooms) { room in
                        roomCard(room)
                    }
                }
            }
        }
        .padding(14)
        .glassBackground(cornerRadius: 18)
        .alert("Add Room", isPresented: $showAddRoom) {
            TextField("Room name", text: $newRoomName)
            Button("Add") {
                guard !newRoomName.isEmpty else { return }
                roomManager.addRoom(name: newRoomName, emoji: newRoomEmoji, defaultMode: .work)
                newRoomName = ""
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func roomCard(_ room: RoomManager.Room) -> some View {
        let isActive = roomManager.activeRoomId == room.id
        
        return Button {
            withAnimation(.spatialInteract) {
                roomManager.selectRoom(room.id)
            }
        } label: {
            VStack(spacing: 6) {
                Text(room.emoji)
                    .font(.system(size: 22))
                
                Text(room.name)
                    .font(.system(size: 10, weight: isActive ? .bold : .medium))
                    .foregroundStyle(.white.opacity(isActive ? 1 : 0.6))
                    .lineLimit(1)
            }
            .frame(width: 70, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? Color.holoPrimary.opacity(0.25) : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isActive ? Color.holoPrimary.opacity(0.5) : .white.opacity(0.08),
                                lineWidth: isActive ? 1 : 0.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
