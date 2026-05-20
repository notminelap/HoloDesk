// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Music Visualizer Content

/// 3D spatial audio visualizer — bars, waveforms, and particles that react to music.
struct MusicVisualizerContent: View {
    
    @State private var barHeights: [CGFloat] = Array(repeating: 0.1, count: 32)
    @State private var isAnimating = false
    @State private var visualizerStyle: VisualizerStyle = .bars
    @State private var hueOffset: Double = 0
    
    enum VisualizerStyle: String, CaseIterable {
        case bars = "Bars"
        case wave = "Wave"
        case circle = "Circle"
        case particles = "Particles"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Style picker
            HStack(spacing: 6) {
                ForEach(VisualizerStyle.allCases, id: \.self) { style in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { visualizerStyle = style }
                    } label: {
                        Text(style.rawValue)
                            .font(.system(size: 9, weight: visualizerStyle == style ? .bold : .regular))
                            .foregroundStyle(visualizerStyle == style ? .white : .white.opacity(0.3))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                visualizerStyle == style
                                ? Color.white.opacity(0.1)
                                : Color.clear,
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.black.opacity(0.2))
            
            // Visualizer
            ZStack {
                Color(white: 0.02)
                
                switch visualizerStyle {
                case .bars:     barsView
                case .wave:     waveView
                case .circle:   circleView
                case .particles: particlesView
                }
            }
        }
        .onAppear {
            isAnimating = true
            animate()
        }
        .onDisappear { isAnimating = false }
    }
    
    // MARK: - Bars
    
    private var barsView: some View {
        GeometryReader { geo in
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<32, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hue: (hueOffset + Double(i) / 32).truncatingRemainder(dividingBy: 1), saturation: 0.7, brightness: 0.9),
                                    Color(hue: (hueOffset + Double(i) / 32 + 0.1).truncatingRemainder(dividingBy: 1), saturation: 0.5, brightness: 0.6)
                                ],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(height: geo.size.height * barHeights[i])
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 4)
        }
    }
    
    // MARK: - Wave
    
    private var waveView: some View {
        GeometryReader { geo in
            Canvas { context, size in
                var path = Path()
                path.move(to: CGPoint(x: 0, y: size.height / 2))
                
                for i in 0..<32 {
                    let x = size.width * CGFloat(i) / 31
                    let y = size.height / 2 + (barHeights[i] - 0.5) * size.height * 0.6
                    if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                    else { path.addLine(to: CGPoint(x: x, y: y)) }
                }
                
                context.stroke(path, with: .linearGradient(
                    Gradient(colors: [.cyan, .purple, .pink]),
                    startPoint: .leading, endPoint: .trailing
                ), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                
                // Mirror
                var mirror = Path()
                for i in 0..<32 {
                    let x = size.width * CGFloat(i) / 31
                    let y = size.height / 2 - (barHeights[i] - 0.5) * size.height * 0.4
                    if i == 0 { mirror.move(to: CGPoint(x: x, y: y)) }
                    else { mirror.addLine(to: CGPoint(x: x, y: y)) }
                }
                context.stroke(mirror, with: .color(.white.opacity(0.15)), style: StrokeStyle(lineWidth: 1, lineCap: .round))
            }
        }
    }
    
    // MARK: - Circle
    
    private var circleView: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius: CGFloat = min(geo.size.width, geo.size.height) * 0.3
            
            Canvas { context, size in
                for i in 0..<32 {
                    let angle = (CGFloat.pi * 2 / 32) * CGFloat(i) - .pi / 2
                    let barLength = barHeights[i] * radius
                    
                    let innerPoint = CGPoint(
                        x: center.x + cos(angle) * radius,
                        y: center.y + sin(angle) * radius
                    )
                    let outerPoint = CGPoint(
                        x: center.x + cos(angle) * (radius + barLength),
                        y: center.y + sin(angle) * (radius + barLength)
                    )
                    
                    var path = Path()
                    path.move(to: innerPoint)
                    path.addLine(to: outerPoint)
                    
                    let hue = (hueOffset + Double(i) / 32).truncatingRemainder(dividingBy: 1)
                    context.stroke(path, with: .color(Color(hue: hue, saturation: 0.7, brightness: 0.9)), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                }
                
                // Center circle
                context.fill(Circle().path(in: CGRect(x: center.x - 20, y: center.y - 20, width: 40, height: 40)), with: .color(.white.opacity(0.05)))
            }
        }
    }
    
    // MARK: - Particles
    
    private var particlesView: some View {
        GeometryReader { geo in
            Canvas { context, size in
                for i in 0..<32 {
                    let x = size.width * CGFloat(i) / 31
                    let y = size.height * (1 - barHeights[i])
                    let dotSize = barHeights[i] * 8 + 2
                    let hue = (hueOffset + Double(i) / 32).truncatingRemainder(dividingBy: 1)
                    
                    context.fill(
                        Circle().path(in: CGRect(x: x - dotSize/2, y: y - dotSize/2, width: dotSize, height: dotSize)),
                        with: .color(Color(hue: hue, saturation: 0.6, brightness: 0.9).opacity(0.7))
                    )
                    
                    // Trail
                    for t in 1..<4 {
                        let trailY = y + CGFloat(t) * 8
                        let trailSize = dotSize * (1 - CGFloat(t) * 0.25)
                        context.fill(
                            Circle().path(in: CGRect(x: x - trailSize/2, y: trailY - trailSize/2, width: trailSize, height: trailSize)),
                            with: .color(Color(hue: hue, saturation: 0.4, brightness: 0.7).opacity(0.15))
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Animation
    
    private func animate() {
        guard isAnimating else { return }
        
        withAnimation(.easeInOut(duration: 0.15)) {
            for i in 0..<32 {
                barHeights[i] = CGFloat.random(in: 0.05...0.95)
            }
            hueOffset += 0.005
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            animate()
        }
    }
}
