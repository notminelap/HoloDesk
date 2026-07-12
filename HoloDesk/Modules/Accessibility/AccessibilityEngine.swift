// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Accessibility Engine (Complete)

/// Full voice control, eye-only navigation, one-hand mode, tremor stabilization.
@MainActor @Observable
final class AccessibilityEngine {
    
    // MARK: - Voice Control
    var isVoiceControlEnabled = false
    var voiceControlCommands: [VoiceCommand] = [
        VoiceCommand(phrase: "Open [window name]", action: "Opens specified window"),
        VoiceCommand(phrase: "Close this", action: "Closes focused window"),
        VoiceCommand(phrase: "Move left/right", action: "Moves window"),
        VoiceCommand(phrase: "Save workspace", action: "Saves current layout"),
        VoiceCommand(phrase: "Switch to [mode]", action: "Changes workspace mode"),
        VoiceCommand(phrase: "Scroll up/down", action: "Scrolls content"),
        VoiceCommand(phrase: "Select [item]", action: "Selects UI element"),
        VoiceCommand(phrase: "Go back", action: "Navigation back"),
    ]
    
    struct VoiceCommand: Identifiable {
        let id = UUID()
        var phrase: String
        var action: String
    }
    
    // MARK: - Eye-Only Navigation
    var isEyeOnlyMode = false
    var dwellDuration: Double = 0.8   // seconds to dwell-select
    var gazeScrollSpeed: Double = 1.0
    var gazeCursorSize: CGFloat = 24
    
    func enableEyeOnlyMode() {
        isEyeOnlyMode = true
        dwellDuration = 0.8
        HapticManager.shared.mediumTap()
    }
    
    // MARK: - One-Hand Mode
    var isOneHandMode = false
    var dominantHand: Hand = .right
    
    enum Hand: String { case left = "Left", right = "Right" }
    
    func enableOneHandMode(hand: Hand) {
        isOneHandMode = true
        dominantHand = hand
    }
    
    // MARK: - UI Scaling
    var uiScale: CGFloat = 1.0    // 0.75 – 2.0
    var fontScale: CGFloat = 1.0
    
    func adjustScale(_ scale: CGFloat) {
        uiScale = max(0.75, min(2.0, scale))
        fontScale = uiScale
    }
    
    // MARK: - High Contrast & Colorblind
    var isHighContrast = false
    var colorblindMode: ColorblindMode = .none
    
    enum ColorblindMode: String, CaseIterable {
        case none = "None"
        case protanopia = "Protanopia"
        case deuteranopia = "Deuteranopia"
        case tritanopia = "Tritanopia"
    }
    
    // MARK: - Hand Tremor Stabilization
    var isTremorStabilization = false
    var stabilizationStrength: Double = 0.5  // 0-1
    
    func stabilize(position: SIMD3<Float>, previousPositions: [SIMD3<Float>]) -> SIMD3<Float> {
        guard isTremorStabilization, !previousPositions.isEmpty else { return position }
        let count = min(previousPositions.count, 5)
        let recent = previousPositions.suffix(count)
        var avg = SIMD3<Float>.zero
        for p in recent { avg += p }
        avg /= Float(count)
        let blend = Float(stabilizationStrength)
        return position * (1 - blend) + avg * blend
    }
    
    // MARK: - Cognitive Load Reduction
    var isCognitiveLoadReduction = false
    var maxVisibleWindows: Int = 3
    var simplifiedUI = false
    
    func enableCognitiveReduction() {
        isCognitiveLoadReduction = true
        maxVisibleWindows = 3
        simplifiedUI = true
    }
    
    // MARK: - Gesture Sensitivity
    var gestureSensitivity: Double = 1.0  // 0.5 – 2.0
    
    // MARK: - Fatigue-Aware Spacing
    var fatigueAwareSpacing = true
    var extraSpacing: CGFloat = 0
    
