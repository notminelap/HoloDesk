// Copyright (c) 2026 Radhesh Ranvijay. All Rights Reserved.
// Designed by Radhesh Ranvijay for Apple Swift Student Challenge.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Brush Types
enum BrushType: String, CaseIterable {
    case solid = "Solid Pen"
    case laser = "Laser Glow"
    case cosmic = "Cosmic Dust"
    
    var iconName: String {
        switch self {
        case .solid: return "paintbrush.pointed.fill"
        case .laser: return "sparkles"
        case .cosmic: return "wavy.flatline"
        }
    }
}

// MARK: - Stroke Structure
struct WhiteboardStroke: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var width: CGFloat
    var brushType: BrushType
}

/// A dedicated, premium spatial whiteboard featuring glowing laser brushes, cosmic particle streams, and canvas history stacks.
struct WhiteboardContent: View {
    // Drawing State
    @State private var strokes: [WhiteboardStroke] = []
    @State private var undoneStrokes: [WhiteboardStroke] = []
    @State private var currentStrokePoints: [CGPoint] = []
    
    // Tools State
    @State private var selectedBrush: BrushType = .solid
    @State private var selectedColor: Color = .cyan
    @State private var strokeWidth: CGFloat = 4.0
    @State private var showGrid: Bool = true
    
    // Color Palette matching the 8 HSL premium palette
    private let presetColors: [(name: String, color: Color)] = [
        ("Cyan", Color(hue: 0.53, saturation: 0.8, brightness: 0.95)),
        ("Pink", Color(hue: 0.95, saturation: 0.8, brightness: 0.95)),
        ("Gold", Color(hue: 0.12, saturation: 0.8, brightness: 0.95)),
        ("Lavender", Color(hue: 0.72, saturation: 0.5, brightness: 0.95)),
        ("Emerald", Color(hue: 0.40, saturation: 0.7, brightness: 0.9)),
        ("Indigo", Color(hue: 0.65, saturation: 0.75, brightness: 0.95)),
        ("Crimson", Color(hue: 0.0, saturation: 0.85, brightness: 0.9)),
        ("White", .white)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Upper control toolbar
            HStack(spacing: 16) {
                // Brush Selector
                HStack(spacing: 4) {
                    ForEach(BrushType.allCases, id: \.self) { brush in
                        Button {
                            selectedBrush = brush
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: brush.iconName)
                                    .font(.system(size: 11))
                                Text(brush.rawValue)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                selectedBrush == brush
                                ? Color.white.opacity(0.12)
                                : Color.clear,
                                in: RoundedRectangle(cornerRadius: 6)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
                .background(.black.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
                
                Spacer()
                
                // Stroke Width Slider
                HStack(spacing: 8) {
                    Image(systemName: "line.horizontal.3.decrease")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.4))
                    
                    Slider(value: $strokeWidth, in: 2...12)
                        .frame(width: 80)
                        .tint(selectedColor)
                    
                    Text("\(Int(strokeWidth))px")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(width: 28, alignment: .trailing)
                }
                
                // Alignment Grid Toggle
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showGrid.toggle()
                    }
                } label: {
                    Image(systemName: showGrid ? "grid" : "grid.circle")
                        .font(.system(size: 11))
                        .foregroundStyle(showGrid ? selectedColor : .white.opacity(0.4))
                        .frame(width: 24, height: 24)
                        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                
                // History Actions: Undo / Redo / Trash
                HStack(spacing: 4) {
                    // Undo
                    Button {
                        undo()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 11))
                            .foregroundStyle(strokes.isEmpty ? .white.opacity(0.2) : .white.opacity(0.7))
                            .frame(width: 24, height: 24)
                    }
                    .disabled(strokes.isEmpty)
                    .buttonStyle(.plain)
                    
                    // Redo
                    Button {
                        redo()
                    } label: {
                        Image(systemName: "arrow.uturn.forward")
                            .font(.system(size: 11))
                            .foregroundStyle(undoneStrokes.isEmpty ? .white.opacity(0.2) : .white.opacity(0.7))
                            .frame(width: 24, height: 24)
                    }
                    .disabled(undoneStrokes.isEmpty)
                    .buttonStyle(.plain)
                    
                    // Clear / Trash
                    Button {
                        withAnimation {
                            undoneStrokes = strokes
                            strokes.removeAll()
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 11))
                            .foregroundStyle(.red.opacity(0.6))
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                }
                .padding(4)
                .background(.black.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.white.opacity(0.03))
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Drawing Canvas Area
            ZStack {
                // Background & Grid Mesh
                Color(white: 0.04)
                
                if showGrid {
                    Canvas { context, size in
                        let spacing: CGFloat = 32
                        // Dot grid mesh
                        for x in stride(from: spacing, to: size.width, by: spacing) {
                            for y in stride(from: spacing, to: size.height, by: spacing) {
                                let circle = Path(ellipseIn: CGRect(x: x - 1, y: y - 1, width: 2, height: 2))
                                context.fill(circle, with: .color(Color.white.opacity(0.06)))
                            }
                        }
                    }
                }
                
                // Premium Interactive Drawing Canvas
                Canvas { context, size in
                    // Draw existing strokes
                    for stroke in strokes {
                        drawStroke(stroke, in: &context)
                    }
                    // Draw the currently active drawing stroke
                    if !currentStrokePoints.isEmpty {
                        let activeStroke = WhiteboardStroke(
                            points: currentStrokePoints,
                            color: selectedColor,
                            width: strokeWidth,
                            brushType: selectedBrush
                        )
                        drawStroke(activeStroke, in: &context)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            currentStrokePoints.append(value.location)
                        }
                        .onEnded { _ in
                            if !currentStrokePoints.isEmpty {
                                let newStroke = WhiteboardStroke(
                                    points: currentStrokePoints,
                                    color: selectedColor,
                                    width: strokeWidth,
                                    brushType: selectedBrush
                                )
                                strokes.append(newStroke)
                                currentStrokePoints = []
                                undoneStrokes.removeAll() // Clear redo stack on new action
                            }
                        }
                )
            }
            
