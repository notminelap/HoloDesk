// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import Foundation
import Observation

// MARK: - Room Manager

/// Multi-room memory — different workspace setups per physical room.
/// "Bedroom workspace, Study workspace, Living room cinema."
@Observable
final class RoomManager {
    
    var rooms: [Room] = []
    var activeRoomId: UUID?
    
    var activeRoom: Room? {
        rooms.first { $0.id == activeRoomId }
    }
    
    struct Room: Identifiable, Codable {
        let id: UUID
        var name: String
        var icon: String        // SF Symbol name
        var emoji: String
        var defaultMode: WorkspaceMode
        var savedWorkspaces: [Workspace]
        var spatialFiles: [SpatialFile]
        var lastUsed: Date
        
        init(
            id: UUID = UUID(),
            name: String,
            icon: String = "door.left.hand.open",
            emoji: String = "🏠",
            defaultMode: WorkspaceMode = .work,
            savedWorkspaces: [Workspace] = [],
            spatialFiles: [SpatialFile] = [],
            lastUsed: Date = Date()
        ) {
            self.id = id
            self.name = name
            self.icon = icon
            self.emoji = emoji
            self.defaultMode = defaultMode
            self.savedWorkspaces = savedWorkspaces
            self.spatialFiles = spatialFiles
            self.lastUsed = lastUsed
        }
    }
    
    // MARK: - Init
    
    init() {
        loadRooms()
        if rooms.isEmpty {
            createDefaultRooms()
        }
    }
    
    // MARK: - Room Management
    
    func addRoom(name: String, emoji: String, defaultMode: WorkspaceMode) {
        let room = Room(name: name, emoji: emoji, defaultMode: defaultMode)
        rooms.append(room)
        persistRooms()
    }
    
    func selectRoom(_ roomId: UUID) {
        activeRoomId = roomId
        if let index = rooms.firstIndex(where: { $0.id == roomId }) {
            rooms[index].lastUsed = Date()
        }
        persistRooms()
    }
    
    func saveWorkspaceToRoom(roomId: UUID, workspace: Workspace) {
        guard let index = rooms.firstIndex(where: { $0.id == roomId }) else { return }
        
        if let existingIndex = rooms[index].savedWorkspaces.firstIndex(where: { $0.mode == workspace.mode }) {
            rooms[index].savedWorkspaces[existingIndex] = workspace
        } else {
            rooms[index].savedWorkspaces.append(workspace)
        }
        persistRooms()
    }
    
    func deleteRoom(_ roomId: UUID) {
        rooms.removeAll { $0.id == roomId }
        if activeRoomId == roomId {
            activeRoomId = rooms.first?.id
        }
        persistRooms()
    }
    
    // MARK: - Defaults
    
    private func createDefaultRooms() {
        rooms = [
            Room(name: "Office", icon: "desktopcomputer", emoji: "🏢", defaultMode: .work),
            Room(name: "Bedroom", icon: "bed.double.fill", emoji: "🛏️", defaultMode: .cinema),
            Room(name: "Study", icon: "book.closed.fill", emoji: "📖", defaultMode: .study),
            Room(name: "Living Room", icon: "sofa.fill", emoji: "🛋️", defaultMode: .gaming),
        ]
        activeRoomId = rooms.first?.id
        persistRooms()
    }
    
    // MARK: - Persistence
    
    private var saveURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("holodesk_rooms.json")
    }
    
    private func persistRooms() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(rooms) else { return }
        try? data.write(to: saveURL)
    }
    
    private func loadRooms() {
        guard let data = try? Data(contentsOf: saveURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        rooms = (try? decoder.decode([Room].self, from: data)) ?? []
        activeRoomId = rooms.sorted(by: { $0.lastUsed > $1.lastUsed }).first?.id
    }
}
