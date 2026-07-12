// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - 3D Model Viewer Content

/// USDZ 3D model viewer with rotation, zoom, and model picker.
struct ModelViewerContent: View {
    
    @State private var rotation: Double = 0
    @State private var selectedModel: Model3D = .globe
    @State private var isRotating = true
    @State private var zoom: CGFloat = 1.0
    @State private var rotationTimer: Timer?
    
    enum Model3D: String, CaseIterable, Identifiable {
        case globe = "Globe"
        case cube = "Cube"
        case cone = "Cone"
        case torus = "Torus"
        case cylinder = "Cylinder"
        case capsule = "Capsule"
        
        var id: String { rawValue }
        var systemImage: String {
            switch self {
            case .globe:    return "globe"
            case .cube:     return "cube"
            case .cone:     return "cone"
            case .torus:    return "torus"
            case .cylinder: return "cylinder"
            case .capsule:  return "capsule"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 8) {
                ForEach(Model3D.allCases) { model in
                    Button {
                        selectedModel = model
                    } label: {
                        Image(systemName: model.systemImage)
                            .font(.system(size: 14))
                            .foregroundStyle(selectedModel == model ? Color.holoPrimary : Color.white.opacity(0.3))
                            .frame(width: 28, height: 28)
                            .innerGlass(cornerRadius: 6)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                
                Toggle(isOn: $isRotating) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .labelsHidden()
                .tint(.holoPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.black.opacity(0.15))
            
            // 3D Preview
            ZStack {
                Color(white: 0.04)
                
                // Grid floor
                gridFloor
                
                // Model visualization
                modelView
                    .scaleEffect(zoom)
                    .rotationEffect(.degrees(rotation))
                    .gesture(
                        MagnifyGesture()
                            .onChanged { value in
                                zoom = min(max(value.magnification, 0.5), 2.5)
                            }
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                rotation += Double(value.translation.width) * 0.5
                            }
                    )
            }
            
            // Info bar
            HStack {
                Text(selectedModel.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("Vertices: \(vertexCount)")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
                
                Text("Zoom: \(Int(zoom * 100))%")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.black.opacity(0.15))
        }
        .onAppear { autoRotate() }
        .onDisappear {
            rotationTimer?.invalidate()
            rotationTimer = nil
        }
        .onChange(of: isRotating) { _, newValue in
            if newValue {
                autoRotate()
            } else {
                rotationTimer?.invalidate()
                rotationTimer = nil
            }
        }
    }
    
    @ViewBuilder
    private var modelView: some View {
        switch selectedModel {
        case .globe:
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue.opacity(0.4), .green.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle().strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                    )
                // Latitude lines
                ForEach(0..<5, id: \.self) { i in
                    Ellipse()
                        .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
                        .frame(width: 120, height: CGFloat(20 + i * 25))
                }
                // Meridian
                Ellipse()
                    .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
                    .frame(width: 50, height: 120)
            }
        case .cube:
            RoundedRectangle(cornerRadius: 4)
                .fill(LinearGradient(colors: [.orange.opacity(0.5), .red.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 100, height: 100)
                .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(.white.opacity(0.2), lineWidth: 0.5))
                .rotation3DEffect(.degrees(rotation * 0.3), axis: (x: 0.3, y: 1, z: 0.1))
        case .cone:
            Triangle()
                .fill(LinearGradient(colors: [.purple.opacity(0.5), .indigo.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                .frame(width: 100, height: 120)
                .overlay(Triangle().stroke(Color.white.opacity(0.2), lineWidth: 0.5))
        case .torus:
            Circle()
                .strokeBorder(LinearGradient(colors: [.cyan.opacity(0.6), .teal.opacity(0.3)], startPoint: .top, endPoint: .bottom), lineWidth: 20)
                .frame(width: 110, height: 110)
        case .cylinder:
            RoundedRectangle(cornerRadius: 40)
                .fill(LinearGradient(colors: [.green.opacity(0.5), .mint.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
                .frame(width: 80, height: 120)
                .overlay(RoundedRectangle(cornerRadius: 40).strokeBorder(.white.opacity(0.2), lineWidth: 0.5))
        case .capsule:
            Capsule()
                .fill(LinearGradient(colors: [.pink.opacity(0.5), .red.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                .frame(width: 60, height: 120)
                .overlay(Capsule().strokeBorder(.white.opacity(0.2), lineWidth: 0.5))
        }
    }
    
    private var gridFloor: some View {
        Canvas { context, size in
            let step: CGFloat = 20
            let center = CGPoint(x: size.width / 2, y: size.height * 0.75)
            for i in -5...5 {
                // Horizontal
                context.stroke(Path { p in
                    p.move(to: CGPoint(x: 0, y: center.y + CGFloat(i) * step * 0.4))
                    p.addLine(to: CGPoint(x: size.width, y: center.y + CGFloat(i) * step * 0.4))
                }, with: .color(.white.opacity(0.03)), lineWidth: 0.5)
                // Vertical (perspective)
                let x = center.x + CGFloat(i) * step
                context.stroke(Path { p in
                    p.move(to: CGPoint(x: x, y: center.y - 40))
                    p.addLine(to: CGPoint(x: x, y: size.height))
                }, with: .color(.white.opacity(0.03)), lineWidth: 0.5)
            }
        }
    }
    
    private var vertexCount: String {
        switch selectedModel {
        case .globe:    return "2,562"
        case .cube:     return "8"
        case .cone:     return "129"
        case .torus:    return "1,024"
        case .cylinder: return "66"
        case .capsule:  return "386"
        }
    }
    
    private func autoRotate() {
        rotationTimer?.invalidate()
        rotationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            Task { @MainActor in
                guard isRotating else { return }
                withAnimation(.linear(duration: 0.05)) {
                    rotation += 0.5
                }
            }
        }
    }
}

// MARK: - Triangle Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
