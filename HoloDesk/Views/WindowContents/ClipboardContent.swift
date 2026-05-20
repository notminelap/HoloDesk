// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Clipboard History Content

/// Spatial clipboard manager — everything you've copied, always available.
struct ClipboardContent: View {
    
    @State private var clips: [ClipItem] = ClipItem.defaults
    @State private var searchText = ""
    @State private var selectedCategory: ClipCategory = .all
    
    enum ClipCategory: String, CaseIterable {
        case all = "All"
        case text = "Text"
        case links = "Links"
        case code = "Code"
        case images = "Images"
    }
    
    struct ClipItem: Identifiable {
        let id = UUID()
        var content: String
        var category: ClipCategory
        var timestamp: Date
        var isPinned: Bool
        
        static var defaults: [ClipItem] {
            [
                ClipItem(content: "HoloDesk — Spatial Workspace for Vision Pro", category: .text, timestamp: Date().addingTimeInterval(-120), isPinned: true),
                ClipItem(content: "https://developer.apple.com/visionos/", category: .links, timestamp: Date().addingTimeInterval(-300), isPinned: false),
                ClipItem(content: "struct ContentView: View { ... }", category: .code, timestamp: Date().addingTimeInterval(-600), isPinned: false),
                ClipItem(content: "The future of spatial computing is here.", category: .text, timestamp: Date().addingTimeInterval(-900), isPinned: false),
                ClipItem(content: "https://github.com/apple/swift", category: .links, timestamp: Date().addingTimeInterval(-1200), isPinned: true),
                ClipItem(content: "func spatialWindow() -> some View { }", category: .code, timestamp: Date().addingTimeInterval(-1800), isPinned: false),
                ClipItem(content: "Remember to test on device!", category: .text, timestamp: Date().addingTimeInterval(-3600), isPinned: false),
            ]
        }
    }
    
    var filteredClips: [ClipItem] {
        var result = clips
        if selectedCategory != .all {
            result = result.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
        return result.sorted { ($0.isPinned ? 0 : 1) < ($1.isPinned ? 0 : 1) }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "clipboard.fill")
                    .foregroundStyle(.indigo)
                Text("Clipboard")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(clips.count) items")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.3))
                Button {
                    clips.removeAll { !$0.isPinned }
                } label: {
                    Text("Clear")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.red.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            
            // Search
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.3))
                TextField("Search clipboard...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 14)
            
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(ClipCategory.allCases, id: \.self) { cat in
                        Button {
                            selectedCategory = cat
                        } label: {
                            Text(cat.rawValue)
                                .font(.system(size: 9, weight: selectedCategory == cat ? .bold : .regular))
                                .foregroundStyle(selectedCategory == cat ? .white : .white.opacity(0.3))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(selectedCategory == cat ? Color.indigo.opacity(0.2) : .clear, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
            }
            
            // Clips
            ScrollView {
                VStack(spacing: 3) {
                    ForEach(Array(filteredClips.enumerated()), id: \.element.id) { _, clip in
                        clipRow(clip)
                    }
                }
                .padding(.horizontal, 14)
            }
        }
    }
    
    private func clipRow(_ clip: ClipItem) -> some View {
        HStack(spacing: 8) {
            // Category icon
            Image(systemName: categoryIcon(clip.category))
                .font(.system(size: 10))
                .foregroundStyle(categoryColor(clip.category))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(clip.content)
                    .font(.system(size: 10, design: clip.category == .code ? .monospaced : .default))
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(2)
                Text(clip.timestamp, style: .relative)
                    .font(.system(size: 7))
                    .foregroundStyle(.white.opacity(0.2))
            }
            
            Spacer()
            
            if clip.isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.yellow.opacity(0.5))
            }
            
            Button { } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .innerGlass(cornerRadius: 6)
    }
    
    private func categoryIcon(_ cat: ClipCategory) -> String {
        switch cat {
        case .all:    return "tray.full"
        case .text:   return "doc.text"
        case .links:  return "link"
        case .code:   return "chevron.left.forwardslash.chevron.right"
        case .images: return "photo"
        }
    }
    
    private func categoryColor(_ cat: ClipCategory) -> Color {
        switch cat {
        case .all:    return .white
        case .text:   return .blue
        case .links:  return .green
        case .code:   return .cyan
        case .images: return .pink
        }
    }
}
