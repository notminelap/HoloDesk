// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Notes Window Content (Interactive)

/// Rich notes editor — multiple notes, color labels, add/delete, formatting toolbar.
struct NotesContent: View {
    
    @State private var notes: [Note] = [
        Note(title: "Design Ideas", body: "• minimalist\n• natural light\n• open space\n• clean lines", color: .orange, isPinned: true),
        Note(title: "Meeting Notes", body: "Discussed Q4 roadmap.\nNext milestone: Jan 15.\nAction items assigned.", color: .blue, isPinned: false),
        Note(title: "Quick Thought", body: "What if windows could snap to surfaces automatically?", color: .purple, isPinned: false),
    ]
    @State private var selectedNote: Int = 0
    @State private var isEditing = false
    @State private var searchText = ""
    
    struct Note: Identifiable {
        let id = UUID()
        var title: String
        var body: String
        var color: Color
        var isPinned: Bool
        var lastEdited: Date = Date()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            notesSidebar
            
            Divider().overlay(Color.white.opacity(0.06))
            
            // Editor
            noteEditor
        }
    }
    
    // MARK: - Sidebar
    
    private var notesSidebar: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Notes")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Button { addNote() } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 12))
                        .foregroundStyle(.yellow)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            
            // Search
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.25))
                Text("Search")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.2))
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 6))
            .padding(.horizontal, 10)
            .padding(.bottom, 6)
            
            // Notes list
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(Array(notes.enumerated()), id: \.offset) { index, note in
                        Button { selectedNote = index } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(note.color)
                                        .frame(width: 6, height: 6)
                                    Text(note.title)
                                        .font(.system(size: 11, weight: selectedNote == index ? .bold : .medium))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                    Spacer()
                                    if note.isPinned {
                                        Image(systemName: "pin.fill")
                                            .font(.system(size: 7))
                                            .foregroundStyle(.yellow.opacity(0.6))
                                    }
                                }
                                Text(note.body)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.white.opacity(0.35))
                                    .lineLimit(2)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(selectedNote == index ? Color.white.opacity(0.06) : .clear, in: RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Count
            Text("\(notes.count) notes")
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.2))
                .padding(.vertical, 6)
        }
        .frame(width: 150)
        .background(.black.opacity(0.08))
    }
    
    // MARK: - Editor
    
    private var noteEditor: some View {
        VStack(alignment: .leading, spacing: 0) {
            if notes.indices.contains(selectedNote) {
                let note = notes[selectedNote]
                
                // Toolbar
                HStack(spacing: 8) {
                    // Color dots
                    ForEach([Color.orange, .blue, .purple, .green, .pink], id: \.self) { color in
                        Button {
                            notes[selectedNote].color = color
                        } label: {
                            Circle()
                                .fill(color)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle().strokeBorder(.white.opacity(note.color == color ? 0.6 : 0.1), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                    
                    // Pin toggle
                    Button {
                        notes[selectedNote].isPinned.toggle()
                    } label: {
                        Image(systemName: note.isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 10))
                            .foregroundStyle(note.isPinned ? .yellow : .white.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                    
                    // Delete
                    Button {
                        if notes.count > 1 {
                            notes.remove(at: selectedNote)
                            selectedNote = max(0, selectedNote - 1)
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 10))
                            .foregroundStyle(.red.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.black.opacity(0.1))
                
                // Title
                TextField("Title", text: $notes[selectedNote].title)
                    .textFieldStyle(.plain)
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.top, 10)
                
                // Edited date
                Text("Last edited: \(note.lastEdited.formatted(date: .abbreviated, time: .shortened))")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.2))
                    .padding(.horizontal, 14)
                    .padding(.top, 2)
                
                Divider()
                    .overlay(Color.white.opacity(0.05))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                
                // Body
                TextEditor(text: $notes[selectedNote].body)
                    .font(.system(size: 13, design: .serif))
                    .foregroundStyle(.white.opacity(0.85))
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 10)
                    .onChange(of: notes[selectedNote].body) { _, _ in
                        notes[selectedNote].lastEdited = Date()
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func addNote() {
        let new = Note(title: "Untitled", body: "", color: [.orange, .blue, .purple, .green, .pink].randomElement()!, isPinned: false)
        notes.insert(new, at: 0)
        selectedNote = 0
        HapticManager.shared.lightTap()
    }
}
