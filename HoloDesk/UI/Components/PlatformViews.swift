// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Wellness Dashboard View

/// Break reminders, posture, breathing, hydration, eye rest.
struct WellnessDashboardView: View {
    @Bindable var wellness: WellnessManager
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("🌿 Wellness").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 18)).foregroundStyle(.white.opacity(0.3))
                }.buttonStyle(.plain)
            }
            
            // Stats row
            HStack(spacing: 12) {
                wellnessStat("🧘", "Posture", "\(wellness.postureScore)%", .green)
                wellnessStat("💧", "Water", "\(wellness.hydrationCount)/\(wellness.hydrationGoal)", .cyan)
                wellnessStat("🔥", "Fatigue", "\(Int(wellness.fatigueLevel * 100))%", wellness.fatigueLevel > 0.7 ? .red : .green)
                wellnessStat("🧘", "Stretches", "\(wellness.stretchesDone)", .purple)
            }
            
            // Break status
            HStack {
                Image(systemName: wellness.isBreakDue ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .foregroundStyle(wellness.isBreakDue ? .orange : .green)
                Text(wellness.isBreakDue ? "Break overdue!" : "Good — next break in \(Int((wellness.breakInterval - Date().timeIntervalSince(wellness.lastBreakTime)) / 60))m")
                    .font(.system(size: 11)).foregroundStyle(.white.opacity(0.7))
                Spacer()
                if wellness.isBreakDue {
                    Button { wellness.takeBreak() } label: {
                        Text("Take Break").font(.system(size: 10, weight: .bold)).foregroundStyle(.white)
                            .padding(.horizontal, 10).padding(.vertical, 4).background(.green.opacity(0.5), in: Capsule())
                    }.buttonStyle(.plain)
                }
            }.padding(10).innerGlass(cornerRadius: 10)
            
            // Quick actions
            HStack(spacing: 8) {
                quickAction("💧", "Water") { wellness.drinkWater() }
                quickAction("🧘", "Stretch") { wellness.logStretch() }
                quickAction("👁️", "Eye Rest") { wellness.startEyeRest() }
                quickAction("🌬️", "Breathe") { wellness.breathingActive.toggle() }
            }
            
            // Breathing exercise
            if wellness.breathingActive {
                VStack(spacing: 6) {
                    Text("🌬️ Box Breathing").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                    Text("In 4s → Hold 4s → Out 4s → Hold 4s").font(.system(size: 9)).foregroundStyle(.white.opacity(0.4))
                }.padding(12).innerGlass(cornerRadius: 10)
            }
        }
        .padding(20).frame(width: 380).glassBackground(cornerRadius: 24)
    }
    
    private func wellnessStat(_ emoji: String, _ label: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 3) {
            Text(emoji).font(.system(size: 16))
            Text(value).font(.system(size: 12, weight: .bold)).foregroundStyle(color)
            Text(label).font(.system(size: 7)).foregroundStyle(.white.opacity(0.3))
        }.frame(maxWidth: .infinity)
    }
    
    private func quickAction(_ emoji: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Text(emoji).font(.system(size: 18))
                Text(label).font(.system(size: 8, weight: .medium)).foregroundStyle(.white.opacity(0.5))
            }.frame(maxWidth: .infinity).padding(.vertical, 8).innerGlass(cornerRadius: 10)
        }.buttonStyle(.plain)
    }
}

// MARK: - Smart Home View

struct SmartHomeView: View {
    @Bindable var hub: SmartHomeHub
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("🏠 Home").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 18)).foregroundStyle(.white.opacity(0.3))
                }.buttonStyle(.plain)
            }
            
            // Climate
            HStack {
                VStack(alignment: .leading) {
                    Text("Climate").font(.system(size: 11, weight: .bold)).foregroundStyle(.white.opacity(0.5))
                    Text("\(hub.currentTemperature, specifier: "%.1f")°C").font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                }
                Spacer()
                HStack(spacing: 8) {
                    Button { hub.targetTemperature -= 0.5 } label: {
                        Image(systemName: "minus.circle").font(.system(size: 18)).foregroundStyle(.cyan)
                    }.buttonStyle(.plain)
                    Text("\(hub.targetTemperature, specifier: "%.0f")°").font(.system(size: 14, weight: .bold, design: .monospaced)).foregroundStyle(.white)
                    Button { hub.targetTemperature += 0.5 } label: {
                        Image(systemName: "plus.circle").font(.system(size: 18)).foregroundStyle(.orange)
                    }.buttonStyle(.plain)
                }
            }.padding(10).innerGlass(cornerRadius: 10)
            
            // Scenes
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(hub.scenes) { scene in
                        Button { hub.activateScene(scene) } label: {
                            VStack(spacing: 3) {
                                Text(scene.emoji).font(.system(size: 18))
                                Text(scene.name).font(.system(size: 8, weight: .medium)).foregroundStyle(.white.opacity(0.6))
                            }.padding(8).innerGlass(cornerRadius: 8)
                        }.buttonStyle(.plain)
                    }
                }
            }
            
            // Devices
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                ForEach(hub.devices) { device in
                    Button { hub.toggleDevice(id: device.id) } label: {
                        HStack(spacing: 6) {
                            Image(systemName: device.icon).font(.system(size: 14))
                                .foregroundStyle(device.isOn ? .yellow : .white.opacity(0.3))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(device.name).font(.system(size: 9, weight: .medium)).foregroundStyle(.white.opacity(device.isOn ? 0.9 : 0.4))
                                Text(device.room).font(.system(size: 7)).foregroundStyle(.white.opacity(0.2))
                            }
                            Spacer()
                        }.padding(8).innerGlass(cornerRadius: 8)
                    }.buttonStyle(.plain)
                }
            }
        }.padding(20).frame(width: 380).glassBackground(cornerRadius: 24)
    }
}

// MARK: - Achievements View

struct AchievementsView: View {
    @Bindable var system: AchievementSystem
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("🏆 Achievements").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Text("Lv.\(system.level) • \(system.totalPoints) pts").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundStyle(.yellow)
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 18)).foregroundStyle(.white.opacity(0.3))
                }.buttonStyle(.plain)
            }
            
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(system.achievements) { a in
                        HStack(spacing: 10) {
                            Text(a.emoji).font(.system(size: 22)).opacity(a.isUnlocked ? 1 : 0.3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(a.title).font(.system(size: 12, weight: .bold)).foregroundStyle(.white.opacity(a.isUnlocked ? 1 : 0.5))
                                Text(a.description).font(.system(size: 9)).foregroundStyle(.white.opacity(0.3))
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(.white.opacity(0.06)).frame(height: 3)
                                        Capsule().fill(a.isUnlocked ? .yellow : .white.opacity(0.2)).frame(width: geo.size.width * a.progress, height: 3)
                                    }
                                }.frame(height: 3)
                            }
                            Spacer()
                            Text("+\(a.points)").font(.system(size: 10, weight: .bold)).foregroundStyle(.yellow.opacity(a.isUnlocked ? 1 : 0.3))
                        }.padding(8).innerGlass(cornerRadius: 8)
                    }
                }
            }.frame(maxHeight: 300)
        }.padding(20).frame(width: 400).glassBackground(cornerRadius: 24)
    }
}
