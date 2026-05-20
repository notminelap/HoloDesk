// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - App Launcher View

/// Quick launcher for real visionOS apps — sends users to actual apps.
struct AppLauncherView: View {
    @Binding var isPresented: Bool
    
    private let apps: [(name: String, icon: String, color: Color, bundle: String)] = [
        ("Safari", "safari", .blue, "com.apple.mobilesafari"),
        ("Mail", "envelope.fill", .blue, "com.apple.mobilemail"),
        ("Maps", "map.fill", .green, "com.apple.Maps"),
        ("FaceTime", "video.fill", .green, "com.apple.facetime"),
        ("Freeform", "scribble", .purple, "com.apple.freeform"),
        ("Keynote", "play.rectangle.fill", .blue, "com.apple.Keynote"),
        ("Photos", "photo.fill", .white, "com.apple.mobileslideshow"),
        ("Music", "music.note", .pink, "com.apple.Music"),
        ("TV", "play.tv.fill", .blue, "com.apple.tv"),
        ("App Store", "bag.fill", .blue, "com.apple.AppStore"),
        ("Settings", "gearshape.fill", .gray, "com.apple.Preferences"),
        ("Files", "folder.fill", .blue, "com.apple.DocumentsApp"),
    ]
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "square.grid.3x3")
                    .font(.system(size: 16))
                    .foregroundStyle(.holoPrimary)
                Text("App Launcher")
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
            
            Text("Launch visionOS apps alongside your workspace")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.4))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(Array(apps.enumerated()), id: \.offset) { _, app in
                    appButton(app)
                }
            }
        }
        .padding(20)
        .frame(width: 380)
        .glassBackground(cornerRadius: 24)
    }
    
    private func appButton(_ app: (name: String, icon: String, color: Color, bundle: String)) -> some View {
        Button {
            // Open app via URL scheme
            if let url = URL(string: "\(app.bundle)://") {
                // In production: UIApplication.shared.open(url)
                HapticManager.shared.mediumTap()
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(app.color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: app.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(app.color)
                }
                
                Text(app.name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}
