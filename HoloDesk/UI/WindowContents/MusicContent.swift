// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Music Window Content (Apple Music Style)

/// Compact Apple Music-style player with rotating ambient vinyl overlay,
/// spatial sound effects, spring scaling, and a highly polished UI.
struct MusicContent: View {
    
    @Environment(SpatialAudioManager.self) private var audio
    
    @State private var isPlaying = true
    @State private var progress: Double = 0.45
    @State private var volume: Double = 0.65
    
    // Rotating galaxy/vinyl effect
    @State private var rotationAngle = 0.0
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "music.note")
                        .font(.system(size: 10))
                        .foregroundStyle(.pink)
                    Text("Now Playing")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
                Spacer()
                
                // Active waveform indicator
                HStack(spacing: 2) {
                    ForEach(0..<4, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(.pink)
                            .frame(width: 2, height: isPlaying ? CGFloat.random(in: 4...12) : 4)
                            .animation(isPlaying ? .easeInOut(duration: 0.3).repeatForever(autoreverses: true).delay(Double(i) * 0.05) : .default, value: isPlaying)
                    }
                }
            }
            
            // Album art — lifts and rotates dynamically when playing
            albumArt
                .scaleEffect(isPlaying ? 1.03 : 0.96)
                .shadow(color: .pink.opacity(isPlaying ? 0.25 : 0.05), radius: isPlaying ? 16 : 8, y: isPlaying ? 6 : 2)
                .animation(.spring(response: 0.45, dampingFraction: 0.72), value: isPlaying)
            
            // Track info
            VStack(spacing: 3) {
                Text("Midnight City")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text("M83")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.top, 4)
            
            // Progress bar with scrubber
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.12))
                            .frame(height: 3)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * progress, height: 3)
                        
                        // Scrubber handle
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                            .offset(x: geo.size.width * progress - 4)
                            .shadow(radius: 2)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                progress = min(max(Double(value.location.x / geo.size.width), 0), 1)
                            }
                    )
                }
                .frame(height: 8)
                
                HStack {
                    Text(formatTime(progress * 221)) // 3:41 = 221 seconds
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                    Spacer()
                    Text("3:41")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            
            // Controls — responsive spatial buttons
            HStack(spacing: 24) {
                controlButton(icon: "shuffle") {
                    audio.playSFX(.softTick)
                }
                
                controlButton(icon: "backward.fill") {
                    audio.playSFX(.softTick)
                    progress = max(0, progress - 0.1)
                }
                
                // Play/Pause (centered, larger with bounce)
                Button {
                    isPlaying.toggle()
                    audio.playSFX(isPlaying ? .windowOpen : .windowClose)
                    HapticManager.shared.mediumTap()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(.white.opacity(0.12), in: Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.15), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
                .hoverGlow()
                .spatialDepth()
                
                controlButton(icon: "forward.fill") {
                    audio.playSFX(.softTick)
                    progress = min(1, progress + 0.1)
                }
                
                controlButton(icon: "repeat") {
                    audio.playSFX(.softTick)
                }
            }
            .padding(.vertical, 4)
            
            // Volume Scrubber
            HStack(spacing: 8) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.3))
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.08)).frame(height: 2)
                        Capsule().fill(.white.opacity(0.4)).frame(width: geo.size.width * volume, height: 2)
                        
                        Circle()
                            .fill(.white.opacity(0.7))
                            .frame(width: 6, height: 6)
                            .offset(x: geo.size.width * volume - 3)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                volume = min(max(Double(value.location.x / geo.size.width), 0), 1)
                                audio.setVolume(Float(volume))
                            }
                    )
                }
                .frame(height: 6)
                
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(.top, 4)
            
            Spacer()
        }
        .padding(16)
        .onAppear {
            if isPlaying {
                withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                    rotationAngle = 360.0
                }
            }
        }
    }
    
    // MARK: - Album Art (matches reference image)
    
    private var albumArt: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.35, blue: 0.72), // Atmospheric deep blue
                        Color(red: 0.42, green: 0.12, blue: 0.58), // Midnight purple
                        Color(red: 0.12, green: 0.05, blue: 0.2) // Void black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 120)
            .overlay(
                ZStack {
                    // Galaxy dust / rotating ambient records
                    Circle()
                        .strokeBorder(.white.opacity(0.03), lineWidth: 1)
                        .frame(width: 100, height: 100)
                    Circle()
                        .strokeBorder(.white.opacity(0.02), lineWidth: 1)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink.opacity(0.2), .purple.opacity(0.08)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .rotationEffect(.degrees(rotationAngle))
                        .onChange(of: isPlaying) { _, playing in
                            if playing {
                                withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                                    rotationAngle += 360.0
                                }
                            }
                        }
                    
                    // City skyline silhouette (Midnight City!)
                    VStack {
                        Spacer()
                        HStack(spacing: 3) {
                            ForEach(0..<10, id: \.self) { i in
                                let heights: [CGFloat] = [20, 35, 28, 50, 18, 42, 30, 48, 22, 38]
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(.white.opacity(isPlaying ? 0.22 : 0.12))
                                    .frame(width: 8, height: heights[i])
                                    .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(Double(i) * 0.02), value: isPlaying)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    
                    // Small glowing window lights on buildings
                    VStack {
                        Spacer()
                        HStack(spacing: 12) {
                            ForEach(0..<5, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color(red: 1.0, green: 0.85, blue: 0.4))
                                    .frame(width: 2, height: 2)
                                    .opacity(isPlaying ? 0.6 : 0.2)
                                    .offset(y: -CGFloat.random(in: 12...38))
                            }
                        }
                        .padding(.bottom, 10)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
            )
    }
    
    private func controlButton(icon: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
            HapticManager.shared.lightTap()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.5))
                .frame(width: 28, height: 28)
                .background(.white.opacity(0.04), in: Circle())
        }
        .buttonStyle(.plain)
        .hoverGlow()
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
