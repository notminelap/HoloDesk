// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Widget System

/// Mini spatial widgets — Clock, Calculator, Translator, Quick Note, Stopwatch.
enum WidgetType: String, CaseIterable, Identifiable {
    case clock
    case calculator
    case quickNote
    case stopwatch
    case worldClock
    case unitConverter
    
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .clock:         return "Clock"
        case .calculator:    return "Calculator"
        case .quickNote:     return "Quick Note"
        case .stopwatch:     return "Stopwatch"
        case .worldClock:    return "World Clock"
        case .unitConverter: return "Converter"
        }
    }
    var emoji: String {
        switch self {
        case .clock:         return "🕐"
        case .calculator:    return "🔢"
        case .quickNote:     return "📌"
        case .stopwatch:     return "⏱️"
        case .worldClock:    return "🌍"
        case .unitConverter: return "📐"
        }
    }
    var iconName: String {
        switch self {
        case .clock:         return "clock.fill"
        case .calculator:    return "plusminus"
        case .quickNote:     return "pin.fill"
        case .stopwatch:     return "stopwatch.fill"
        case .worldClock:    return "globe"
        case .unitConverter: return "arrow.left.arrow.right"
        }
    }
}

// MARK: - Clock Widget

struct ClockWidgetView: View {
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 6) {
            Text(currentTime, style: .time)
                .font(.system(size: 32, weight: .thin, design: .rounded))
                .foregroundStyle(.white)
            
            Text(currentTime, style: .date)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.5))
            
            // Analog clock face
            ZStack {
                Circle()
                    .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                    .frame(width: 80, height: 80)
                
                // Hour markers
                ForEach(0..<12, id: \.self) { i in
                    Rectangle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 1, height: i % 3 == 0 ? 8 : 4)
                        .offset(y: -35)
                        .rotationEffect(.degrees(Double(i) * 30))
                }
                
                // Hour hand
                Rectangle()
                    .fill(.white.opacity(0.8))
                    .frame(width: 2, height: 22)
                    .offset(y: -11)
                    .rotationEffect(.degrees(hourAngle))
                
                // Minute hand
                Rectangle()
                    .fill(.white.opacity(0.6))
                    .frame(width: 1.5, height: 30)
                    .offset(y: -15)
                    .rotationEffect(.degrees(minuteAngle))
                
                // Second hand
                Rectangle()
                    .fill(.holoPrimary)
                    .frame(width: 0.5, height: 32)
                    .offset(y: -16)
                    .rotationEffect(.degrees(secondAngle))
                
                Circle().fill(.holoPrimary).frame(width: 4, height: 4)
            }
        }
        .padding(14)
        .onReceive(timer) { currentTime = $0 }
    }
    
    private var hourAngle: Double {
        let cal = Calendar.current
        let h = Double(cal.component(.hour, from: currentTime) % 12)
        let m = Double(cal.component(.minute, from: currentTime))
        return (h + m / 60) * 30
    }
    private var minuteAngle: Double {
        let m = Double(Calendar.current.component(.minute, from: currentTime))
        return m * 6
    }
    private var secondAngle: Double {
        let s = Double(Calendar.current.component(.second, from: currentTime))
        return s * 6
    }
}

// MARK: - Calculator Widget

struct CalculatorWidgetView: View {
    @Environment(SpatialAudioManager.self) private var audio
    @State private var display = "0"
    @State private var operand: Double = 0
    @State private var operation: String?
    @State private var isNewInput = true
    
