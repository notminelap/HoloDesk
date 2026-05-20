// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Kanban Board Content

/// Interactive Kanban board with draggable cards between columns.
struct KanbanContent: View {
    
    @State private var columns: [KanbanColumn] = KanbanColumn.defaults
    @State private var newCardText = ""
    @State private var addingToColumn: Int?
    
    struct KanbanColumn: Identifiable {
        let id = UUID()
        var title: String
        var emoji: String
        var color: Color
        var cards: [KanbanCard]
        
        static var defaults: [KanbanColumn] {
            [
                KanbanColumn(title: "To Do", emoji: "📋", color: .blue, cards: [
                    KanbanCard(text: "Design landing page", tag: .design, priority: .high),
                    KanbanCard(text: "Write API docs", tag: .docs, priority: .medium),
                    KanbanCard(text: "Setup CI/CD pipeline", tag: .engineering, priority: .low),
                ]),
                KanbanColumn(title: "In Progress", emoji: "🔨", color: .orange, cards: [
                    KanbanCard(text: "Implement auth flow", tag: .engineering, priority: .high),
                    KanbanCard(text: "User testing session", tag: .design, priority: .medium),
                ]),
                KanbanColumn(title: "Review", emoji: "👀", color: .purple, cards: [
                    KanbanCard(text: "PR #142 — dark mode", tag: .engineering, priority: .low),
                ]),
                KanbanColumn(title: "Done", emoji: "✅", color: .green, cards: [
                    KanbanCard(text: "Onboarding redesign", tag: .design, priority: .medium),
                    KanbanCard(text: "Fix memory leak", tag: .engineering, priority: .high),
                ]),
            ]
        }
    }
    
    struct KanbanCard: Identifiable {
        let id = UUID()
        var text: String
        var tag: Tag
        var priority: Priority
        
        enum Tag: String, CaseIterable {
            case engineering = "Eng"
            case design = "Design"
            case docs = "Docs"
            case bug = "Bug"
            
            var color: Color {
                switch self {
                case .engineering: return .blue
                case .design:      return .pink
                case .docs:        return .cyan
                case .bug:         return .red
                }
            }
        }
        
        enum Priority: String {
            case high = "🔴"
            case medium = "🟡"
            case low = "🟢"
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 10) {
                ForEach(Array(columns.enumerated()), id: \.element.id) { colIndex, column in
                    columnView(column, colIndex: colIndex)
                }
            }
            .padding(12)
        }
    }
    
    private func columnView(_ column: KanbanColumn, colIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(column.emoji)
                    .font(.system(size: 14))
                Text(column.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(column.cards.count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.white.opacity(0.08), in: Capsule())
            }
            
            // Cards
            ForEach(Array(column.cards.enumerated()), id: \.element.id) { cardIndex, card in
                cardView(card, colIndex: colIndex, cardIndex: cardIndex)
            }
            
            // Add card
            if addingToColumn == colIndex {
                HStack(spacing: 4) {
                    TextField("Card title...", text: $newCardText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 11))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .innerGlass(cornerRadius: 6)
                    
                    Button {
                        if !newCardText.isEmpty {
                            columns[colIndex].cards.append(KanbanCard(text: newCardText, tag: .engineering, priority: .medium))
                            newCardText = ""
                            addingToColumn = nil
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.green)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Button {
                    addingToColumn = colIndex
                } label: {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 10))
                        Text("Add card")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(.white.opacity(0.3))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .frame(width: 180)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(column.color.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(column.color.opacity(0.1), lineWidth: 0.5)
                )
        )
    }
    
    private func cardView(_ card: KanbanCard, colIndex: Int, cardIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(card.text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(2)
            
            HStack {
                Text(card.tag.rawValue)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(card.tag.color)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(card.tag.color.opacity(0.15), in: Capsule())
                
                Spacer()
                
                Text(card.priority.rawValue)
                    .font(.system(size: 8))
                
                // Move buttons
                if colIndex < columns.count - 1 {
                    Button {
                        let moved = columns[colIndex].cards.remove(at: cardIndex)
                        columns[colIndex + 1].cards.append(moved)
                        HapticManager.shared.lightTap()
                    } label: {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(8)
        .innerGlass(cornerRadius: 8)
    }
}
