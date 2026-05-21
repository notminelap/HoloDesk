// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Power User Panel

struct PowerUserPanel: View {
    @State private var tools = PowerUserTools()
    @Binding var isPresented: Bool
    @State private var activeTab = 0
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("⚡ Power Tools").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 18)).foregroundStyle(.white.opacity(0.3))
                }.buttonStyle(.plain)
            }
            
            // Tabs
            HStack(spacing: 0) {
                ForEach(["Layouts", "Keys", "Plugins", "API"], id: \.self) { tab in
                    let idx = ["Layouts", "Keys", "Plugins", "API"].firstIndex(of: tab)!
                    Button { activeTab = idx } label: {
                        Text(tab).font(.system(size: 10, weight: activeTab == idx ? .bold : .regular))
                            .foregroundStyle(activeTab == idx ? .white : .white.opacity(0.3))
                            .frame(maxWidth: .infinity).padding(.vertical, 6)
                            .background(activeTab == idx ? Color.white.opacity(0.08) : .clear, in: RoundedRectangle(cornerRadius: 6))
                    }.buttonStyle(.plain)
                }
            }.innerGlass(cornerRadius: 8)
            
            ScrollView {
                switch activeTab {
                case 0: layoutsTab
                case 1: shortcutsTab
                case 2: pluginsTab
                case 3: apiTab
                default: EmptyView()
                }
            }.frame(maxHeight: 280)
        }.padding(20).frame(width: 400).glassBackground(cornerRadius: 24)
    }
    
    private var layoutsTab: some View {
        VStack(spacing: 4) {
            ForEach(tools.deskLayouts) { layout in
                HStack(spacing: 8) {
                    Text(layout.emoji).font(.system(size: 18))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(layout.name).font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                        Text(layout.description).font(.system(size: 8)).foregroundStyle(.white.opacity(0.3))
                    }
                    Spacer()
                    Button { tools.activeDeskLayout = layout.id } label: {
                        Text("Apply").font(.system(size: 9, weight: .bold)).foregroundStyle(.blue)
                            .padding(.horizontal, 8).padding(.vertical, 4).innerGlass(cornerRadius: 4)
                    }.buttonStyle(.plain)
                }.padding(8).innerGlass(cornerRadius: 8)
            }
        }
    }
    
    private var shortcutsTab: some View {
        VStack(spacing: 2) {
            ForEach(tools.shortcuts) { sc in
                HStack {
                    Text(sc.keys).font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(.cyan).frame(width: 70, alignment: .leading)
                    Text(sc.action).font(.system(size: 10)).foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Text(sc.category).font(.system(size: 7)).foregroundStyle(.white.opacity(0.2))
                }.padding(.vertical, 4)
                Divider().overlay(Color.white.opacity(0.03))
            }
        }
    }
    
    private var pluginsTab: some View {
        VStack(spacing: 4) {
            ForEach(tools.availablePlugins) { plugin in
                HStack(spacing: 8) {
                    Text(plugin.emoji).font(.system(size: 18))
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(plugin.name).font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                            Text("v\(plugin.version)").font(.system(size: 7, design: .monospaced)).foregroundStyle(.white.opacity(0.2))
                        }
                        Text(plugin.description).font(.system(size: 8)).foregroundStyle(.white.opacity(0.3)).lineLimit(1)
                        Text("by \(plugin.author)").font(.system(size: 7)).foregroundStyle(.white.opacity(0.2))
                    }
                    Spacer()
                    Button { } label: {
                        Text(plugin.isInstalled ? "Installed" : "Install")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(plugin.isInstalled ? .green : .blue)
                            .padding(.horizontal, 8).padding(.vertical, 4).innerGlass(cornerRadius: 4)
                    }.buttonStyle(.plain)
                }.padding(8).innerGlass(cornerRadius: 8)
            }
        }
    }
    
    private var apiTab: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Developer API v\(tools.apiVersion)").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Circle().fill(tools.isAPIEnabled ? .green : .red).frame(width: 6, height: 6)
                Text(tools.isAPIEnabled ? "Active" : "Disabled").font(.system(size: 9)).foregroundStyle(.white.opacity(0.4))
            }
            
            ForEach(tools.apiEndpoints, id: \.self) { endpoint in
                HStack(spacing: 6) {
                    let method = endpoint.components(separatedBy: " ").first ?? ""
                    Text(method).font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundStyle(method == "GET" ? .green : method == "POST" ? .blue : method == "PUT" ? .orange : .red)
                        .frame(width: 35, alignment: .leading)
                    Text(endpoint.components(separatedBy: " ").dropFirst().joined(separator: " "))
                        .font(.system(size: 9, design: .monospaced)).foregroundStyle(.white.opacity(0.5))
                }.padding(.vertical, 2)
            }
            
            if tools.isDebugMode {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Debug Info").font(.system(size: 9, weight: .bold)).foregroundStyle(.orange)
                    ForEach(Array(tools.debugInfo), id: \.key) { key, value in
                        HStack {
                            Text(key).font(.system(size: 8, design: .monospaced)).foregroundStyle(.white.opacity(0.3))
                            Spacer()
                            Text(value).font(.system(size: 8, weight: .bold, design: .monospaced)).foregroundStyle(.cyan)
                        }
                    }
                }.padding(8).background(.orange.opacity(0.05), in: RoundedRectangle(cornerRadius: 6))
            }
        }
    }
}