    private let buttons: [[String]] = [
        ["C", "±", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["0", ".", "=", ""]
    ]
    
    var body: some View {
        VStack(spacing: 6) {
            // Display
            Text(display)
                .font(.system(size: 28, weight: .thin, design: .monospaced))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 10)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            // Buttons
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { btn in
                        if !btn.isEmpty {
                            calcButton(btn)
                        }
                    }
                }
            }
        }
        .padding(10)
    }
    
    private func calcButton(_ label: String) -> some View {
        let isOp = ["÷", "×", "−", "+", "="].contains(label)
        let isFunc = ["C", "±", "%"].contains(label)
        
        return Button {
            handleTap(label)
        } label: {
            Text(label)
                .font(.system(size: 16, weight: isOp ? .medium : .regular))
                .foregroundStyle(isOp ? .holoPrimary : isFunc ? .white.opacity(0.6) : .white.opacity(0.85))
                .frame(width: label == "0" ? 70 : 32, height: 32)
                .innerGlass(cornerRadius: 8)
        }
        .buttonStyle(.plain)
    }
    
    private func handleTap(_ btn: String) {
        audio.playSFX(.tap)
        switch btn {
        case "C":
            display = "0"; operand = 0; operation = nil; isNewInput = true
        case "±":
            if let val = Double(display) { display = String(val * -1) }
        case "%":
            if let val = Double(display) { display = String(val / 100) }
        case "÷", "×", "−", "+":
            operand = Double(display) ?? 0
            operation = btn
            isNewInput = true
        case "=":
            guard let op = operation, let current = Double(display) else { return }
            var result: Double = 0
            switch op {
            case "÷": result = operand / (current == 0 ? 1 : current)
            case "×": result = operand * current
            case "−": result = operand - current
            case "+": result = operand + current
            default: break
            }
            display = result.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(result)) : String(format: "%.4g", result)
            operation = nil
            isNewInput = true
        default:
            if isNewInput { display = ""; isNewInput = false }
            if btn == "." && display.contains(".") { return }
            display += btn
            if display.first == "0" && display.count > 1 && !display.contains(".") {
                display = String(display.dropFirst())
            }
        }
        HapticManager.shared.lightTap()
    }
}

// MARK: - Quick Note Widget

struct QuickNoteWidgetView: View {
    @Environment(SpatialAudioManager.self) private var audio
    @State private var noteText = ""
    @State private var savedNotes: [String] = ["Ship v1.0 🚀", "Call Alex @ 3pm", "Buy groceries"]
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "pin.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.yellow)
                Text("Quick Notes")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
            }
            
            // Input
            HStack(spacing: 6) {
                TextField("New note...", text: $noteText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .innerGlass(cornerRadius: 8)
                
                Button {
                    guard !noteText.isEmpty else { return }
                    savedNotes.insert(noteText, at: 0)
                    noteText = ""
                    audio.playSFX(.tap)
                    HapticManager.shared.lightTap()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.yellow)
                }
                .buttonStyle(.plain)
            }
            
            // Notes list
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(Array(savedNotes.enumerated()), id: \.offset) { index, note in
                        HStack {
                            Text("•")
                                .foregroundStyle(.yellow.opacity(0.5))
                            Text(note)
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.75))
                            Spacer()
                            Button {
                                savedNotes.remove(at: index)
                                audio.playSFX(.tap)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 7, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .padding(12)
    }
}

// MARK: - Stopwatch Widget

