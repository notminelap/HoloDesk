// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Ambience Mixer Content

/// Ambient soundscape mixer — combine rain, fire, birds, waves, wind, etc.
struct AmbienceMixerContent: View {
    
    // MARK: - Synth Keyboard Keys Definitions
    struct SynthKey: Identifiable {
        let id = UUID()
        let note: String
        let frequency: Double
        let isBlack: Bool
    }
    
    private let synthKeys: [SynthKey] = [
        SynthKey(note: "C", frequency: 261.63, isBlack: false),
        SynthKey(note: "C#", frequency: 277.18, isBlack: true),
        SynthKey(note: "D", frequency: 293.66, isBlack: false),
        SynthKey(note: "D#", frequency: 311.13, isBlack: true),
        SynthKey(note: "E", frequency: 329.63, isBlack: false),
        SynthKey(note: "F", frequency: 349.23, isBlack: false),
        SynthKey(note: "F#", frequency: 369.99, isBlack: true),
        SynthKey(note: "G", frequency: 392.00, isBlack: false),
        SynthKey(note: "G#", frequency: 415.30, isBlack: true),
        SynthKey(note: "A", frequency: 440.00, isBlack: false),
        SynthKey(note: "A#", frequency: 466.16, isBlack: true),
        SynthKey(note: "B", frequency: 493.88, isBlack: false)
    ]
    
    @State private var waveType: SpatialAudioManager.WaveType = .sine
    @State private var channels: [AmbienceChannel] = AmbienceChannel.defaults
    @State private var masterVolume: Double = 0.7
    @State private var isPlaying = true
    @State private var selectedPreset = "Custom"
    @State private var audio = SpatialAudioManager.shared
    
    // 3D soundboard states
    @State private var selectedTab = 0 // 0 = Mixer Channels, 1 = 3D Soundboard
    @State private var posX: Float = 0.0
    @State private var posY: Float = 1.2
    @State private var posZ: Float = -1.5
    
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
            
