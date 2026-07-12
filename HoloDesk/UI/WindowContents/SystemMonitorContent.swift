// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Performance Diagnostics Engine

/// Manages real-time background diagnostics for HoloDesk.
/// Decouples UI rendering from thread polling using visionOS 2.0+ standard Observation.
@MainActor @Observable
final class PerformanceDiagnostics {
    var cpuUsage: Double = 0.34
    var memoryUsage: Double = 0.62
    var batteryLevel: Double = 0.78
    var thermalState = "Nominal"
    var cpuHistory: [Double] = (0..<30).map { _ in Double.random(in: 0.15...0.6) }
    
    private var isAnimating = false
    private var monitorTask: Task<Void, Never>?
    
    func startMonitoring() {
        guard !isAnimating else { return }
        isAnimating = true
        monitorTask = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                } catch {
                    break
                }
                guard let self = self, self.isAnimating else { break }
                withAnimation(.easeInOut(duration: 1.0)) {
                    self.cpuUsage = Double.random(in: 0.15...0.65)
                    self.memoryUsage = Double.random(in: 0.55...0.75)
                    if !self.cpuHistory.isEmpty {
                        self.cpuHistory.removeFirst()
                    }
                    self.cpuHistory.append(self.cpuUsage)
                }
            }
        }
    }
    
    func stopMonitoring() {
        isAnimating = false
        monitorTask?.cancel()
        monitorTask = nil
    }
    
    deinit {
        // Task automatically stops when self is deallocated due to weak self reference.
    }
}

// MARK: - Safe Timer Wrapper for Non-isolated deinit
fileprivate final class TimerBox: @unchecked Sendable {
    var timer: Timer?
    func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}


// MARK: - System Monitor Content

/// Real-time system monitoring — CPU, memory, battery, storage, network.
struct SystemMonitorContent: View {
    
    @State private var diagnostics = PerformanceDiagnostics()
    
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
                    Circle().fill(diagnostics.thermalState == "Nominal" ? .green : .orange).frame(width: 6, height: 6)
                    Text(diagnostics.thermalState)
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            
            // Gauges
            HStack(spacing: 14) {
                gaugeView("CPU", value: diagnostics.cpuUsage, color: .cyan, detail: "\(Int(diagnostics.cpuUsage * 100))%")
                gaugeView("RAM", value: diagnostics.memoryUsage, color: .orange, detail: "6.2 GB")
                gaugeView("Battery", value: diagnostics.batteryLevel, color: diagnostics.batteryLevel < 0.2 ? .red : .green, detail: "\(Int(diagnostics.batteryLevel * 100))%")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            
            // CPU Cores 8-Thread Grid
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("CPU Cores (8-Thread Activity)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white.opacity(0.3))
                    Spacer()
                    Text("Real-time DSP")
                        .font(.system(size: 7, weight: .semibold))
                        .foregroundStyle(Color.holoPrimary.opacity(0.5))
                }
                
                TimelineView(.periodic(from: .now, by: 1.0/30.0)) { timeline in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    
                    Canvas { context, size in
                        let coreCount = 8
                        let spacing: CGFloat = 4
                        let padding: CGFloat = 6
                        let totalSpacing = spacing * CGFloat(coreCount - 1)
                        let colWidth = (size.width - padding * 2 - totalSpacing) / CGFloat(coreCount)
                        
                        for core in 0..<coreCount {
                            let x = padding + CGFloat(core) * (colWidth + spacing)
                            
                            // Detuned frequencies for dynamic independent core simulation
                            let freq = 1.6 + Double(core) * 0.32
                            let offset = Double(core) * 1.8
                            
                            let s1 = sin(time * freq + offset)
                            let s2 = sin(time * freq * 2.3 + offset * 0.5) * 0.35
                            let s3 = cos(time * freq * 4.9) * 0.12
                            
                            // Deterministic time-based high-speed jitter to replace memory-allocating Double.random
                            let jitter = sin(time * 25.0 + Double(core) * 3.14) * 0.04
                            
                            var activity = 0.45 + 0.4 * s1 + 0.12 * s2 + 0.08 * s3 + jitter
                            activity = activity * (0.55 + diagnostics.cpuUsage * 0.9)
                            activity = max(0.06, min(0.96, activity))
                            
                            // Background track for core
                            let colRect = CGRect(x: x, y: 0, width: colWidth, height: size.height)
                            context.fill(
                                Path(roundedRect: colRect, cornerRadius: 2.5),
                                with: .color(.white.opacity(0.04))
                            )
                            
                            // Active thread fill
                            let activeHeight = size.height * CGFloat(activity)
                            let activeRect = CGRect(
                                x: x,
                                y: size.height - activeHeight,
                                width: colWidth,
                                height: activeHeight
                            )
                            
                            // Gradient color: Cyan to Purple to mimic Liquid Glass
                            let gradient = Gradient(colors: [
                                Color.holoTertiary,
                                Color.holoSecondary,
                                Color.holoPrimary
                            ])
                            
                            context.fill(
                                Path(roundedRect: activeRect, cornerRadius: 2.5),
                                with: .linearGradient(
                                    gradient,
                                    startPoint: CGPoint(x: x, y: size.height),
                                    endPoint: CGPoint(x: x, y: size.height - activeHeight)
                                )
                            )
                            
                            // Segmented meter grid incisions
                            let segmentCount = 8
                            for seg in 1..<segmentCount {
                                let y = size.height * CGFloat(seg) / CGFloat(segmentCount)
                                context.stroke(
                                    Path { p in
                                        p.move(to: CGPoint(x: x - 0.5, y: y))
                                        p.addLine(to: CGPoint(x: x + colWidth + 0.5, y: y))
                                    },
                                    with: .color(.black.opacity(0.45)),
                                    lineWidth: 1.0
                                )
                            }
                        }
                    }
                }
                .frame(height: 54)
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
            
            // Storage & Network
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Storage")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                    
                    ShimmerProgressBar(value: 0.67, color: Color.holoSecondary)
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
                    .frame(height: 6)
                    Spacer(minLength: 4)
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 12)
        }
        .onAppear {
            diagnostics.startMonitoring()
        }
        .onDisappear {
            diagnostics.stopMonitoring()
        }
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
                
                // Sweep caustics glint overlay inside circular gauge
                Circle()
                    .trim(from: 0, to: value)
                    .stroke(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.45), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-90))
                    .blendMode(.screen)
                
                Text(detail)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
            }
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
        }
    }
}

// MARK: - Shimmer Progress Bar
struct ShimmerProgressBar: View {
    var value: Double
    var color: Color
    
    @State private var sweepOffset: CGFloat = -1.5
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.08))
                    .frame(height: 6)
                
                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * CGFloat(value), height: 6)
                    .overlay(
                        // Moving screen-blended caustics sweep layer
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .white.opacity(0.6), .clear],
                                    startPoint: UnitPoint(x: sweepOffset, y: 0),
                                    endPoint: UnitPoint(x: sweepOffset + 0.35, y: 0)
                                )
                            )
                            .blendMode(.screen)
                    )
                    .clipShape(Capsule())
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                sweepOffset = 1.5
            }
        }
    }
}
