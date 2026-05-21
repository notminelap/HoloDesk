// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Music Window Content (Apple Music Style)

/// Apple Music-style player matching the reference image —
/// compact album art on left, controls on right, "Midnight City" by M83.
struct MusicContent: View {
    
    @State private var isPlaying = true
    @State private var progress: Double = 0.45
    @State private var volume: Double = 0.65
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("Music")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                // Spotify / Apple Music indicator dots
                HStack(spacing: 5) {
                    Circle().fill(.blue).frame(width: 8, height: 8)
                    Circle().fill(.green).frame(width: 8, height: 8)
                    Circle().fill(.orange).frame(width: 8, height: 8)
                    Circle().fill(.yellow).frame(width: 8, height: 8)
                    Circle().fill(.purple).frame(width: 8, height: 8)
                }
            }
            
            // Album art — matching reference image exactly
            albumArt
            
            // Track info
            VStack(spacing: 3) {
                Text("Midnight City")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Text("M83")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            // Progress bar with scrubber
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.15))
                            .frame(height: 3)
                        
                        Capsule()
                            .fill(.white.opacity(0.7))
                            .frame(width: geo.size.width * progress, height: 3)
                        
                        // Scrubber
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                            .offset(x: geo.size.width * progress - 4)
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
                    Text("1:34")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.4))
                    Spacer()
                    Text("3:41")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            
            // Controls — exactly matching the reference image layout
            HStack(spacing: 24) {
                controlButton(icon: "shuffle", size: 14)
                controlButton(icon: "backward.fill", size: 18)
                
                // Play/Pause (centered, larger)
                Button {
                    isPlaying.toggle()
                    HapticManager.shared.lightTap()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.12), in: Circle())
                }
                .buttonStyle(.plain)
                
                controlButton(icon: "forward.fill", size: 18)
                controlButton(icon: "repeat", size: 14)
            }
            
            // Volume
            HStack(spacing: 6) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.3))
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.1)).frame(height: 2)
                        Capsule().fill(.white.opacity(0.4)).frame(width: geo.size.width * volume, height: 2)
                    }
                }
                .frame(height: 6)
                
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.3))
            }
            
            Spacer()
        }
        .padding(16)
    }
    
    // MARK: - Album Art (matches reference image)
    
    private var albumArt: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(
                LinearGradient(
                    colors: [
                        Color(hue: 0.6, saturation: 0.7, brightness: 0.5),
                        Color(hue: 0.72, saturation: 0.65, brightness: 0.35),
                        Color(hue: 0.8, saturation: 0.5, brightness: 0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 120)
            .overlay(
                ZStack {
                    // Atmospheric glow
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.2))
                    
                    // City skyline silhouette (Midnight City!)
                    VStack {
                        Spacer()
                        HStack(spacing: 3) {
                            ForEach(0..<10, id: \.self) { i in
                                let heights: [CGFloat] = [20, 35, 28, 50, 18, 42, 30, 48, 22, 38]
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(.white.opacity(Double.random(in: 0.1...0.2)))
                                    .frame(width: 8, height: heights[i])
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    
                    // Small window lights on buildings
                    VStack {
                        Spacer()
                        HStack(spacing: 12) {
                            ForEach(0..<5, id: \.self) { _ in
                                Rectangle()
                                    .fill(.yellow.opacity(0.25))
                                    .frame(width: 3, height: 3)
                                    .offset(y: -CGFloat.random(in: 15...40))
                            }
                        }
                        .padding(.bottom, 10)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private func controlButton(icon: String, size: CGFloat) -> some View {
        Button {
            HapticManager.shared.lightTap()
        } label: {
            Image(systemName: icon)
                .font(.system(size: size))
                .foregroundStyle(.white.opacity(0.6))
        }
        .buttonStyle(.plain)
    }
}
