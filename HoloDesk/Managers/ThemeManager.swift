// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Theme Manager

/// Multiple visual themes for HoloDesk.
@Observable
final class ThemeManager {
    
    var activeTheme: HoloDeskTheme = .midnight
    
    enum HoloDeskTheme: String, CaseIterable, Identifiable {
        case midnight       // Default dark
        case aurora         // Green/purple northern lights
        case ocean          // Deep blue
        case sunset         // Warm orange/pink
        case monochrome     // Pure black and white
        case neon           // Cyberpunk neon
        case nature         // Earthy greens
        case rose           // Soft pink/rose
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .midnight:    return "Midnight"
            case .aurora:      return "Aurora"
            case .ocean:       return "Ocean"
            case .sunset:      return "Sunset"
            case .monochrome:  return "Mono"
            case .neon:        return "Neon"
            case .nature:      return "Nature"
            case .rose:        return "Rose"
            }
        }
        
        var emoji: String {
            switch self {
            case .midnight:    return "🌙"
            case .aurora:      return "🌌"
            case .ocean:       return "🌊"
            case .sunset:      return "🌅"
            case .monochrome:  return "◻️"
            case .neon:        return "💜"
            case .nature:      return "🌿"
            case .rose:        return "🌸"
            }
        }
        
        var primaryColor: Color {
            switch self {
            case .midnight:    return Color(hue: 0.58, saturation: 0.85, brightness: 0.95)
            case .aurora:      return Color(hue: 0.35, saturation: 0.8, brightness: 0.85)
            case .ocean:       return Color(hue: 0.55, saturation: 0.9, brightness: 0.8)
            case .sunset:      return Color(hue: 0.08, saturation: 0.85, brightness: 0.95)
            case .monochrome:  return Color(white: 0.85)
            case .neon:        return Color(hue: 0.8, saturation: 1, brightness: 1)
            case .nature:      return Color(hue: 0.3, saturation: 0.7, brightness: 0.7)
            case .rose:        return Color(hue: 0.95, saturation: 0.5, brightness: 0.9)
            }
        }
        
        var secondaryColor: Color {
            switch self {
            case .midnight:    return Color(hue: 0.52, saturation: 0.6, brightness: 0.9)
            case .aurora:      return Color(hue: 0.75, saturation: 0.6, brightness: 0.8)
            case .ocean:       return Color(hue: 0.48, saturation: 0.7, brightness: 0.9)
            case .sunset:      return Color(hue: 0.95, saturation: 0.7, brightness: 0.9)
            case .monochrome:  return Color(white: 0.6)
            case .neon:        return Color(hue: 0.5, saturation: 1, brightness: 1)
            case .nature:      return Color(hue: 0.25, saturation: 0.5, brightness: 0.8)
            case .rose:        return Color(hue: 0.9, saturation: 0.4, brightness: 0.85)
            }
        }
        
        /// Preview gradient for theme picker
        var previewGradient: [Color] {
            [primaryColor.opacity(0.6), secondaryColor.opacity(0.3)]
        }
    }
}

// MARK: - Theme Picker View

struct ThemePickerView: View {
    @Bindable var themeManager: ThemeManager
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(themeManager.activeTheme.primaryColor)
                Text("Themes")
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
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(ThemeManager.HoloDeskTheme.allCases) { theme in
                    themeCard(theme)
                }
            }
        }
        .padding(20)
        .frame(width: 380)
        .glassBackground(cornerRadius: 24)
    }
    
    private func themeCard(_ theme: ThemeManager.HoloDeskTheme) -> some View {
        let isActive = themeManager.activeTheme == theme
        return Button {
            withAnimation(.spatialInteract) {
                themeManager.activeTheme = theme
                HapticManager.shared.selectionChanged()
            }
        } label: {
            VStack(spacing: 6) {
                // Color preview circle
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: theme.previewGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 36, height: 36)
                    
                    if isActive {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                
                Text(theme.displayName)
                    .font(.system(size: 9, weight: isActive ? .bold : .medium))
                    .foregroundStyle(.white.opacity(isActive ? 1 : 0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isActive ? theme.primaryColor.opacity(0.5) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