struct StopwatchWidgetView: View {
    @Environment(SpatialAudioManager.self) private var audio
    @State private var elapsed: TimeInterval = 0
    @State private var isRunning = false
    @State private var laps: [TimeInterval] = []
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 10) {
            Text(formatTime(elapsed))
                .font(.system(size: 28, weight: .thin, design: .monospaced))
                .foregroundStyle(.white)
            
            HStack(spacing: 12) {
                Button {
                    audio.playSFX(.tap)
                    if isRunning {
                        timer?.invalidate()
                        isRunning = false
                    } else {
                        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                            elapsed += 0.01
                        }
                        isRunning = true
                    }
                } label: {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(isRunning ? .holoWarning : .holoSuccess)
                        .frame(width: 36, height: 28)
                        .innerGlass(cornerRadius: 8)
                }
                .buttonStyle(.plain)
                
                Button {
                    audio.playSFX(.tap)
                    if isRunning {
                        laps.insert(elapsed, at: 0)
                    } else {
                        elapsed = 0; laps.removeAll()
                    }
                } label: {
                    Image(systemName: isRunning ? "flag.fill" : "arrow.counterclockwise")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(width: 36, height: 28)
                        .innerGlass(cornerRadius: 8)
                }
                .buttonStyle(.plain)
            }
            
            if !laps.isEmpty {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(Array(laps.enumerated()), id: \.offset) { i, lap in
                            HStack {
                                Text("Lap \(laps.count - i)")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.4))
                                Spacer()
                                Text(formatTime(lap))
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                    }
                }
                .frame(maxHeight: 60)
            }
        }
        .padding(12)
        .onDisappear {
            timer?.invalidate()
            timer = nil
            isRunning = false
        }
    }
    
    private func formatTime(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        let ms = Int((t.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", m, s, ms)
    }
}

// MARK: - World Clock Widget

struct WorldClockWidgetView: View {
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private let zones: [(city: String, tz: String, emoji: String)] = [
        ("San Francisco", "America/Los_Angeles", "🌉"),
        ("New York", "America/New_York", "🗽"),
        ("London", "Europe/London", "🇬🇧"),
        ("Tokyo", "Asia/Tokyo", "🗼"),
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(zones, id: \.tz) { zone in
                HStack(spacing: 8) {
                    Text(zone.emoji)
                        .font(.system(size: 14))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(zone.city)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                        Text(timeIn(zone: zone.tz))
                            .font(.system(size: 16, weight: .thin, design: .monospaced))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .innerGlass(cornerRadius: 8)
            }
        }
        .padding(12)
        .onReceive(timer) { currentTime = $0 }
    }
    
    private func timeIn(zone tz: String) -> String {
        let fmt = DateFormatter()
        fmt.timeZone = TimeZone(identifier: tz)
        fmt.dateFormat = "h:mm a"
        return fmt.string(from: currentTime)
    }
}

// MARK: - Unit Converter Widget

struct UnitConverterWidgetView: View {
    @Environment(SpatialAudioManager.self) private var audio
    @State private var inputValue = "1"
    @State private var selectedUnit = 0 // 0: Length, 1: Weight, 2: Temp
    
    private let categories = ["Length", "Weight", "Temp"]
    
    var body: some View {
        VStack(spacing: 8) {
            // Category picker
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Button {
                        selectedUnit = i
                        audio.playSFX(.tap)
                    } label: {
                        Text(categories[i])
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(selectedUnit == i ? .white : .white.opacity(0.4))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .innerGlass(cornerRadius: 6)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Input
            TextField("Value", text: $inputValue)
                .textFieldStyle(.plain)
                .font(.system(size: 20, weight: .thin, design: .monospaced))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(8)
                .innerGlass(cornerRadius: 10)
            
            // Results
            VStack(spacing: 4) {
                ForEach(conversions, id: \.label) { item in
                    HStack {
                        Text(item.label)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(0.4))
                        Spacer()
                        Text(item.value)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
            .padding(8)
            .innerGlass(cornerRadius: 8)
        }
        .padding(10)
    }
    
    private var conversions: [(label: String, value: String)] {
        let v = Double(inputValue) ?? 0
        switch selectedUnit {
        case 0: return [
            ("km", String(format: "%.3f", v * 1.60934)),
            ("m", String(format: "%.1f", v * 1609.34)),
            ("ft", String(format: "%.1f", v * 5280)),
            ("in", String(format: "%.0f", v * 63360)),
        ]
        case 1: return [
            ("kg", String(format: "%.2f", v * 0.453592)),
            ("g", String(format: "%.1f", v * 453.592)),
            ("oz", String(format: "%.1f", v * 16)),
            ("st", String(format: "%.2f", v / 14)),
        ]
        default: return [
            ("°C", String(format: "%.1f", (v - 32) * 5/9)),
            ("K", String(format: "%.1f", (v - 32) * 5/9 + 273.15)),
            ("°R", String(format: "%.1f", v + 459.67)),
        ]
        }
    }
}

// MARK: - Widget Container

struct WidgetContainerView: View {
    let type: WidgetType
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack(spacing: 6) {
                Image(systemName: type.iconName)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))
                Text(type.displayName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(.ultraThinMaterial.opacity(0.3))
            
            // Content
            widgetContent
        }
        .frame(width: widgetSize.width, height: widgetSize.height)
        .glassBackground(cornerRadius: 18)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    @ViewBuilder
    private var widgetContent: some View {
        switch type {
        case .clock:         ClockWidgetView()
        case .calculator:    CalculatorWidgetView()
        case .quickNote:     QuickNoteWidgetView()
        case .stopwatch:     StopwatchWidgetView()
        case .worldClock:    WorldClockWidgetView()
        case .unitConverter: UnitConverterWidgetView()
        }
    }
    
    private var widgetSize: CGSize {
        switch type {
        case .clock:         return CGSize(width: 200, height: 220)
        case .calculator:    return CGSize(width: 200, height: 280)
        case .quickNote:     return CGSize(width: 220, height: 240)
        case .stopwatch:     return CGSize(width: 200, height: 220)
        case .worldClock:    return CGSize(width: 200, height: 220)
        case .unitConverter: return CGSize(width: 200, height: 280)
        }
    }
}