// MARK: - Automation Panel

struct AutomationPanel: View {
    @State private var engine = AutomationEngine()
    @Binding var isPresented: Bool
    @State private var activeSection = 0
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("🤖 Automation").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 18)).foregroundStyle(.white.opacity(0.3))
                }.buttonStyle(.plain)
            }
            
            // Section toggle
            HStack(spacing: 0) {
                ForEach(["Scripts", "Gestures"], id: \.self) { tab in
                    let idx = tab == "Scripts" ? 0 : 1
                    Button { activeSection = idx } label: {
                        Text(tab).font(.system(size: 10, weight: activeSection == idx ? .bold : .regular))
                            .foregroundStyle(activeSection == idx ? .white : .white.opacity(0.3))
                            .frame(maxWidth: .infinity).padding(.vertical, 6)
                            .background(activeSection == idx ? Color.white.opacity(0.08) : .clear, in: RoundedRectangle(cornerRadius: 6))
                    }.buttonStyle(.plain)
                }
            }.innerGlass(cornerRadius: 8)
            
            if activeSection == 0 {
                // Scripts
                VStack(spacing: 4) {
                    ForEach(engine.scripts) { script in
                        HStack(spacing: 8) {
                            Text(script.emoji).font(.system(size: 16))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(script.name).font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                                Text(script.trigger).font(.system(size: 8)).foregroundStyle(.white.opacity(0.3))
                                HStack(spacing: 4) {
                                    ForEach(script.actions, id: \.self) { a in
                                        Text(a).font(.system(size: 6, design: .monospaced))
                                            .foregroundStyle(.cyan.opacity(0.5)).padding(.horizontal, 4).padding(.vertical, 1)
                                            .background(.cyan.opacity(0.08), in: Capsule())
                                    }
                                }
                            }
                            Spacer()
                            Circle().fill(script.isEnabled ? .green : .red.opacity(0.3)).frame(width: 8, height: 8)
                        }.padding(8).innerGlass(cornerRadius: 8)
                    }
                }
            } else {
                // Custom gestures
                VStack(spacing: 4) {
                    ForEach(engine.customGestures) { gesture in
                        HStack(spacing: 8) {
                            Image(systemName: "hand.raised.fill").font(.system(size: 14)).foregroundStyle(.purple)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(gesture.name).font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                                Text(gesture.gesture).font(.system(size: 8)).foregroundStyle(.white.opacity(0.3))
                                Text("→ \(gesture.action)").font(.system(size: 8)).foregroundStyle(.purple.opacity(0.5))
                            }
                            Spacer()
                            Circle().fill(gesture.isEnabled ? .green : .red.opacity(0.3)).frame(width: 8, height: 8)
                        }.padding(8).innerGlass(cornerRadius: 8)
                    }
                }
            }
        }.padding(20).frame(width: 400).glassBackground(cornerRadius: 24)
    }
}

// MARK: - Celebration Overlay

struct CelebrationOverlay: View {
    @Environment(DelightSystem.self) private var delight
    
    var body: some View {
        if delight.showCelebration {
            ZStack {
                // Particle emojis
                ForEach(0..<12, id: \.self) { i in
                    Text(delight.celebrationEmoji)
                        .font(.system(size: CGFloat.random(in: 16...32)))
                        .offset(
                            x: CGFloat.random(in: -150...150),
                            y: CGFloat.random(in: -200...0)
                        )
                        .opacity(0.8)
                        .animation(.easeOut(duration: 1.5).delay(Double(i) * 0.05), value: delight.showCelebration)
                }
            }
            .transition(.opacity)
            .allowsHitTesting(false)
        }
    }
}
