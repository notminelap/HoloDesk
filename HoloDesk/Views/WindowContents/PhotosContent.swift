// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Photos Window Content

/// Photo grid with landscape images — visual gallery.
struct PhotosContent: View {
    
    // Gradient-based photo placeholders that look like landscape images
    private let photoGradients: [(colors: [Color], icon: String)] = [
        ([Color(hue: 0.55, saturation: 0.6, brightness: 0.5), Color(hue: 0.35, saturation: 0.7, brightness: 0.4)], "mountain.2.fill"),
        ([Color(hue: 0.1, saturation: 0.7, brightness: 0.6), Color(hue: 0.05, saturation: 0.8, brightness: 0.4)], "sun.horizon.fill"),
        ([Color(hue: 0.6, saturation: 0.5, brightness: 0.4), Color(hue: 0.58, saturation: 0.7, brightness: 0.3)], "water.waves"),
        ([Color(hue: 0.3, saturation: 0.6, brightness: 0.5), Color(hue: 0.35, saturation: 0.5, brightness: 0.3)], "leaf.fill"),
        ([Color(hue: 0.7, saturation: 0.4, brightness: 0.5), Color(hue: 0.75, saturation: 0.6, brightness: 0.3)], "moon.stars.fill"),
        ([Color(hue: 0.45, saturation: 0.5, brightness: 0.6), Color(hue: 0.5, saturation: 0.7, brightness: 0.35)], "cloud.fill"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Text("Photos")
                    .font(.system(size: 14, weight: .bold))
                    .italic()
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            
            // Photo grid
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 6),
                        GridItem(.flexible(), spacing: 6),
                        GridItem(.flexible(), spacing: 6)
                    ],
                    spacing: 6
                ) {
                    ForEach(Array(photoGradients.enumerated()), id: \.offset) { index, photo in
                        photoCell(colors: photo.colors, icon: photo.icon, index: index)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
        }
    }
    
    private func photoCell(colors: [Color], icon: String, index: Int) -> some View {
        let height: CGFloat = index == 0 ? 100 : (index % 3 == 0 ? 80 : 70)
        
        return RoundedRectangle(cornerRadius: 8)
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: height)
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.3))
            )
    }
}
