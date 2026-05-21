// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Spotify Window Content

/// Full Spotify-like music player with library, playlists, and Now Playing.
struct SpotifyContent: View {
    
    @State private var isPlaying = true
    @State private var progress: Double = 0.38
    @State private var volume: Double = 0.72
    @State private var isShuffled = false
    @State private var repeatMode = 0 // 0=off, 1=all, 2=one
    @State private var selectedTab: SpotifyTab = .nowPlaying
    @State private var likedSongs: Set<Int> = [0, 2, 4]
    
    enum SpotifyTab: String, CaseIterable {
        case nowPlaying = "Now Playing"
        case library = "Library"
        case search = "Search"
        case queue = "Queue"
    }
    
    // Sample data
    private let currentTrack = (title: "Midnight City", artist: "M83", album: "Hurry Up, We're Dreaming", duration: "4:03", elapsed: "1:34")
    
    private let recentTracks: [(title: String, artist: String, duration: String, albumHue: Double)] = [
        ("Midnight City", "M83", "4:03", 0.75),
        ("Blinding Lights", "The Weeknd", "3:20", 0.0),
        ("Starboy", "The Weeknd ft. Daft Punk", "3:50", 0.08),
        ("Get Lucky", "Daft Punk", "6:09", 0.12),
        ("Instant Crush", "Daft Punk ft. Julian Casablancas", "5:37", 0.55),
        ("Somebody Else", "The 1975", "5:43", 0.6),
        ("Take On Me", "a-ha", "3:48", 0.52),
        ("Electric Feel", "MGMT", "3:49", 0.3),
        ("Tame Impala", "The Less I Know The Better", "3:36", 0.85),
        ("Fleetwood Mac", "Dreams", "4:14", 0.15),
    ]
    
