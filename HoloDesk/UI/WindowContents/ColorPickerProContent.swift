// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Color Picker Pro

struct ColorPickerProContent: View {
    @State private var hue: Double = 0.6
    @State private var sat: Double = 0.7
    @State private var bri: Double = 0.85
    @State private var alpha: Double = 1.0
    @State private var recent: [Color] = [.blue, .red, .green, .purple, .orange, .cyan, .pink, .yellow]
    
    private var current: Color { Color(hue: hue, saturation: sat, brightness: bri, opacity: alpha) }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "paintpalette.fill").foregroundStyle(current)
                Text("Color Picker").font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Image(systemName: "eyedropper").font(.system(size: 14)).foregroundStyle(.white.opacity(0.5))
            }.padding(.horizontal, 14).padding(.top, 10)
            
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 10).fill(current).frame(width: 60, height: 60)
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.white.opacity(0.15), lineWidth: 1))
                VStack(alignment: .leading, spacing: 3) {
                    Text("#\(hexString)").font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundStyle(.white)
                    HStack(spacing: 6) {
                        cv("H", "\(Int(hue*360))°"); cv("S", "\(Int(sat*100))%"); cv("B", "\(Int(bri*100))%")
                    }
                }
            }.padding(.horizontal, 14)
            
            // 2D gradient
            GeometryReader { geo in
                ZStack {
                    LinearGradient(colors: [.white, Color(hue: hue, saturation: 1, brightness: 1)], startPoint: .leading, endPoint: .trailing)
                    LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                    Circle().strokeBorder(.white, lineWidth: 2).frame(width: 14, height: 14)
                        .position(x: geo.size.width * sat, y: geo.size.height * (1 - bri))
                }.clipShape(RoundedRectangle(cornerRadius: 8))
                .gesture(DragGesture(minimumDistance: 0).onChanged { v in
                    sat = min(max(v.location.x / geo.size.width, 0), 1)
                    bri = min(max(1 - v.location.y / geo.size.height, 0), 1)
                })
            }.frame(height: 80).padding(.horizontal, 14)
            
            // Hue rainbow
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    LinearGradient(colors: (0...10).map { Color(hue: Double($0)/10, saturation: 1, brightness: 1) }, startPoint: .leading, endPoint: .trailing)
                        .frame(height: 12).clipShape(Capsule())
                    Circle().fill(.white).frame(width: 16, height: 16).shadow(radius: 2).offset(x: geo.size.width * hue - 8)
                }.gesture(DragGesture(minimumDistance: 0).onChanged { v in hue = min(max(v.location.x / geo.size.width, 0), 1) })
            }.frame(height: 16).padding(.horizontal, 14)
            
            Slider(value: $alpha, in: 0...1).tint(current).padding(.horizontal, 14)
            
            HStack(spacing: 4) {
                ForEach(0..<8, id: \.self) { i in
                    Circle().fill(recent[i]).frame(width: 20, height: 20)
                        .overlay(Circle().strokeBorder(.white.opacity(0.15), lineWidth: 0.5))
                }
                Spacer()
            }.padding(.horizontal, 14).padding(.bottom, 8)
        }
    }
    
    private func cv(_ l: String, _ v: String) -> some View {
        HStack(spacing: 2) { Text(l).font(.system(size: 8, weight: .bold)).foregroundStyle(.white.opacity(0.3)); Text(v).font(.system(size: 9, design: .monospaced)).foregroundStyle(.white.opacity(0.6)) }
    }
    private var hexString: String { String(format: "%02X%02X%02X", Int(hue*255), Int(sat*255), Int(bri*255)) }
}
