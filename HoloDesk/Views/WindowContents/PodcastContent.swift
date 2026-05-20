// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Podcast Window Content

/// Podcast player with episode list, show info, and playback controls.
struct PodcastContent: View {
    
    @State private var isPlaying = false
    @State private var progress: Double = 0.22
    @State private var playbackSpeed: Double = 1.0
    @State private var selectedTab: PodcastTab = .nowPlaying
    
    enum PodcastTab: String, CaseIterable {
        case nowPlaying = "Playing"
        case episodes = "Episodes"
        case discover = "Discover"
    }
    
    private let currentEpisode = (
        title: "The Future of Spatial Computing",
        show: "Design Details",
        host: "Brian Lovin & Marshall Bock",
        duration: "1:24:30",
        elapsed: "18:37",
        description: "We dive into Apple Vision Pro, the future of spatial interfaces, and what designers need to know about building for the next computing paradigm."
    )
    
    private let episodes: [(title: String, date: String, duration: String, isPlayed: Bool)] = [
        ("The Future of Spatial Computing", "May 8", "1:24:30", false),
        ("Design Systems at Scale", "May 1", "58:12", true),
        ("AI in Creative Tools", "Apr 24", "1:12:45", true),
        ("Accessibility-First Design", "Apr 17", "45:30", true),
        ("The State of SwiftUI", "Apr 10", "1:08:22", false),
        ("Interview: Jony Ive", "Apr 3", "1:35:00", false),
        ("Typography in AR/VR", "Mar 27", "52:18", true),
    ]
    
    private let shows: [(name: String, publisher: String, hue: Double, emoji: String)] = [
        ("Design Details", "Spec.fm", 0.6, "🎨"),
        ("99% Invisible", "Roman Mars", 0.0, "🏛️"),
        ("Under the Radar", "Marco Arment", 0.55, "📡"),
        ("Swift by Sundell", "John Sundell", 0.08, "🦅"),
        ("Accidental Tech Podcast", "ATP", 0.45, "💻"),
        ("Lex Fridman Podcast", "Lex Fridman", 0.75, "🧠"),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                ForEach(PodcastTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                    } label: {
                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: selectedTab == tab ? .bold : .medium))
                            .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                selectedTab == tab
                                ? Color.white.opacity(0.06)
                                : Color.clear,
                                in: RoundedRectangle(cornerRadius: 8)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(.black.opacity(0.15))
            
            switch selectedTab {
            case .nowPlaying: nowPlayingView
            case .episodes:   episodesList
            case .discover:   discoverView
            }
        }
    }
    
    // MARK: - Now Playing
    
    private var nowPlayingView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                // Show artwork
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hue: 0.6, saturation: 0.5, brightness: 0.4),
                                Color(hue: 0.65, saturation: 0.4, brightness: 0.25)
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 130)
                    .overlay(
                        VStack(spacing: 6) {
                            Image(systemName: "mic.circle.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(.white.opacity(0.3))
                            Text("DESIGN DETAILS")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.5))
                                .tracking(3)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                
                // Episode info
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentEpisode.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(currentEpisode.show)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(hue: 0.78, saturation: 0.5, brightness: 0.85))
                    
                    Text(currentEpisode.description)
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.4))
                        .lineLimit(3)
                        .padding(.top, 2)
                }
                
                // Progress
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.12)).frame(height: 4)
                            Capsule().fill(Color(hue: 0.78, saturation: 0.5, brightness: 0.85)).frame(width: geo.size.width * progress, height: 4)
                            Circle().fill(.white).frame(width: 10, height: 10).offset(x: geo.size.width * progress - 5)
                        }
                        .gesture(DragGesture(minimumDistance: 0).onChanged { v in
                            progress = min(max(Double(v.location.x / geo.size.width), 0), 1)
                        })
                    }
                    .frame(height: 10)
                    
                    HStack {
                        Text(currentEpisode.elapsed)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.4))
                        Spacer()
                        Text("-\(remainingTime)")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                
                // Controls
                HStack(spacing: 20) {
                    // Sleep timer
                    Button { } label: {
                        Image(systemName: "moon.zzz")
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                    
                    // Rewind 15s
                    Button { progress = max(0, progress - 0.02) } label: {
                        Image(systemName: "gobackward.15")
                            .font(.system(size: 22))
                            .foregroundStyle(.white.opacity(0.7))
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
                    
                    // Forward 30s
                    Button { progress = min(1, progress + 0.03) } label: {
                        Image(systemName: "goforward.30")
                            .font(.system(size: 22))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    
                    // Speed
                    Button {
                        let speeds: [Double] = [0.5, 1.0, 1.25, 1.5, 2.0]
                        if let i = speeds.firstIndex(of: playbackSpeed) {
                            playbackSpeed = speeds[(i + 1) % speeds.count]
                        } else { playbackSpeed = 1.0 }
                    } label: {
                        Text("\(playbackSpeed, specifier: "%.1f")×")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(width: 36, height: 28)
                            .innerGlass(cornerRadius: 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
    }
    
    // MARK: - Episodes
    
    private var episodesList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(Array(episodes.enumerated()), id: \.offset) { index, ep in
                    HStack(spacing: 10) {
                        Button {
                            isPlaying = true
                        } label: {
                            Image(systemName: index == 0 && isPlaying ? "waveform" : "play.fill")
                                .font(.system(size: index == 0 ? 14 : 12))
                                .foregroundStyle(index == 0 ? Color(hue: 0.78, saturation: 0.5, brightness: 0.85) : .white.opacity(0.4))
                                .frame(width: 28, height: 28)
                                .innerGlass(cornerRadius: 8)
                        }
                        .buttonStyle(.plain)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ep.title)
                                .font(.system(size: 12, weight: index == 0 ? .bold : .medium))
                                .foregroundStyle(.white.opacity(ep.isPlayed ? 0.5 : 1))
                                .lineLimit(1)
                            HStack(spacing: 6) {
                                Text(ep.date)
                                Text("•")
                                Text(ep.duration)
                            }
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.3))
                        }
                        
                        Spacer()
                        
                        Button { } label: {
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.2))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    
                    if index < episodes.count - 1 {
                        Divider().overlay(Color.white.opacity(0.04)).padding(.horizontal, 54)
                    }
                }
            }
        }
    }
    
    // MARK: - Discover
    
    private var discoverView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Top Shows")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                
                ForEach(Array(shows.enumerated()), id: \.offset) { _, show in
                    HStack(spacing: 10) {
                        Text(show.emoji)
                            .font(.system(size: 20))
                            .frame(width: 40, height: 40)
                            .background(
                                LinearGradient(
                                    colors: [Color(hue: show.hue, saturation: 0.5, brightness: 0.4), Color(hue: show.hue, saturation: 0.4, brightness: 0.25)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                in: RoundedRectangle(cornerRadius: 8)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(show.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                            Text(show.publisher)
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        
                        Spacer()
                        
                        Button { } label: {
                            Text("Follow")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .innerGlass(cornerRadius: 8)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    
    // MARK: - Helper
    
    private var remainingTime: String {
        let totalSeconds = 1 * 3600 + 24 * 60 + 30
        let elapsed = Int(progress * Double(totalSeconds))
        let remaining = totalSeconds - elapsed
        let m = remaining / 60
        let s = remaining % 60
        return String(format: "%d:%02d", m, s)
    }
}
