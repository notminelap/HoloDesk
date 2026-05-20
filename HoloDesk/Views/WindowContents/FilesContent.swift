// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Files Window Content

/// Spatial file browser with folder icons and file items.
struct FilesContent: View {
    
    private let folders: [(name: String, icon: String)] = [
        ("Work", "folder.fill"),
        ("Projects", "folder.fill"),
        ("Resources", "folder.fill"),
    ]
    
    private let files: [(name: String, icon: String, color: Color)] = [
        ("Q4_Charts.pptx", "doc.richtext.fill", .orange),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Files")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            
            // Folders row
            HStack(spacing: 14) {
                ForEach(folders, id: \.name) { folder in
                    folderItem(folder)
                }
                
                // File item
                ForEach(files, id: \.name) { file in
                    fileItem(file)
                }
            }
            .padding(.horizontal, 14)
            
            Spacer()
        }
    }
    
    private func folderItem(_ folder: (name: String, icon: String)) -> some View {
        VStack(spacing: 6) {
            Image(systemName: folder.icon)
                .font(.system(size: 32))
                .foregroundStyle(.holoPrimary)
            
            Text(folder.name)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(width: 70, height: 70)
        .innerGlass(cornerRadius: 12)
    }
    
    private func fileItem(_ file: (name: String, icon: String, color: Color)) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Image(systemName: file.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(file.color)
                
                // PowerPoint "P" badge
                Text("P")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.white)
                    .offset(y: 2)
            }
            
            Text(file.name)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(1)
        }
        .frame(width: 70, height: 70)
        .innerGlass(cornerRadius: 12)
    }
}
