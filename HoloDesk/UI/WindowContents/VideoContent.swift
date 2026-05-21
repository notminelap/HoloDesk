// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import AVKit

// MARK: - Enhanced Video Player Content

/// Full cinematic video player with controls, chapters, and picture-in-picture.
struct VideoContent: View {
    @State private var isPlaying = false
    @State private var progress: Double = 0.0
    @State private var volume: Double = 0.8
    @State private var showControls = true
    @State private var isFullscreen = false
    @State private var selectedQuality = "1080p"
    @State private var playbackSpeed: Double = 1.0
    
    private let videoTitle = "Planet Earth III — Deep Ocean"
    private let channelName = "BBC Earth"
    private let duration = "2:34:15"
    
    private let chapters: [(title: String, time: String, progress: Double)] = [
        ("Introduction", "0:00", 0.0),
        ("The Abyss", "12:30", 0.08),
        ("Coral Kingdoms", "34:15", 0.22),
        ("Deep Trenches", "58:00", 0.38),
        ("Bioluminescence", "1:22:45", 0.55),
        ("Migration", "1:48:30", 0.72),
        ("Conservation", "2:10:00", 0.87),
    ]
    
    private let relatedVideos: [(title: String, channel: String, views: String, hue: Double)] = [
        ("Our Planet — Forests", "Netflix", "42M views", 0.3),
        ("Blue Planet II", "BBC Earth", "38M views", 0.55),
        ("Cosmos: Worlds", "NatGeo", "25M views", 0.7),
        ("Night on Earth", "Netflix", "31M views", 0.15),
    ]
    
    var body: some View {
        ZStack {
            // Video background
            videoBackground
            
            // Controls overlay
            if showControls {
                controlsOverlay
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showControls.toggle()
            }
        }
    }
    
    // MARK: - Video Background
    
    private var videoBackground: some View {
        ZStack {
            // Deep ocean gradient
            LinearGradient(
                colors: [
                    Color(hue: 0.58, saturation: 0.6, brightness: 0.12),
                    Color(hue: 0.62, saturation: 0.5, brightness: 0.08),
                    Color(hue: 0.55, saturation: 0.4, brightness: 0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Underwater particle effect
            ZStack {
                ForEach(0..<15, id: \.self) { i in
                    Circle()
                        .fill(.white.opacity(Double.random(in: 0.02...0.08)))
                        .frame(width: CGFloat.random(in: 2...6))
                        .offset(
                            x: CGFloat.random(in: -200...200),
                            y: CGFloat.random(in: -150...150)
                        )
                }
            }
            
            // Cinematic letterbox bars
            VStack(spacing: 0) {
                Rectangle()
                    .fill(.black)
                    .frame(height: isFullscreen ? 0 : 20)
                Spacer()
                Rectangle()
                    .fill(.black)
                    .frame(height: isFullscreen ? 0 : 20)
            }
        }
    }
    
    // MARK: - Controls Overlay
    
    private var controlsOverlay: some View {
        VStack(spacing: 0) {
            // Top bar
            topBar
                .padding(.top, 24)
            
            Spacer()
            
            // Center controls
            centerControls
            
            Spacer()
            
            // Bottom controls
            bottomControls
        }
        .background(
            LinearGradient(
                colors: [.black.opacity(0.6), .clear, .clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .transition(.opacity)
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(videoTitle)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Text(channelName)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Quality badge
            Menu {
                Button("4K HDR") { selectedQuality = "4K HDR" }
                Button("1080p") { selectedQuality = "1080p" }
                Button("720p") { selectedQuality = "720p" }
                Button("480p") { selectedQuality = "480p" }
            } label: {
                Text(selectedQuality)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.white.opacity(0.15), in: Capsule())
            }
            
            // PiP button
            Button { } label: {
                Image(systemName: "pip.enter")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .buttonStyle(.plain)
            
            // Fullscreen
            Button {
                isFullscreen.toggle()
            } label: {
                Image(systemName: isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Center Controls
    
    private var centerControls: some View {
        HStack(spacing: 36) {
            // Rewind 10s
            Button { progress = max(0, progress - 0.02) } label: {
                ZStack {
                    Image(systemName: "gobackward.10")
                        .font(.system(size: 26))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .buttonStyle(.plain)
            
            // Play/Pause
            Button {
                isPlaying.toggle()
                HapticManager.shared.lightTap()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(.white.opacity(0.12), in: Circle())
            }
            .buttonStyle(.plain)
            
            // Forward 10s
            Button { progress = min(1, progress + 0.02) } label: {
                Image(systemName: "goforward.10")
                    .font(.system(size: 26))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControls: some View {
        VStack(spacing: 6) {
            // Chapter markers on progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule().fill(.white.opacity(0.15)).frame(height: 4)
                    
                    // Buffer
                    Capsule().fill(.white.opacity(0.2))
                        .frame(width: geo.size.width * min(progress + 0.1, 1), height: 4)
                    
                    // Progress
                    Capsule().fill(.red)
                        .frame(width: geo.size.width * progress, height: 4)
                    
                    // Chapter dots
                    ForEach(Array(chapters.enumerated()), id: \.offset) { _, chapter in
                        Circle()
                            .fill(.white.opacity(0.5))
                            .frame(width: 4, height: 4)
                            .offset(x: geo.size.width * chapter.progress - 2)
                    }
                    
                    // Scrubber
                    Circle()
                        .fill(.red)
                        .frame(width: 12, height: 12)
                        .offset(x: geo.size.width * progress - 6)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            progress = min(max(Double(value.location.x / geo.size.width), 0), 1)
                        }
                )
            }
            .frame(height: 16)
            
            // Time + controls
            HStack {
                Text(timeForProgress(progress))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.6))
                
                Text("/")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.3))
                
                Text(duration)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
                
                Spacer()
                
                // Speed
                Menu {
                    Button("0.5×") { playbackSpeed = 0.5 }
                    Button("0.75×") { playbackSpeed = 0.75 }
                    Button("1×") { playbackSpeed = 1.0 }
                    Button("1.25×") { playbackSpeed = 1.25 }
                    Button("1.5×") { playbackSpeed = 1.5 }
                    Button("2×") { playbackSpeed = 2.0 }
                } label: {
                    Text("\(playbackSpeed, specifier: "%.1f")×")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                // Volume
                HStack(spacing: 4) {
                    Image(systemName: volume > 0 ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.5))
                    
                    Slider(value: $volume, in: 0...1)
                        .frame(width: 60)
                        .tint(.white.opacity(0.6))
                }
                
                // Subtitles
                Button { } label: {
                    Image(systemName: "captions.bubble")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .buttonStyle(.plain)
                
                // Settings
                Button { } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 28)
    }
    
    // MARK: - Helper
    
    private func timeForProgress(_ p: Double) -> String {
        let totalSeconds = 2 * 3600 + 34 * 60 + 15
        let current = Int(p * Double(totalSeconds))
        let h = current / 3600
        let m = (current % 3600) / 60
        let s = current % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
    }
}
