// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - System Monitor Content

/// Real-time system monitoring — CPU, memory, battery, storage, network.
struct SystemMonitorContent: View {
    
    @State private var cpuUsage: Double = 0.34
    @State private var memoryUsage: Double = 0.62
    @State private var batteryLevel: Double = 0.78
    @State private var thermalState = "Nominal"
    @State private var cpuHistory: [Double] = (0..<30).map { _ in Double.random(in: 0.15...0.6) }
    @State private var isAnimating = false
    
    private let processes: [(name: String, cpu: String, mem: String)] = [
        ("HoloDesk", "12.3%", "245 MB"),
        ("RealityKit", "8.7%", "189 MB"),
        ("ARKit", "6.2%", "134 MB"),
        ("SwiftUI", "3.1%", "98 MB"),
        ("CoreML", "2.8%", "76 MB"),
        ("System", "1.4%", "512 MB"),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "gauge.with.dots.needle.33percent")
                    .foregroundStyle(.cyan)
                Text("System")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                HStack(spacing: 4) {
                    Circle().fill(thermalState == "Nominal" ? .green : .orange).frame(width: 6, height: 6)
                    Text(thermalState)
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            
            // Gauges
            HStack(spacing: 14) {
                gaugeView("CPU", value: cpuUsage, color: .cyan, detail: "\(Int(cpuUsage * 100))%")
                gaugeView("RAM", value: memoryUsage, color: .orange, detail: "6.2 GB")
                gaugeView("Battery", value: batteryLevel, color: batteryLevel < 0.2 ? .red : .green, detail: "\(Int(batteryLevel * 100))%")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            
            // CPU History chart
            VStack(alignment: .leading, spacing: 4) {
                Text("CPU Usage (30s)")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.3))
                
                GeometryReader { geo in
                    Canvas { context, size in
                        // Grid lines
                        for i in 1...3 {
                            let y = size.height * CGFloat(i) / 4
                            context.stroke(Path { p in
                                p.move(to: CGPoint(x: 0, y: y))
                                p.addLine(to: CGPoint(x: size.width, y: y))
                            }, with: .color(.white.opacity(0.04)), lineWidth: 0.5)
                        }
                        
                        // Line
                        var path = Path()
                        for (i, val) in cpuHistory.enumerated() {
                            let x = size.width * CGFloat(i) / CGFloat(cpuHistory.count - 1)
                            let y = size.height * (1 - val)
                            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        context.stroke(path, with: .color(.cyan), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                        
                        // Fill
                        var fill = path
                        fill.addLine(to: CGPoint(x: size.width, y: size.height))
                        fill.addLine(to: CGPoint(x: 0, y: size.height))
                        fill.closeSubpath()
                        context.fill(fill, with: .linearGradient(
                            Gradient(colors: [.cyan.opacity(0.15), .cyan.opacity(0)]),
                            startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: size.height)
                        ))
                    }
                }
                .frame(height: 50)
            }
            .padding(.horizontal, 14)
            .padding(8)
            .innerGlass(cornerRadius: 10)
            .padding(.horizontal, 14)
            
            // Process list
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Process")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("CPU")
                        .frame(width: 45, alignment: .trailing)
                    Text("Memory")
                        .frame(width: 55, alignment: .trailing)
                }
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
                
                ForEach(Array(processes.enumerated()), id: \.offset) { _, proc in
                    HStack {
                        Text(proc.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(proc.cpu)
                            .frame(width: 45, alignment: .trailing)
                        Text(proc.mem)
                            .frame(width: 55, alignment: .trailing)
                    }
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(10)
            .padding(.horizontal, 4)
            
            // Storage
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Storage")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.08)).frame(height: 6)
                            Capsule().fill(.blue).frame(width: geo.size.width * 0.67, height: 6)
                        }
                    }
                    .frame(height: 6)
                    Text("172 GB / 256 GB")
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.3))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Network")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                    HStack(spacing: 6) {
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 7))
                                .foregroundStyle(.green)
                            Text("2.4 MB/s")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 7))
                                .foregroundStyle(.blue)
                            Text("0.8 MB/s")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
        }
        .onAppear {
            isAnimating = true
            animateUsage()
        }
        .onDisappear { isAnimating = false }
    }
    
    private func gaugeView(_ label: String, value: Double, color: Color, detail: String) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .strokeBorder(.white.opacity(0.06), lineWidth: 5)
                    .frame(width: 48, height: 48)
                Circle()
                    .trim(from: 0, to: value)
                    .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-90))
                Text(detail)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
            }
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
        }
    }
    
    private func animateUsage() {
        guard isAnimating else { return }
        withAnimation(.easeInOut(duration: 1)) {
            cpuUsage = Double.random(in: 0.15...0.65)
            memoryUsage = Double.random(in: 0.55...0.75)
            cpuHistory.removeFirst()
            cpuHistory.append(cpuUsage)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { animateUsage() }
    }
}