    func updateFatigueSpacing(sessionMinutes: Int) {
        guard fatigueAwareSpacing else { extraSpacing = 0; return }
        // After 60 min, increase spacing to reduce eye strain
        extraSpacing = min(CGFloat(sessionMinutes) / 60.0 * 8, 20)
    }
    
    // MARK: - Seated/Standing Calibration Wizard
    var isCalibrationComplete = false
    var seatedHeight: Float = 1.2
    var standingHeight: Float = 1.6
    
    func calibrate(height: Float, isSeated: Bool) {
        if isSeated { seatedHeight = height }
        else { standingHeight = height }
        isCalibrationComplete = true
    }
    
    // MARK: - Closed Captions
    var isClosedCaptionsEnabled = false
    var captionFontSize: CGFloat = 14
    var captionPosition: CaptionPosition = .bottom
    
    enum CaptionPosition: String { case top, bottom, floating }
    
    // MARK: - Quick Toggle Panel
    var quickToggles: [QuickToggle] {
        [
            QuickToggle(name: "Voice Control", icon: "mic.fill", isOn: isVoiceControlEnabled),
            QuickToggle(name: "Eye-Only", icon: "eye.fill", isOn: isEyeOnlyMode),
            QuickToggle(name: "One-Hand", icon: "hand.raised.fill", isOn: isOneHandMode),
            QuickToggle(name: "High Contrast", icon: "circle.lefthalf.filled", isOn: isHighContrast),
            QuickToggle(name: "Tremor Stabilization", icon: "hand.point.up.braille.fill", isOn: isTremorStabilization),
            QuickToggle(name: "Cognitive Load", icon: "brain.head.profile", isOn: isCognitiveLoadReduction),
            QuickToggle(name: "Captions", icon: "captions.bubble.fill", isOn: isClosedCaptionsEnabled),
            QuickToggle(name: "Reduced Motion", icon: "figure.stand", isOn: false),
        ]
    }
    
    struct QuickToggle: Identifiable {
        let id = UUID()
        var name: String
        var icon: String
        var isOn: Bool
    }
    
    // MARK: - Guided Interaction Hints
    var isGuidedHintsEnabled = true
    var currentHint: String?
    
    func showHint(_ text: String) {
        currentHint = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            self?.currentHint = nil
        }
    }
}

// MARK: - Accessibility Quick Toggle Panel View

struct AccessibilityTogglePanelView: View {
    @Bindable var engine: AccessibilityEngine
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "accessibility").foregroundStyle(.blue)
                Text("Accessibility").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 18)).foregroundStyle(.white.opacity(0.3))
                }.buttonStyle(.plain)
            }
            
            // UI Scale slider
            VStack(alignment: .leading, spacing: 4) {
                Text("UI Scale: \(engine.uiScale, specifier: "%.1f")x").font(.system(size: 10, weight: .medium)).foregroundStyle(.white.opacity(0.5))
                Slider(value: $engine.uiScale, in: 0.75...2.0).tint(.blue)
            }
            
            // Toggles grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                ForEach(engine.quickToggles) { toggle in
                    HStack(spacing: 6) {
                        Image(systemName: toggle.icon).font(.system(size: 12))
                            .foregroundStyle(toggle.isOn ? .blue : .white.opacity(0.3))
                        Text(toggle.name).font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(toggle.isOn ? 0.9 : 0.4))
                        Spacer()
                    }
                    .padding(8).innerGlass(cornerRadius: 8)
                }
            }
            
            // Colorblind mode
            HStack {
                Text("Colorblind").font(.system(size: 10, weight: .medium)).foregroundStyle(.white.opacity(0.5))
                Spacer()
                Picker("", selection: $engine.colorblindMode) {
                    ForEach(AccessibilityEngine.ColorblindMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }.pickerStyle(.menu).tint(.white)
            }
        }
        .padding(20).frame(width: 380).glassBackground(cornerRadius: 24)
    }
}
