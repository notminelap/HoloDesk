// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Spatial Screenshot Manager

/// Captures and manages screenshots of your spatial workspace layout.
@MainActor @Observable
final class SpatialScreenshotManager {
    var screenshots: [SpatialScreenshot] = []
    
    struct SpatialScreenshot: Identifiable, Codable {
        let id: UUID
        var name: String
        var mode: WorkspaceMode
        var windowCount: Int
        var timestamp: Date
        var windowTypes: [WindowType]
        
        init(name: String, mode: WorkspaceMode, windows: [SpatialWindow]) {
            self.id = UUID()
            self.name = name
            self.mode = mode
            self.windowCount = windows.count
            self.timestamp = Date()
            self.windowTypes = windows.map { $0.type }
        }
    }
    
    func capture(name: String, mode: WorkspaceMode, windows: [SpatialWindow]) {
        let screenshot = SpatialScreenshot(name: name, mode: mode, windows: windows)
        screenshots.insert(screenshot, at: 0)
        HapticManager.shared.success()
    }
    
    func delete(_ id: UUID) {
        screenshots.removeAll { $0.id == id }
    }
}

// MARK: - Screenshot Gallery View

struct ScreenshotGalleryView: View {
    @Bindable var manager: SpatialScreenshotManager
    @Environment(WorkspaceStore.self) private var store
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 16))
                    .foregroundStyle(.mint)
                Text("Workspace Captures")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                
                Button {
                    manager.capture(
                        name: "Capture \(manager.screenshots.count + 1)",
                        mode: store.currentMode,
                        windows: store.activeWindows
                    )
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "camera.fill")
                        Text("Capture")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.mint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .innerGlass(cornerRadius: 8)
                }
                .buttonStyle(.plain)
                
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
            
            if manager.screenshots.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "camera")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.2))
                    Text("No captures yet")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.4))
                    Text("Capture your workspace to save a snapshot")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .padding(.vertical, 20)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(manager.screenshots) { screenshot in
                            screenshotCard(screenshot)
                        }
                    }
                }
                .frame(maxHeight: 250)
            }
        }
        .padding(20)
        .frame(width: 380)
        .glassBackground(cornerRadius: 24)
    }
    
    private func screenshotCard(_ screenshot: SpatialScreenshotManager.SpatialScreenshot) -> some View {
        VStack(spacing: 6) {
            // Preview
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.modeTint(for: screenshot.mode).opacity(0.15))
                    .frame(height: 60)
                
                // Mini window representations
                HStack(spacing: 2) {
                    ForEach(screenshot.windowTypes.prefix(4), id: \.self) { type in
                        Image(systemName: type.iconName)
                            .font(.system(size: 10))
                            .foregroundStyle(Color.windowAccent(for: type))
                    }
                    if screenshot.windowTypes.count > 4 {
                        Text("+\(screenshot.windowTypes.count - 4)")
                            .font(.system(size: 8))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
            
            Text(screenshot.name)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
            
            HStack(spacing: 4) {
                Text(screenshot.mode.emoji)
                    .font(.system(size: 8))
                Text(screenshot.timestamp, style: .time)
                    .font(.system(size: 8))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(8)
        .innerGlass(cornerRadius: 10)
    }
}