            // Tab Selector (Premium Glass Capsule)
            HStack(spacing: 4) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = 0
                    }
                    audio.playSFX(.softTick)
                    HapticManager.shared.lightTap()
                } label: {
                    Text("Mixer")
                        .font(.system(size: 10, weight: selectedTab == 0 ? .bold : .medium))
                        .foregroundStyle(selectedTab == 0 ? .white : .white.opacity(0.4))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(selectedTab == 0 ? .white.opacity(0.1) : .clear, in: Capsule())
                }
                .buttonStyle(.plain)
                
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = 1
                    }
                    audio.playSFX(.softTick)
                    HapticManager.shared.lightTap()
                } label: {
                    Text("3D Soundboard")
                        .font(.system(size: 10, weight: selectedTab == 1 ? .bold : .medium))
                        .foregroundStyle(selectedTab == 1 ? .white : .white.opacity(0.4))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(selectedTab == 1 ? .white.opacity(0.1) : .clear, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(3)
            .background(.white.opacity(0.04), in: Capsule())
            .padding(.bottom, 4)
            
            if selectedTab == 0 {
                // ── Spatial Synth Keyboard Panel ──
                VStack(spacing: 6) {
                    HStack {
                        Text("SPATIAL SYNTHESIZER")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white.opacity(0.4))
                            .tracking(1.0)
                        
                        Spacer()
                        
                        // Waveform Picker
                        HStack(spacing: 2) {
                            ForEach(SpatialAudioManager.WaveType.allCases, id: \.self) { wave in
                                Button {
                                    waveType = wave
                                    audio.playSFX(.softTick)
                                } label: {
                                    Text(wave.rawValue)
                                        .font(.system(size: 7, weight: waveType == wave ? .bold : .regular))
                                        .foregroundStyle(waveType == wave ? .white : .white.opacity(0.4))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(
                                            waveType == wave ? Color.green.opacity(0.2) : Color.clear,
                                            in: RoundedRectangle(cornerRadius: 4)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(2)
                        .background(.black.opacity(0.15), in: RoundedRectangle(cornerRadius: 6))
                    }
                    
                    // 12 Chromatic Synth Keys
                    HStack(spacing: 2) {
                        ForEach(synthKeys) { key in
                            Button {
                                audio.playTone(frequency: key.frequency, waveType: waveType, duration: 0.35)
                                HapticManager.shared.lightTap()
                            } label: {
                                VStack {
                                    Spacer()
                                    Text(key.note)
                                        .font(.system(size: 7, weight: .bold))
                                        .foregroundStyle(key.isBlack ? .white.opacity(0.4) : .black.opacity(0.6))
                                        .padding(.bottom, 4)
                                }
                                .frame(height: 44)
                                .frame(maxWidth: .infinity)
                                .background(
                                    key.isBlack
                                    ? Color(white: 0.12, opacity: 0.8)
                                    : Color(white: 0.95, opacity: 0.75),
                                    in: RoundedRectangle(cornerRadius: 4)
                                )
                                .shadow(color: .black.opacity(0.12), radius: 2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(3)
                    .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 6))
                }
                .padding(8)
                .background(.white.opacity(0.02), in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
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
            } else {
                // ── 3D Soundboard Panel ──
                VStack(spacing: 10) {
                    // Coordinate Map
                    VStack(alignment: .leading, spacing: 4) {
                        Text("3D SPATIAL SOUNDBOARD (X-Z GRID)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white.opacity(0.4))
                            .tracking(1.0)
                        
                        GeometryReader { geo in
                            Canvas { context, size in
                                let w = size.width
                                let h = size.height
                                
                                // Draw grid lines
                                for col in 0...4 {
                                    let x = CGFloat(col) * w / 4
                                    context.stroke(Path { p in
                                        p.move(to: CGPoint(x: x, y: 0))
                                        p.addLine(to: CGPoint(x: x, y: h))
                                    }, with: .color(.white.opacity(0.05)), lineWidth: 0.5)
                                }
                                for row in 0...4 {
                                    let y = CGFloat(row) * h / 4
                                    context.stroke(Path { p in
                                        p.move(to: CGPoint(x: 0, y: y))
                                        p.addLine(to: CGPoint(x: w, y: y))
                                    }, with: .color(.white.opacity(0.05)), lineWidth: 0.5)
                                }
                                
                                // Draw center crosshairs
                                context.stroke(Path { p in
                                    p.move(to: CGPoint(x: w/2, y: 0))
                                    p.addLine(to: CGPoint(x: w/2, y: h))
                                    p.move(to: CGPoint(x: 0, y: h/2))
                                    p.addLine(to: CGPoint(x: w, y: h/2))
                                }, with: .color(.white.opacity(0.12)), lineWidth: 1.0)
                                
                                // Map X [-1.5, 1.5] and Z [-2.5, -0.5]
                                let normX = (posX + 1.5) / 3.0
                                let normZ = (posZ + 2.5) / 2.0
                                
                                let dotX = CGFloat(normX) * w
                                let dotZ = CGFloat(normZ) * h
                                
                                // Outer glow
                                context.fill(
                                    Path(arcCenter: CGPoint(x: dotX, y: dotZ), radius: 10, startAngle: .zero, endAngle: .degrees(360), clockwise: true),
                                    with: .radialGradient(
                                        Gradient(colors: [Color.green.opacity(0.35), .clear]),
                                        center: CGPoint(x: dotX, y: dotZ),
                                        startRadius: 0,
                                        endRadius: 10
                                    )
                                )
                                
                                // Inner dot
                                context.fill(
                                    Path(arcCenter: CGPoint(x: dotX, y: dotZ), radius: 4, startAngle: .zero, endAngle: .degrees(360), clockwise: true),
                                    with: .color(.green)
                                )
                            }
                            .background(Color.white.opacity(0.02))
                            .cornerRadius(8)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let w = geo.size.width
                                        let h = geo.size.height
                                        
                                        let tappedX = max(0, min(w, value.location.x))
                                        let tappedZ = max(0, min(h, value.location.y))
                                        
                                        posX = Float((tappedX / w) * 3.0 - 1.5)
                                        posZ = Float((tappedZ / h) * 2.0 - 2.5)
                                        HapticManager.shared.lightTap()
                                    }
                            )
                        }
                        .frame(height: 100)
                    }
                    .padding(6)
                    .background(.white.opacity(0.02), in: RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.06), lineWidth: 1))
                    
                    // Precise Sliders
                    VStack(spacing: 3) {
                        coordinateSlider(label: "X (Left/Right)", value: $posX, range: -1.5...1.5, format: "%.1f m")
                        coordinateSlider(label: "Y (Up/Down)", value: $posY, range: 0.5...2.0, format: "%.1f m")
                        coordinateSlider(label: "Z (Far/Near)", value: $posZ, range: -2.5...-0.5, format: "%.1f m")
                    }
                    .padding(6)
                    .background(.white.opacity(0.01), in: RoundedRectangle(cornerRadius: 8))
                    
                    // Buttons grid
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TRIGGER SPATIAL SOUND EFFECTS")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white.opacity(0.4))
                            .tracking(1.0)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                            soundTriggerButton("Bubble Pop", effect: .bubblePop)
                            soundTriggerButton("Sonar Ping", effect: .sonarPing)
                            soundTriggerButton("Chime", effect: .chime)
                            soundTriggerButton("Cosmic Sweep", effect: .cosmicSweep)
                        }
                    }
                }
                .padding(.top, 2)
            }
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
    
    private func coordinateSlider(label: String, value: Binding<Float>, range: ClosedRange<Float>, format: String) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
                .frame(width: 70, alignment: .leading)
            
            Slider(value: Binding(
                get: { Double(value.wrappedValue) },
                set: { value.wrappedValue = Float($0) }
            ), in: Double(range.lowerBound)...Double(range.upperBound))
            .tint(.green)
            
            Text(String(format: format, value.wrappedValue))
                .font(.system(size: 8, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
                .frame(width: 40, alignment: .trailing)
        }
    }
    
    private func soundTriggerButton(_ label: String, effect: SoundEffect) -> some View {
        Button {
            audio.playSFX(effect, at: SIMD3<Float>(posX, posY, posZ))
            HapticManager.shared.mediumTap()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "speaker.wave.2.bubble.left.fill")
                    .font(.system(size: 9))
                Text(label)
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.06), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
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
