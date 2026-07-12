// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Settings View

/// Settings panel for HoloDesk — controls preferences and manages saved workspaces.
struct SettingsView: View {
    
    @Environment(WorkspaceStore.self) private var store
    @Binding var isPresented: Bool
    
    @AppStorage("holodesk_haptics_enabled") private var hapticsEnabled = true
    @AppStorage("holodesk_voice_autostart") private var voiceAutostart = false
    @AppStorage("holodesk_particle_effects") private var particleEffects = true
    @AppStorage("holodesk_auto_save") private var autoSave = true
    @AppStorage("holodesk_window_opacity") private var windowOpacity = 0.85
    @AppStorage("holodesk_animation_speed") private var animationSpeed = 1.0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // General
                    settingsSection("General") {
                        toggleRow("Auto-save workspace", icon: "arrow.clockwise", isOn: $autoSave)
                        toggleRow("Haptic feedback", icon: "hand.tap", isOn: $hapticsEnabled)
                        toggleRow("Auto-start voice", icon: "mic.fill", isOn: $voiceAutostart)
                        toggleRow("Particle effects", icon: "sparkle", isOn: $particleEffects)
                    }
                    
                    // Appearance
                    settingsSection("Appearance") {
                        sliderRow("Window opacity", icon: "circle.lefthalf.filled", value: $windowOpacity, range: 0.5...1.0)
                        sliderRow("Animation speed", icon: "hare", value: $animationSpeed, range: 0.5...2.0)
                    }
                    
                    // Saved Workspaces
                    settingsSection("Saved Workspaces") {
                        ForEach(store.savedWorkspaces) { workspace in
                            HStack {
                                Image(systemName: workspace.mode.iconName)
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.modeTint(for: workspace.mode))
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(workspace.name)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.white)
                                    
                                    Text("\(workspace.windows.count) windows")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                                
                                Spacer()
                                
                                Text(workspace.mode.emoji)
                                    .font(.system(size: 14))
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    // AI & Apple Intelligence
                    settingsSection("AI & Apple Intelligence") {
                        infoRow("AI Engine", value: "Apple Intelligence (On-Device)")
                        infoRow("Fallback", value: "Offline NLP (38 intents)")
                        infoRow("Default Mode", value: "On-Device First")
                        infoRow("Intents", value: "38 commands")
                    }
                    
                    // About
                    settingsSection("About") {
                        infoRow("Version", value: "3.0.0")
                        infoRow("Build", value: "2026.06.18")
                        infoRow("Submission", value: "SSC 2027")
                        infoRow("Platform", value: "visionOS 27 (Apple Vision Pro)")
                        infoRow("Runtime", value: "SwiftUI + RealityKit")
                        infoRow("AI", value: "Apple Intelligence (On-Device)")
                        infoRow("Developer", value: "Notminelap Industries")
                        infoRow("License", value: "Source Available")
                        infoRow("Swift Files", value: "101")
                        infoRow("Dependencies", value: "Zero")
                    }
                    
                    // Reset
                    Button {
                        store.clearAllWindows()
                        UserDefaults.standard.removeObject(forKey: "holodesk_onboarding_complete")
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset All Data")
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .innerGlass(cornerRadius: 12)
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { isPresented = false }
                }
            }
        }
        .frame(width: 420, height: 500)
        .glassBackground(cornerRadius: 24)
    }
    
    // MARK: - Components
    
    private func settingsSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
                .textCase(.uppercase)
            
            VStack(spacing: 1) {
                content()
            }
            .padding(12)
            .innerGlass(cornerRadius: 14)
        }
    }
    
    private func toggleRow(_ label: String, icon: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(Color.holoSecondary)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.8))
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.holoPrimary)
        }
        .padding(.vertical, 4)
    }
    
    private func sliderRow(_ label: String, icon: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.holoSecondary)
                    .frame(width: 24)
                
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.8))
                
                Spacer()
                
                Text(String(format: "%.0f%%", value.wrappedValue * 100))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Slider(value: value, in: range)
                .tint(.holoPrimary)
        }
        .padding(.vertical, 4)
    }
    
    private func infoRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.vertical, 3)
    }
}
