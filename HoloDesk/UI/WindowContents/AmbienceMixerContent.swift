// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Ambience Mixer Content

/// Ambient soundscape mixer — combine rain, fire, birds, waves, wind, etc.
struct AmbienceMixerContent: View {
    
    @State private var channels: [AmbienceChannel] = AmbienceChannel.defaults
    @State private var masterVolume: Double = 0.7
    @State private var isPlaying = true
    @State private var selectedPreset = "Custom"
    @State private var audio = SpatialAudioManager.shared
    
    struct AmbienceChannel: Identifiable {
        let id = UUID()
        var name: String
        var emoji: String
        var volume: Double
        var isActive: Bool
        var color: Color
    }
    
    private let presets = ["Custom", "Rainy Cafe", "Forest", "Ocean Night", "Cozy Cabin", "Space Station"]
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "waveform")
                    .font(.system(size: 14))
                    .foregroundStyle(.green)
                Text("Ambience")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                // Generative Soundscape Focus Orb
                GenerativeSoundscapeOrb(channels: channels, isPlaying: isPlaying)
                    .frame(width: 44, height: 44)
                
                Spacer()
                
                Button {
                    isPlaying.toggle()
                    audio.playSFX(.tap)
                    HapticManager.shared.mediumTap()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 2)
            
            // Presets
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(presets, id: \.self) { preset in
                        Button {
                            selectedPreset = preset
                            applyPreset(preset)
                            audio.playSFX(.softTick)
                            HapticManager.shared.lightTap()
                        } label: {
                            Text(preset)
                                .font(.system(size: 9, weight: selectedPreset == preset ? .bold : .regular))
                                .foregroundStyle(selectedPreset == preset ? .white : .white.opacity(0.4))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    selectedPreset == preset ? Color.green.opacity(0.2) : Color.clear,
                                    in: Capsule()
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.bottom, 2)
            
            // Channel sliders
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(Array(channels.enumerated()), id: \.element.id) { index, channel in
                        channelRow(channel, index: index)
                    }
                }
            }
            
            // Master volume
            HStack(spacing: 6) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.3))
                
                Slider(value: $masterVolume, in: 0...1)
                    .tint(.green)
                
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.3))
                
                Text("\(Int(masterVolume * 100))%")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
                    .frame(width: 30)
            }
            .padding(.top, 4)
        }
        .padding(14)
    }
    
    private func channelRow(_ channel: AmbienceChannel, index: Int) -> some View {
        HStack(spacing: 8) {
            Button {
                channels[index].isActive.toggle()
                audio.playSFX(.softTick)
                HapticManager.shared.lightTap()
            } label: {
                Text(channel.emoji)
                    .font(.system(size: 16))
                    .opacity(channel.isActive ? 1 : 0.3)
            }
            .buttonStyle(.plain)
            
            Text(channel.name)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(channel.isActive ? 0.8 : 0.3))
                .frame(width: 55, alignment: .leading)
            
            Slider(value: Binding(
                get: { channels[index].volume },
                set: { channels[index].volume = $0 }
            ), in: 0...1)
            .tint(channel.color.opacity(channel.isActive ? 1 : 0.3))
            .disabled(!channel.isActive)
            
            Text("\(Int(channel.volume * 100))")
                .font(.system(size: 8, design: .monospaced))
                .foregroundStyle(.white.opacity(0.3))
                .frame(width: 20)
        }
        .padding(.vertical, 2)
    }
    
    private func applyPreset(_ preset: String) {
        switch preset {
        case "Rainy Cafe":
            setVolumes([0.8, 0.0, 0.0, 0.0, 0.0, 0.6, 0.3, 0.0, 0.0, 0.4])
        case "Forest":
            setVolumes([0.2, 0.0, 0.9, 0.0, 0.5, 0.0, 0.0, 0.3, 0.0, 0.0])
        case "Ocean Night":
            setVolumes([0.0, 0.0, 0.0, 0.9, 0.0, 0.0, 0.0, 0.6, 0.0, 0.0])
        case "Cozy Cabin":
            setVolumes([0.3, 0.8, 0.0, 0.0, 0.2, 0.0, 0.5, 0.0, 0.0, 0.3])
        case "Space Station":
            setVolumes([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9, 0.2])
        default: break
        }
    }
    
    private func setVolumes(_ volumes: [Double]) {
        for i in 0..<min(volumes.count, channels.count) {
            channels[i].volume = volumes[i]
            channels[i].isActive = volumes[i] > 0
        }
    }
}