    private let playlists: [(name: String, count: Int, emoji: String)] = [
        ("Liked Songs", 342, "💚"),
        ("Chill Vibes", 87, "🌊"),
        ("Workout Energy", 56, "🔥"),
        ("Late Night Coding", 124, "🌙"),
        ("Road Trip", 78, "🚗"),
        ("Focus Flow", 93, "🧠"),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            tabBar
            
            // Content
            switch selectedTab {
            case .nowPlaying: nowPlayingView
            case .library:    libraryView
            case .search:     searchView
            case .queue:      queueView
            }
            
            Spacer(minLength: 0)
            
            // Mini player (always visible)
            miniPlayerBar
        }
    }
    
    // MARK: - Tab Bar
    
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(SpotifyTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tabIcon(tab))
                            .font(.system(size: 13))
                        Text(tab.rawValue)
                            .font(.system(size: 8, weight: .medium))
                    }
                    .foregroundStyle(selectedTab == tab ? .green : .white.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
        }
        .background(.black.opacity(0.2))
    }
    
    private func tabIcon(_ tab: SpotifyTab) -> String {
        switch tab {
        case .nowPlaying: return "music.note"
        case .library:    return "books.vertical"
        case .search:     return "magnifyingglass"
        case .queue:      return "list.bullet"
        }
    }
    
    // MARK: - Now Playing
    
    private var nowPlayingView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                // Album Art (large)
                albumArtLarge
                
                // Track info
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(currentTrack.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        Text(currentTrack.artist)
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Spacer()
                    Button {
                        if likedSongs.contains(0) { likedSongs.remove(0) }
                        else { likedSongs.insert(0) }
                    } label: {
                        Image(systemName: likedSongs.contains(0) ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundStyle(likedSongs.contains(0) ? .green : .white.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
                
                // Progress
                progressBar
                
                // Playback controls
                playbackControls
                
                // Volume
                volumeSlider
                
                // Extras
                HStack(spacing: 20) {
                    extraButton(icon: "speaker.wave.2", label: "Device")
                    extraButton(icon: "list.bullet", label: "Queue")
                    extraButton(icon: "square.and.arrow.up", label: "Share")
                    extraButton(icon: "ellipsis.circle", label: "More")
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
    }
    
    // MARK: - Album Art
    
    private var albumArtLarge: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        Color(hue: 0.6, saturation: 0.7, brightness: 0.5),
                        Color(hue: 0.75, saturation: 0.6, brightness: 0.3),
                        Color(hue: 0.8, saturation: 0.5, brightness: 0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 160)
            .overlay(
                ZStack {
                    // Album art visual
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.white.opacity(0.2))
                    
                    // City skyline silhouette
                    VStack {
                        Spacer()
                        HStack(spacing: 3) {
                            ForEach(0..<12, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(.white.opacity(Double.random(in: 0.08...0.2)))
                                    .frame(width: 8, height: CGFloat.random(in: 12...55))
                            }
                        }
                        .padding(.bottom, 6)
                    }
                    
                    // "Spotify" badge
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "music.note.list")
                                .font(.system(size: 10))
                                .foregroundStyle(.green.opacity(0.6))
                                .padding(6)
                                .background(.black.opacity(0.3), in: Circle())
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color(hue: 0.7, saturation: 0.5, brightness: 0.3).opacity(0.4), radius: 20, y: 8)
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.12)).frame(height: 4)
                    Capsule().fill(.green).frame(width: geo.size.width * progress, height: 4)
                    
                    // Scrubber dot
                    Circle()
                        .fill(.white)
                        .frame(width: 10, height: 10)
                        .offset(x: geo.size.width * progress - 5)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            progress = min(max(Double(value.location.x / geo.size.width), 0), 1)
                        }
                )
            }
            .frame(height: 10)
            
            HStack {
                Text(currentTrack.elapsed)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
                Spacer()
                Text(currentTrack.duration)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }
    
    // MARK: - Playback Controls
    
    private var playbackControls: some View {
        HStack(spacing: 20) {
            // Shuffle
            Button {
                isShuffled.toggle()
            } label: {
                Image(systemName: "shuffle")
                    .font(.system(size: 16))
                    .foregroundStyle(isShuffled ? .green : .white.opacity(0.5))
            }
            .buttonStyle(.plain)
            
            // Previous
            Button { } label: {
                Image(systemName: "backward.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .buttonStyle(.plain)
            
            // Play/Pause
            Button {
                isPlaying.toggle()
                HapticManager.shared.lightTap()
            } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            
            // Next
            Button { } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .buttonStyle(.plain)
            
            // Repeat
            Button {
                repeatMode = (repeatMode + 1) % 3
            } label: {
                Image(systemName: repeatMode == 2 ? "repeat.1" : "repeat")
                    .font(.system(size: 16))
                    .foregroundStyle(repeatMode > 0 ? .green : .white.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Volume
    
    private var volumeSlider: some View {
        HStack(spacing: 8) {
            Image(systemName: "speaker.fill")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.4))
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.12)).frame(height: 3)
                    Capsule().fill(.white.opacity(0.6)).frame(width: geo.size.width * volume, height: 3)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            volume = min(max(Double(value.location.x / geo.size.width), 0), 1)
                        }
                )
            }
            .frame(height: 8)
            
            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.4))
        }
    }
    
    // MARK: - Library View
    
    private var libraryView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Library")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                
                // Playlists
                ForEach(Array(playlists.enumerated()), id: \.offset) { _, playlist in
                    HStack(spacing: 10) {
                        Text(playlist.emoji)
                            .font(.system(size: 20))
                            .frame(width: 40, height: 40)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(playlist.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("Playlist • \(playlist.count) songs")
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 2)
                }
                
                Divider().overlay(Color.white.opacity(0.06)).padding(.horizontal, 16)
                
                // Recently played
                Text("Recently Played")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                
                ForEach(Array(recentTracks.prefix(5).enumerated()), id: \.offset) { index, track in
                    trackRow(track, index: index)
                }
            }
        }
    }
    
    // MARK: - Search View
    
    private var searchView: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.4))
                Text("Search songs, artists, playlists...")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.3))
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Browse categories
            Text("Browse All")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                categoryCard("Pop", color: .pink)
                categoryCard("Hip-Hop", color: .orange)
                categoryCard("Electronic", color: .purple)
                categoryCard("Rock", color: .red)
                categoryCard("Lo-fi", color: .teal)
                categoryCard("Jazz", color: .brown)
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
    }
    
    // MARK: - Queue View
    
    private var queueView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Now Playing")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                
                trackRow(recentTracks[0], index: 0, isCurrentlyPlaying: true)
                
                Divider().overlay(Color.white.opacity(0.06)).padding(.horizontal, 16)
                
                Text("Up Next")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                
                ForEach(Array(recentTracks.dropFirst().enumerated()), id: \.offset) { index, track in
                    trackRow(track, index: index + 1)
                }
            }
        }
    }
    
    // MARK: - Components
    
    private func trackRow(_ track: (title: String, artist: String, duration: String, albumHue: Double), index: Int, isCurrentlyPlaying: Bool = false) -> some View {
        HStack(spacing: 10) {
            // Album mini art
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hue: track.albumHue, saturation: 0.6, brightness: 0.5),
                            Color(hue: track.albumHue + 0.1, saturation: 0.5, brightness: 0.3)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 36, height: 36)
                .overlay(
                    isCurrentlyPlaying
                    ? AnyView(Image(systemName: "waveform")
                        .font(.system(size: 10))
                        .foregroundStyle(.green))
                    : AnyView(Image(systemName: "music.note")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.4)))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(.system(size: 12, weight: isCurrentlyPlaying ? .bold : .medium))
                    .foregroundStyle(isCurrentlyPlaying ? .green : .white)
                    .lineLimit(1)
                Text(track.artist)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.4))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Like
            Button {
                if likedSongs.contains(index) { likedSongs.remove(index) }
                else { likedSongs.insert(index) }
            } label: {
                Image(systemName: likedSongs.contains(index) ? "heart.fill" : "heart")
                    .font(.system(size: 11))
                    .foregroundStyle(likedSongs.contains(index) ? .green : .white.opacity(0.2))
            }
            .buttonStyle(.plain)
            
            Text(track.duration)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 3)
    }
    
    private func categoryCard(_ name: String, color: Color) -> some View {
        Text(name)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                LinearGradient(
                    colors: [color.opacity(0.5), color.opacity(0.25)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 8)
            )
    }
    
    private func extraButton(icon: String, label: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.5))
            Text(label)
                .font(.system(size: 8))
                .foregroundStyle(.white.opacity(0.3))
        }
    }
    
    // MARK: - Mini Player Bar
    
    private var miniPlayerBar: some View {
        HStack(spacing: 10) {
            // Mini album art
            RoundedRectangle(cornerRadius: 4)
                .fill(LinearGradient(
                    colors: [Color(hue: 0.6, saturation: 0.7, brightness: 0.5), Color(hue: 0.75, saturation: 0.6, brightness: 0.3)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "music.note")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 1) {
                Text(currentTrack.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(currentTrack.artist)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.4))
            }
            
            Spacer()
            
            // Mini controls
            Button { } label: {
                Image(systemName: "speaker.wave.2")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .buttonStyle(.plain)
            
            Button { isPlaying.toggle() } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            
            Button { } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.black.opacity(0.3))
    }
}
