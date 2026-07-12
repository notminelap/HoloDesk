// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Environment Effects Manager

/// Controls immersive environment effects — rain, fireplace, northern lights, nature sounds.
/// Transforms the mood of your workspace dramatically.
@MainActor @Observable
final class EnvironmentEffectsManager {
    
    var activeEffect: EnvironmentEffect = .none
    var effectIntensity: Float = 0.7
    var isSoundEnabled: Bool = true
    
    enum EnvironmentEffect: String, CaseIterable, Identifiable {
        case none
        case rain
        case fireplace
        case northernLights
        case underwater
        case space
        case forest
        case sunset
        case snowfall
        case foggy
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .none:           return "None"
            case .rain:           return "Rainy Day"
            case .fireplace:      return "Cozy Fireplace"
            case .northernLights: return "Northern Lights"
            case .underwater:     return "Deep Ocean"
            case .space:          return "Outer Space"
            case .forest:         return "Forest Ambience"
            case .sunset:         return "Golden Sunset"
            case .snowfall:       return "Gentle Snowfall"
            case .foggy:          return "Mystical Fog"
            }
        }
        
        var emoji: String {
            switch self {
            case .none:           return "⭕"
            case .rain:           return "🌧️"
            case .fireplace:      return "🔥"
            case .northernLights: return "🌌"
            case .underwater:     return "🌊"
            case .space:          return "🚀"
            case .forest:         return "🌲"
            case .sunset:         return "🌅"
            case .snowfall:       return "❄️"
            case .foggy:          return "🌫️"
            }
        }
        
        var iconName: String {
            switch self {
            case .none:           return "circle.slash"
            case .rain:           return "cloud.rain.fill"
            case .fireplace:      return "flame.fill"
            case .northernLights: return "sparkles"
            case .underwater:     return "water.waves"
            case .space:          return "moon.stars.fill"
            case .forest:         return "leaf.fill"
            case .sunset:         return "sun.horizon.fill"
            case .snowfall:       return "snowflake"
            case .foggy:          return "cloud.fog.fill"
            }
        }
        
        /// Color tint applied to ambient lighting
        var lightColor: (r: Float, g: Float, b: Float) {
            switch self {
            case .none:           return (1.0, 1.0, 1.0)
            case .rain:           return (0.5, 0.55, 0.7)
            case .fireplace:      return (1.0, 0.7, 0.3)
            case .northernLights: return (0.3, 0.9, 0.5)
            case .underwater:     return (0.2, 0.5, 0.9)
            case .space:          return (0.15, 0.1, 0.3)
            case .forest:         return (0.5, 0.8, 0.4)
            case .sunset:         return (1.0, 0.6, 0.3)
            case .snowfall:       return (0.85, 0.9, 1.0)
            case .foggy:          return (0.6, 0.6, 0.65)
            }
        }
        
        /// Ambient light intensity multiplier
        var intensityMultiplier: Float {
            switch self {
            case .none:           return 1.0
            case .rain:           return 0.4
            case .fireplace:      return 0.6
            case .northernLights: return 0.3
            case .underwater:     return 0.35
            case .space:          return 0.15
            case .forest:         return 0.65
            case .sunset:         return 0.75
            case .snowfall:       return 0.7
            case .foggy:          return 0.45
            }
        }
        
        /// Immersion level for this effect
        var immersionLevel: Float {
            switch self {
            case .none:           return 0.0
            case .rain:           return 0.3
            case .fireplace:      return 0.2
            case .northernLights: return 0.6
            case .underwater:     return 0.8
            case .space:          return 0.9
            case .forest:         return 0.4
            case .sunset:         return 0.35
            case .snowfall:       return 0.3
            case .foggy:          return 0.5
            }
        }
    }
    
    func setEffect(_ effect: EnvironmentEffect) {
        activeEffect = effect
        HapticManager.shared.mediumTap()
    }
}

// MARK: - Environment Effects Picker View

struct EnvironmentEffectsView: View {
    @Bindable var manager: EnvironmentEffectsManager
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.holoTertiary)
                Text("Environment Effects")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
            
            // Effect grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(EnvironmentEffectsManager.EnvironmentEffect.allCases) { effect in
                    effectCard(effect)
                }
            }
            
            // Intensity slider
            if manager.activeEffect != .none {
                VStack(spacing: 6) {
                    HStack {
                        Text("Intensity")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                        Spacer()
                        Text("\(Int(manager.effectIntensity * 100))%")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Slider(value: $manager.effectIntensity, in: 0.1...1.0)
                        .tint(.holoTertiary)
                }
                .padding(.top, 4)
                
                Toggle(isOn: $manager.isSoundEnabled) {
                    HStack {
                        Image(systemName: manager.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.system(size: 12))
                        Text("Ambient Sound")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
                .tint(.holoTertiary)
            }
        }
        .padding(20)
        .frame(width: 360)
        .glassBackground(cornerRadius: 24)
    }
    
    private func effectCard(_ effect: EnvironmentEffectsManager.EnvironmentEffect) -> some View {
        let isActive = manager.activeEffect == effect
        return Button {
            withAnimation(.spatialInteract) {
                manager.setEffect(effect)
            }
        } label: {
            VStack(spacing: 6) {
                Text(effect.emoji)
                    .font(.system(size: 22))
                Text(effect.displayName)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(isActive ? 1 : 0.6))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? Color.holoTertiary.opacity(0.3) : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isActive ? Color.holoTertiary.opacity(0.6) : .white.opacity(0.06), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
