// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Photos Window Content (Interactive)

/// Apple Photos-inspired gallery with tabs, selection, and photo preview.
struct PhotosContent: View {
    
    @State private var selectedPhoto: Int?
    @State private var selectedTab: PhotoTab = .library
    @State private var showFavorites = false
    
    enum PhotoTab: String, CaseIterable {
        case library = "Library"
        case favorites = "Favorites"
        case albums = "Albums"
    }
    
    struct PhotoItem: Identifiable {
        let id: Int
        let colors: [Color]
        let icon: String
        let label: String
        let date: String
        var isFavorite: Bool
    }
    
    @State private var photos: [PhotoItem] = [
        PhotoItem(id: 0, colors: [Color(hue: 0.55, saturation: 0.6, brightness: 0.5), Color(hue: 0.35, saturation: 0.7, brightness: 0.4)], icon: "mountain.2.fill", label: "Alps", date: "May 20", isFavorite: true),
        PhotoItem(id: 1, colors: [Color(hue: 0.1, saturation: 0.7, brightness: 0.6), Color(hue: 0.05, saturation: 0.8, brightness: 0.4)], icon: "sun.horizon.fill", label: "Sunset", date: "May 18", isFavorite: true),
        PhotoItem(id: 2, colors: [Color(hue: 0.6, saturation: 0.5, brightness: 0.4), Color(hue: 0.58, saturation: 0.7, brightness: 0.3)], icon: "water.waves", label: "Ocean", date: "May 15", isFavorite: false),
        PhotoItem(id: 3, colors: [Color(hue: 0.3, saturation: 0.6, brightness: 0.5), Color(hue: 0.35, saturation: 0.5, brightness: 0.3)], icon: "leaf.fill", label: "Forest", date: "May 12", isFavorite: false),
        PhotoItem(id: 4, colors: [Color(hue: 0.7, saturation: 0.4, brightness: 0.5), Color(hue: 0.75, saturation: 0.6, brightness: 0.3)], icon: "moon.stars.fill", label: "Night Sky", date: "May 10", isFavorite: true),
        PhotoItem(id: 5, colors: [Color(hue: 0.45, saturation: 0.5, brightness: 0.6), Color(hue: 0.5, saturation: 0.7, brightness: 0.35)], icon: "cloud.fill", label: "Clouds", date: "May 8", isFavorite: false),
        PhotoItem(id: 6, colors: [Color(hue: 0.0, saturation: 0.6, brightness: 0.55), Color(hue: 0.95, saturation: 0.7, brightness: 0.35)], icon: "flame.fill", label: "Campfire", date: "May 5", isFavorite: true),
        PhotoItem(id: 7, colors: [Color(hue: 0.18, saturation: 0.6, brightness: 0.7), Color(hue: 0.22, saturation: 0.5, brightness: 0.4)], icon: "building.2.fill", label: "City", date: "May 2", isFavorite: false),
        PhotoItem(id: 8, colors: [Color(hue: 0.85, saturation: 0.4, brightness: 0.6), Color(hue: 0.9, saturation: 0.5, brightness: 0.35)], icon: "sparkles", label: "Aurora", date: "Apr 28", isFavorite: true),
    ]
    
    private var displayedPhotos: [PhotoItem] {
        switch selectedTab {
        case .library:   return photos
        case .favorites: return photos.filter(\.isFavorite)
        case .albums:    return photos
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                ForEach(PhotoTab.allCases, id: \.rawValue) { tab in
                    Button {
                        withAnimation(.spring(response: 0.25)) { selectedTab = tab }
                    } label: {
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: selectedTab == tab ? .bold : .medium))
                            .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(selectedTab == tab ? Color.white.opacity(0.06) : .clear, in: RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.black.opacity(0.15))
            
            // Photo count
            HStack {
                Text("\(displayedPhotos.count) Photos")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)
            
            // Photo grid or expanded view
            if let sel = selectedPhoto, let photo = photos.first(where: { $0.id == sel }) {
                // Expanded photo view
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: photo.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 160)
                        
                        Image(systemName: photo.icon)
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .padding(.horizontal, 10)
                    
                    HStack {
                        Text(photo.label)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        Text(photo.date)
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.3))
                        
                        Button {
                            if let idx = photos.firstIndex(where: { $0.id == sel }) {
                                photos[idx].isFavorite.toggle()
                            }
                        } label: {
                            Image(systemName: photo.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 12))
                                .foregroundStyle(photo.isFavorite ? .pink : .white.opacity(0.3))
                        }
                        .buttonStyle(.plain)
                        
                        Button { withAnimation(.spring(response: 0.3)) { selectedPhoto = nil } } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.3))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 14)
                    
                    Spacer()
                }
                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
            } else {
                // Grid
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)],
                        spacing: 4
                    ) {
                        ForEach(displayedPhotos) { photo in
                            Button {
                                withAnimation(.spring(response: 0.3)) { selectedPhoto = photo.id }
                                HapticManager.shared.lightTap()
                            } label: {
                                ZStack(alignment: .bottomTrailing) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(LinearGradient(colors: photo.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(height: photo.id == 0 ? 90 : 72)
                                    
                                    Image(systemName: photo.icon)
                                        .font(.system(size: 16))
                                        .foregroundStyle(.white.opacity(0.3))
                                    
                                    if photo.isFavorite {
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 8))
                                            .foregroundStyle(.pink)
                                            .padding(4)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
            }
        }
    }
}
