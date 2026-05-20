// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Gesture Shortcut Manager

/// Maps custom hand gestures to workspace actions.
@Observable
final class GestureShortcutManager {
    var shortcuts: [GestureShortcut] = GestureShortcut.defaults
    var isCustomizing = false
    
    struct GestureShortcut: Identifiable {
        let id = UUID()
        var gesture: GestureType
        var action: ShortcutAction
        var isEnabled: Bool
        
        enum GestureType: String, CaseIterable {
            case doublePinch = "Double Pinch"
            case palmUp = "Palm Up"
            case thumbsUp = "Thumbs Up"
            case fist = "Fist"
            case spreadFingers = "Spread Fingers"
            case waveLeft = "Wave Left"
            case waveRight = "Wave Right"
            case pinchHold = "Pinch Hold"
            
            var iconName: String {
                switch self {
                case .doublePinch:    return "hand.pinch"
                case .palmUp:         return "hand.raised.fill"
                case .thumbsUp:       return "hand.thumbsup.fill"
                case .fist:           return "hand.closed.fill"
                case .spreadFingers:  return "hand.raised.fingers.spread"
                case .waveLeft:       return "hand.wave.fill"
                case .waveRight:      return "hand.wave.fill"
                case .pinchHold:      return "hand.pinch"
                }
            }
            
            var emoji: String {
                switch self {
                case .doublePinch:    return "🤏🤏"
                case .palmUp:         return "🖐️"
                case .thumbsUp:       return "👍"
                case .fist:           return "✊"
                case .spreadFingers:  return "🖐️"
                case .waveLeft:       return "👋"
                case .waveRight:      return "👋"
                case .pinchHold:      return "🤏"
                }
            }
        }
        
        enum ShortcutAction: String, CaseIterable {
            case switchWorkMode = "Switch to Work"
            case switchCinemaMode = "Switch to Cinema"
            case saveWorkspace = "Save Workspace"
            case resetWorkspace = "Reset All"
            case toggleImmersive = "Toggle Immersive"
            case addNotes = "Add Notes"
            case toggleVoice = "Toggle Voice"
            case showDashboard = "Show Dashboard"
        }
        
        static var defaults: [GestureShortcut] {
            [
                GestureShortcut(gesture: .doublePinch, action: .saveWorkspace, isEnabled: true),
                GestureShortcut(gesture: .palmUp, action: .resetWorkspace, isEnabled: true),
                GestureShortcut(gesture: .thumbsUp, action: .switchWorkMode, isEnabled: true),
                GestureShortcut(gesture: .fist, action: .switchCinemaMode, isEnabled: true),
                GestureShortcut(gesture: .spreadFingers, action: .toggleImmersive, isEnabled: true),
                GestureShortcut(gesture: .waveLeft, action: .toggleVoice, isEnabled: false),
                GestureShortcut(gesture: .pinchHold, action: .showDashboard, isEnabled: false),
            ]
        }
    }
}

// MARK: - Gesture Shortcuts View

struct GestureShortcutsView: View {
    @Bindable var manager: GestureShortcutManager
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "hand.raised.fingers.spread")
                    .font(.system(size: 16))
                    .foregroundStyle(.orange)
                Text("Gesture Shortcuts")
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
            
            Text("Map hand gestures to workspace actions")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.4))
            
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(Array(manager.shortcuts.enumerated()), id: \.element.id) { index, shortcut in
                        shortcutRow(shortcut, index: index)
                    }
                }
            }
            .frame(maxHeight: 280)
        }
        .padding(20)
        .frame(width: 380)
        .glassBackground(cornerRadius: 24)
    }
    
    private func shortcutRow(_ shortcut: GestureShortcutManager.GestureShortcut, index: Int) -> some View {
        HStack(spacing: 10) {
            Text(shortcut.gesture.emoji)
                .font(.system(size: 18))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(shortcut.gesture.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(shortcut.isEnabled ? 1 : 0.4))
                Text(shortcut.action.rawValue)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.4))
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { manager.shortcuts[index].isEnabled },
                set: { manager.shortcuts[index].isEnabled = $0 }
            ))
            .labelsHidden()
            .tint(.orange)
        }
        .padding(8)
        .innerGlass(cornerRadius: 10)
    }
}
