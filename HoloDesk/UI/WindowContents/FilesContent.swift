// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Files Window Content (Interactive)

/// Finder-style file browser with sidebar, breadcrumb, file type icons, and selection.
struct FilesContent: View {
    
    @State private var currentPath: [String] = ["HoloDesk"]
    @State private var selectedFile: String?
    @State private var viewMode: ViewMode = .grid
    
    enum ViewMode: String, CaseIterable {
        case grid = "square.grid.2x2"
        case list = "list.bullet"
    }
    
    struct FileItem: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let color: Color
        let size: String
        let isFolder: Bool
        let modified: String
    }
    
    private var currentItems: [FileItem] {
        if currentPath.count == 1 {
            return rootItems
        } else {
            return folderItems
        }
    }
    
    private let rootItems: [FileItem] = [
        FileItem(name: "Sources", icon: "folder.fill", color: .blue, size: "—", isFolder: true, modified: "Today"),
        FileItem(name: "Views", icon: "folder.fill", color: .blue, size: "—", isFolder: true, modified: "Today"),
        FileItem(name: "Managers", icon: "folder.fill", color: .blue, size: "—", isFolder: true, modified: "Today"),
        FileItem(name: "Models", icon: "folder.fill", color: .blue, size: "—", isFolder: true, modified: "Yesterday"),
        FileItem(name: "Extensions", icon: "folder.fill", color: .blue, size: "—", isFolder: true, modified: "Yesterday"),
        FileItem(name: "HoloDeskApp.swift", icon: "swift", color: .orange, size: "8.6 KB", isFolder: false, modified: "Today"),
        FileItem(name: "Package.swift", icon: "swift", color: .orange, size: "1.2 KB", isFolder: false, modified: "May 12"),
        FileItem(name: "README.md", icon: "doc.text", color: .gray, size: "3.4 KB", isFolder: false, modified: "May 20"),
        FileItem(name: "LICENSE", icon: "lock.doc", color: .yellow, size: "1.1 KB", isFolder: false, modified: "May 12"),
        FileItem(name: "Q4_Charts.pptx", icon: "doc.richtext.fill", color: .orange, size: "2.8 MB", isFolder: false, modified: "May 18"),
    ]
    
    private let folderItems: [FileItem] = [
        FileItem(name: "ContentView.swift", icon: "swift", color: .orange, size: "15.7 KB", isFolder: false, modified: "Today"),
        FileItem(name: "OnboardingView.swift", icon: "swift", color: .orange, size: "9.8 KB", isFolder: false, modified: "Today"),
        FileItem(name: "DockView.swift", icon: "swift", color: .orange, size: "11.4 KB", isFolder: false, modified: "Today"),
        FileItem(name: "AIBuddyView.swift", icon: "swift", color: .orange, size: "15.8 KB", isFolder: false, modified: "Today"),
        FileItem(name: "SplashView.swift", icon: "swift", color: .orange, size: "5.2 KB", isFolder: false, modified: "May 20"),
        FileItem(name: "SettingsView.swift", icon: "swift", color: .orange, size: "7.4 KB", isFolder: false, modified: "Today"),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 8) {
                // Back button
                Button {
                    if currentPath.count > 1 {
                        withAnimation(.spring(response: 0.25)) { _ = currentPath.removeLast() }
                        selectedFile = nil
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(currentPath.count > 1 ? .white.opacity(0.6) : .white.opacity(0.15))
                }
                .buttonStyle(.plain)
                .disabled(currentPath.count <= 1)
                
                // Breadcrumb
                HStack(spacing: 4) {
                    ForEach(Array(currentPath.enumerated()), id: \.offset) { i, name in
                        if i > 0 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 7))
                                .foregroundStyle(.white.opacity(0.2))
                        }
                        Text(name)
                            .font(.system(size: 10, weight: i == currentPath.count - 1 ? .bold : .medium))
                            .foregroundStyle(i == currentPath.count - 1 ? .white : .white.opacity(0.4))
                    }
                }
                
                Spacer()
                
                // View mode toggle
                ForEach(ViewMode.allCases, id: \.rawValue) { mode in
                    Button { viewMode = mode } label: {
                        Image(systemName: mode.rawValue)
                            .font(.system(size: 10))
                            .foregroundStyle(viewMode == mode ? .white : .white.opacity(0.25))
                    }
                    .buttonStyle(.plain)
                }
                
                Text("\(currentItems.count) items")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.25))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.black.opacity(0.15))
            
            Divider().overlay(Color.white.opacity(0.06))
            
            // Content
            ScrollView {
                if viewMode == .grid {
                    gridView
                } else {
                    listView
                }
            }
        }
    }
    
    // MARK: - Grid View
    
    private var gridView: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 8)], spacing: 8) {
            ForEach(currentItems) { item in
                Button {
                    if item.isFolder {
                        withAnimation(.spring(response: 0.25)) { currentPath.append(item.name) }
                        selectedFile = nil
                    } else {
                        selectedFile = item.name
                    }
                    HapticManager.shared.lightTap()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: item.icon)
                            .font(.system(size: 26))
                            .foregroundStyle(item.color)
                        Text(item.name)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(0.75))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 70, height: 68)
                    .innerGlass(cornerRadius: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(selectedFile == item.name ? Color.holoPrimary.opacity(0.5) : .clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
    }
    
    // MARK: - List View
    
    private var listView: some View {
        VStack(spacing: 0) {
            ForEach(currentItems) { item in
                Button {
                    if item.isFolder {
                        withAnimation(.spring(response: 0.25)) { currentPath.append(item.name) }
                    } else {
                        selectedFile = item.name
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: item.icon)
                            .font(.system(size: 14))
                            .foregroundStyle(item.color)
                            .frame(width: 22)
                        
                        Text(item.name)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text(item.size)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.25))
                        
                        Text(item.modified)
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.2))
                            .frame(width: 55, alignment: .trailing)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(selectedFile == item.name ? Color.holoPrimary.opacity(0.1) : .clear)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