// MARK: - Generative Soundscape Focus Orb
struct GenerativeSoundscapeOrb: View {
    var channels: [AmbienceMixerContent.AmbienceChannel]
    var isPlaying: Bool
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let baseRadius = min(size.width, size.height) * 0.36
                
                // If not playing, draw a calm, breathing circular core
                if !isPlaying {
                    let breathe = baseRadius + sin(time * 2.0) * 1.5
                    context.stroke(
                        Path(arcCenter: center, radius: breathe, startAngle: .zero, endAngle: .degrees(360), clockwise: true),
                        with: .color(.white.opacity(0.15)),
                        lineWidth: 1.5
                    )
                    context.fill(
                        Path(arcCenter: center, radius: breathe - 1, startAngle: .zero, endAngle: .degrees(360), clockwise: true),
                        with: .radialGradient(
                            Gradient(colors: [.white.opacity(0.08), .clear]),
                            center: center, startRadius: 0, endRadius: breathe
                        )
                    )
                    return
                }
                
                // Get active channels with non-zero volumes
                let activeChannels = channels.filter { $0.isActive && $0.volume > 0 }
                
                if activeChannels.isEmpty {
                    // Peaceful idle circle
                    let breathe = baseRadius + sin(time * 1.5) * 1.0
                    context.stroke(
                        Path(arcCenter: center, radius: breathe, startAngle: .zero, endAngle: .degrees(360), clockwise: true),
                        with: .color(.white.opacity(0.2)),
                        lineWidth: 1.0
                    )
                    return
                }
                
                // Overlay multiple dynamic deformed wave rings (one per active channel layer, up to 4)
                for (layerIdx, channel) in activeChannels.prefix(4).enumerated() {
                    let volume = channel.volume
                    let color = channel.color
                    
                    var path = Path()
                    let pointCount = 90
                    let angleStep = 360.0 / Double(pointCount)
                    
                    // Specific frequencies and offsets for each channel type
                    let waveFreq: Double
                    switch channel.name {
                    case "Rain": waveFreq = 4.0
                    case "Fire": waveFreq = 9.0 // high flicker frequency
                    case "Birds": waveFreq = 6.0
                    case "Waves": waveFreq = 2.5 // slow swelling waves
                    case "Wind": waveFreq = 3.0
                    default: waveFreq = Double(layerIdx + 3)
                    }
                    
                    let phaseSpeed = 3.0 + Double(layerIdx) * 1.2
                    
                    for i in 0...pointCount {
                        let angle = Double(i) * angleStep
                        let rad = angle * .pi / 180.0
                        
                        // Deform radius sinusoidally based on time, angle and volume
                        let s1 = sin(angle * waveFreq * .pi / 180.0 + time * phaseSpeed)
                        let s2 = cos(angle * waveFreq * 2.1 * .pi / 180.0 - time * phaseSpeed * 1.4) * 0.3
                        let displacement = (s1 + s2) * 5.0 * CGFloat(volume)
                        
                        let currentRadius = baseRadius + displacement
                        let x = center.x + CGFloat(cos(rad)) * currentRadius
                        let y = center.y + CGFloat(sin(rad)) * currentRadius
                        
                        if i == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    path.closeSubpath()
                    
                    // Draw blending screen outlines and soft transparent fills
                    context.stroke(
                        path,
                        with: .color(color.opacity(0.55)),
                        style: StrokeStyle(lineWidth: 1.5)
                    )
                    context.fill(
                        path,
                        with: .color(color.opacity(0.04))
                    )
                }
            }
            .blendMode(.screen)
        }
    }
}

extension AmbienceMixerContent.AmbienceChannel {
    static var defaults: [AmbienceMixerContent.AmbienceChannel] {
        [
            .init(name: "Rain", emoji: "🌧️", volume: 0.5, isActive: true, color: .blue),
            .init(name: "Fire", emoji: "🔥", volume: 0.0, isActive: false, color: .orange),
            .init(name: "Birds", emoji: "🐦", volume: 0.3, isActive: true, color: .green),
            .init(name: "Waves", emoji: "🌊", volume: 0.0, isActive: false, color: .cyan),
            .init(name: "Wind", emoji: "💨", volume: 0.2, isActive: true, color: .gray),
            .init(name: "Cafe", emoji: "☕", volume: 0.0, isActive: false, color: .brown),
            .init(name: "Piano", emoji: "🎹", volume: 0.0, isActive: false, color: .purple),
            .init(name: "Night", emoji: "🦗", volume: 0.0, isActive: false, color: .indigo),
            .init(name: "White", emoji: "📻", volume: 0.0, isActive: false, color: .white),
            .init(name: "Keys", emoji: "⌨️", volume: 0.0, isActive: false, color: .mint),
        ]
    }
}