            // Bottom premium HSL color selector bar
            HStack {
                Text("HSL Spatial Palettes:")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .textCase(.uppercase)
                
                Spacer()
                
                HStack(spacing: 12) {
                    ForEach(presetColors, id: \.name) { preset in
                        Button {
                            selectedColor = preset.color
                        } label: {
                            Circle()
                                .fill(preset.color)
                                .frame(width: 18, height: 18)
                                .shadow(color: preset.color.opacity(0.4), radius: selectedColor == preset.color ? 6 : 0)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white, lineWidth: selectedColor == preset.color ? 2 : 0)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.white.opacity(0.02))
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1),
                alignment: .top
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Drawing Algorithms
    private func drawStroke(_ stroke: WhiteboardStroke, in context: inout GraphicsContext) {
        guard stroke.points.count > 1 else { return }
        
        switch stroke.brushType {
        case .solid:
            var path = Path()
            path.move(to: stroke.points[0])
            for point in stroke.points.dropFirst() {
                path.addLine(to: point)
            }
            context.stroke(
                path,
                with: .color(stroke.color),
                style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round)
            )
            
        case .laser:
            var path = Path()
            path.move(to: stroke.points[0])
            for point in stroke.points.dropFirst() {
                path.addLine(to: point)
            }
            // Glow layer (wider, lower opacity)
            context.stroke(
                path,
                with: .color(stroke.color.opacity(0.35)),
                style: StrokeStyle(lineWidth: stroke.width + 6, lineCap: .round, lineJoin: .round)
            )
            // Hot core layer (thin, white)
            context.stroke(
                path,
                with: .color(.white),
                style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round)
            )
            
        case .cosmic:
            // Render deterministic starry particles based on point coordinates to prevent frame-to-frame flickering
            for point in stroke.points {
                let seed = Int(point.x * 1000 + point.y)
                // Draw 5 stars at deterministic offsets
                for k in 0..<5 {
                    let offsetSeed = Double((seed ^ (k * 54321)) & 0xFFFF) / 65535.0
                    let angle = offsetSeed * 2.0 * Double.pi
                    let distance = offsetSeed * Double(stroke.width) * 2.0
                    
                    let px = point.x + CGFloat(cos(angle)) * CGFloat(distance)
                    let py = point.y + CGFloat(sin(angle)) * CGFloat(distance)
                    let pSize = CGFloat(1.5 + sin(offsetSeed * 10.0) * 1.0)
                    let alpha = 0.35 + 0.55 * cos(offsetSeed * 15.0)
                    
                    let particle = Path(ellipseIn: CGRect(x: px - pSize/2, y: py - pSize/2, width: pSize, height: pSize))
                    context.fill(particle, with: .color(stroke.color.opacity(alpha)))
                }
            }
        }
    }
    
    // MARK: - History Methods
    private func undo() {
        if let popped = strokes.popLast() {
            undoneStrokes.append(popped)
        }
    }
    
    private func redo() {
        if let popped = undoneStrokes.popLast() {
            strokes.append(popped)
        }
    }
}
