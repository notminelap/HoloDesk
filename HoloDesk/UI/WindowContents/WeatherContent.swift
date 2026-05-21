// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Weather Window Content

/// Apple Weather-inspired spatial weather panel with animated backgrounds,
/// hourly forecast strip, 5-day outlook, and atmospheric details.
struct WeatherContent: View {
    
    @State private var animationPhase: Double = 0
    
    private let hourlyData: [(hour: String, icon: String, temp: Int)] = [
        ("Now", "sun.max.fill", 24),
        ("1PM", "cloud.sun.fill", 25),
        ("2PM", "cloud.sun.fill", 26),
        ("3PM", "cloud.fill", 25),
        ("4PM", "cloud.fill", 23),
        ("5PM", "cloud.sun.rain.fill", 22),
        ("6PM", "cloud.rain.fill", 20),
        ("7PM", "cloud.moon.fill", 19),
        ("8PM", "moon.stars.fill", 18),
    ]
    
    private let dailyData: [(day: String, icon: String, high: Int, low: Int)] = [
        ("Today",     "sun.max.fill",       26, 18),
        ("Tomorrow",  "cloud.sun.fill",     24, 17),
        ("Wednesday", "cloud.fill",         22, 16),
        ("Thursday",  "cloud.rain.fill",    20, 14),
        ("Friday",    "cloud.sun.rain.fill",23, 15),
        ("Saturday",  "sun.max.fill",       27, 19),
        ("Sunday",    "sun.max.fill",       28, 20),
    ]
    
    var body: some View {
        ZStack {
            // Animated sky gradient background
            skyGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // Main temperature
                    mainTemperature
                    
                    // Hourly forecast strip
                    hourlyForecast
                    
                    // Daily forecast
                    dailyForecast
                    
                    // Atmospheric details grid
                    atmosphericGrid
                }
                .padding(14)
            }
        }
    }
    
    // MARK: - Sky Background
    
    private var skyGradient: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            
            // Shifting sky background based on time and potential lightning activity
            let lightningIntensity = abs(sin(time * 0.05)) > 0.97 ? (sin(time * 60) > 0 ? 0.35 : 0.0) : 0.0
            
            LinearGradient(
                colors: [
                    Color(hue: 0.58, saturation: 0.6 - lightningIntensity, brightness: 0.85 + lightningIntensity),
                    Color(hue: 0.55, saturation: 0.4, brightness: 0.65 + lightningIntensity * 0.5),
                    Color(hue: 0.60, saturation: 0.3, brightness: 0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(
                // Dynamic sun glow pulsing slowly
                RadialGradient(
                    colors: [Color.yellow.opacity(0.2 + sin(time * 0.5) * 0.03), .clear],
                    center: .init(x: 0.7, y: 0.15),
                    startRadius: 10,
                    endRadius: 130
                )
            )
            .overlay(
                Canvas { context, size in
                    // 1. Render drifting mist/vapor clouds
                    let cloudPositions = [
                        CGPoint(x: size.width * 0.2 + sin(time * 0.04) * 40.0, y: size.height * 0.2),
                        CGPoint(x: size.width * 0.85 + cos(time * 0.03) * 50.0, y: size.height * 0.35)
                    ]
                    
                    for (i, pos) in cloudPositions.enumerated() {
                        let cloudRadius = size.width * (i == 0 ? 0.5 : 0.4)
                        let cloudGradient = Gradient(colors: [
                            Color.white.opacity(0.06),
                            Color.cyan.opacity(0.02),
                            .clear
                        ])
                        context.fill(
                            Path(CGRect(origin: .zero, size: size)),
                            with: .shading(.radialGradient(cloudGradient, center: pos, startRadius: 0, endRadius: cloudRadius))
                        )
                    }
                    
                    // 2. Render falling spatial precipitation rain strokes
                    let rainCount = 45
                    for i in 0..<rainCount {
                        let seedX = Double((i * 79 + 17) % 1000) / 1000.0
                        let seedY = Double((i * 43 + 13) % 1000) / 1000.0
                        
                        let fallSpeed = 380.0 + Double((i * 7) % 5) * 45.0
                        let startY = seedY * size.height + (time * fallSpeed).truncatingRemainder(dividingBy: size.height)
                        let startX = (seedX * size.width - startY * 0.25).truncatingRemainder(dividingBy: size.width)
                        
                        // Keep rain inside bounds
                        let boundedX = startX >= 0 ? startX : (size.width + startX)
                        let boundedY = startY.truncatingRemainder(dividingBy: size.height)
                        
                        let linePath = Path { path in
                            path.move(to: CGPoint(x: boundedX, y: boundedY))
                            path.addLine(to: CGPoint(x: boundedX - 3.5, y: boundedY + 12.0))
                        }
                        
                        context.stroke(
                            linePath,
                            with: .color(.cyan.opacity(0.16 + Double(i % 3) * 0.05)),
                            lineWidth: 0.75
                        )
                    }
                }
            )
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Main Temperature
    
    private var mainTemperature: some View {
        VStack(spacing: 2) {
            Text("Patna")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
            
            HStack(alignment: .top, spacing: 2) {
                Text("24")
                    .font(.system(size: 64, weight: .thin, design: .rounded))
                    .foregroundStyle(.white)
                Text("°")
                    .font(.system(size: 28, weight: .thin))
                    .foregroundStyle(.white.opacity(0.7))
                    .offset(y: 8)
            }
            
            Text("Partly Cloudy")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            
            Text("H: 26°  L: 18°")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.bottom, 4)
    }
    
    // MARK: - Hourly Forecast
    
    private var hourlyForecast: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                Text("HOURLY FORECAST")
                    .font(.system(size: 9, weight: .semibold))
            }
            .foregroundStyle(.white.opacity(0.4))
            
            Divider().overlay(Color.white.opacity(0.1))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Array(hourlyData.enumerated()), id: \.offset) { _, item in
                        VStack(spacing: 6) {
                            Text(item.hour)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
                            
                            Image(systemName: item.icon)
                                .font(.system(size: 18))
                                .foregroundStyle(weatherColor(item.icon))
                                .shadow(color: weatherColor(item.icon).opacity(0.4), radius: 4)
                                .frame(height: 24)
                            
                            Text("\(item.temp)°")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
        )
    }
    
    // MARK: - Daily Forecast
    
    private var dailyForecast: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 10))
                Text("7-DAY FORECAST")
                    .font(.system(size: 9, weight: .semibold))
            }
            .foregroundStyle(.white.opacity(0.4))
            
            Divider().overlay(Color.white.opacity(0.1))
            
            ForEach(Array(dailyData.enumerated()), id: \.offset) { i, day in
                HStack {
                    Text(day.day)
                        .font(.system(size: 12, weight: i == 0 ? .bold : .medium))
                        .foregroundStyle(.white)
                        .frame(width: 70, alignment: .leading)
                    
                    Image(systemName: day.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(weatherColor(day.icon))
                        .frame(width: 28)
                    
                    Text("\(day.low)°")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(width: 24)
                    
                    // Temperature bar
                    GeometryReader { geo in
                        let minTemp = 14.0
                        let maxTemp = 28.0
                        let range = maxTemp - minTemp
                        let lowFrac = (Double(day.low) - minTemp) / range
                        let highFrac = (Double(day.high) - minTemp) / range
                        
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.white.opacity(0.1))
                                .frame(height: 4)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.cyan, .yellow, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * (highFrac - lowFrac), height: 4)
                                .offset(x: geo.size.width * lowFrac)
                        }
                    }
                    .frame(height: 4)
                    
                    Text("\(day.high)°")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 24)
                }
                
                if i < dailyData.count - 1 {
                    Divider().overlay(Color.white.opacity(0.05))
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
        )
    }
    
    // MARK: - Atmospheric Grid
    
    private var atmosphericGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            atmosphericTile(icon: "wind", title: "WIND", value: "12", unit: "km/h", detail: "Gusts: 18 km/h")
            atmosphericTile(icon: "humidity.fill", title: "HUMIDITY", value: "62", unit: "%", detail: "Dew point: 16°")
            atmosphericTile(icon: "eye.fill", title: "VISIBILITY", value: "14", unit: "km", detail: "Clear skies")
            atmosphericTile(icon: "sun.max.fill", title: "UV INDEX", value: "6", unit: "High", detail: "Protection needed")
            atmosphericTile(icon: "thermometer.medium", title: "FEELS LIKE", value: "25", unit: "°", detail: "Slightly warm")
            atmosphericTile(icon: "gauge.with.dots.needle.bottom.50percent", title: "PRESSURE", value: "1013", unit: "hPa", detail: "Stable")
        }
    }
    
    private func atmosphericTile(icon: String, title: String, value: String, unit: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(title)
                    .font(.system(size: 9, weight: .semibold))
            }
            .foregroundStyle(.white.opacity(0.4))
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                Text(unit)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Text(detail)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.ultraThinMaterial.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
        )
    }
    
    // MARK: - Helpers
    
    private func weatherColor(_ icon: String) -> Color {
        if icon.contains("sun") || icon.contains("max") { return .yellow }
        if icon.contains("rain") { return .cyan }
        if icon.contains("cloud") { return .white.opacity(0.8) }
        if icon.contains("moon") || icon.contains("star") { return .indigo }
        return .white
    }
}
