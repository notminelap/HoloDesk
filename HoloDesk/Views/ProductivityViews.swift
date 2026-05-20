// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Sticky Notes Overlay

/// Spatial sticky notes floating in the room.
struct StickyNotesOverlay: View {
    @Environment(StickyNotesLayer.self) private var stickyNotes
    @State private var newNoteText = ""
    @State private var showAddNote = false
    @State private var selectedColor: Color = .yellow
    
    private let colors: [Color] = [.yellow, .green, .pink, .blue, .orange, .purple]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("📝 Sticky Notes").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Text("\(stickyNotes.notes.count)").font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                Button { showAddNote.toggle() } label: {
                    Image(systemName: "plus.circle.fill").font(.system(size: 18)).foregroundStyle(.yellow)
                }.buttonStyle(.plain)
            }
            
            if showAddNote {
                VStack(spacing: 8) {
                    TextField("Quick note...", text: $newNoteText)
                        .textFieldStyle(.plain).font(.system(size: 12)).foregroundStyle(.white)
                        .padding(8).background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
                    HStack(spacing: 6) {
                        ForEach(colors, id: \.self) { c in
                            Button { selectedColor = c } label: {
                                Circle().fill(c).frame(width: 20, height: 20)
                                    .overlay(Circle().strokeBorder(selectedColor == c ? .white : .clear, lineWidth: 2))
                            }.buttonStyle(.plain)
                        }
                        Spacer()
                        Button {
                            guard !newNoteText.isEmpty else { return }
                            stickyNotes.addNote(text: newNoteText, color: selectedColor, at: SIMD3(Float.random(in: -0.5...0.5), 1.5, -1.0))
                            newNoteText = ""; showAddNote = false
                        } label: {
                            Text("Add").font(.system(size: 10, weight: .bold)).foregroundStyle(.white)
                                .padding(.horizontal, 12).padding(.vertical, 5).background(.yellow.opacity(0.5), in: Capsule())
                        }.buttonStyle(.plain)
                    }
                }.padding(10).innerGlass(cornerRadius: 10)
            }
            
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(stickyNotes.notes) { note in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 3).fill(note.color).frame(width: 4)
                            Text(note.text).font(.system(size: 11)).foregroundStyle(.black.opacity(0.8))
                                .lineLimit(2)
                            Spacer()
                            if note.isPinned {
                                Image(systemName: "pin.fill").font(.system(size: 8)).foregroundStyle(.orange)
                            }
                            Button { stickyNotes.removeNote(note.id) } label: {
                                Image(systemName: "xmark").font(.system(size: 8)).foregroundStyle(.white.opacity(0.3))
                            }.buttonStyle(.plain)
                        }.padding(8).background(note.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }.frame(maxHeight: 200)
        }.padding(20).frame(width: 340).glassBackground(cornerRadius: 24)
    }
}

// MARK: - Quick Capture View

struct QuickCaptureView: View {
    @Environment(QuickCaptureInbox.self) private var capture
    @State private var text = ""
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("⚡ Quick Capture").font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Text("\(capture.items.filter { !$0.isProcessed }.count) unprocessed")
                    .font(.system(size: 9)).foregroundStyle(.white.opacity(0.3))
            }
            
            HStack(spacing: 6) {
                TextField("Capture anything...", text: $text).textFieldStyle(.plain)
                    .font(.system(size: 12)).foregroundStyle(.white)
                Button {
                    guard !text.isEmpty else { return }
                    capture.capture(content: text, type: .note); text = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill").font(.system(size: 20)).foregroundStyle(.blue)
                }.buttonStyle(.plain)
            }.padding(8).innerGlass(cornerRadius: 10)
            
            // Quick type buttons
            HStack(spacing: 6) {
                captureBtn("📝", "Note", .note)
                captureBtn("🔗", "Link", .link)
                captureBtn("🎤", "Voice", .voice)
                captureBtn("📸", "Photo", .photo)
                captureBtn("💡", "Idea", .idea)
            }
            
            ScrollView {
                VStack(spacing: 3) {
                    ForEach(capture.items) { item in
                        HStack(spacing: 8) {
                            Image(systemName: item.type.rawValue).font(.system(size: 10))
                                .foregroundStyle(item.isProcessed ? .green : .white.opacity(0.4))
                            Text(item.content).font(.system(size: 10))
                                .foregroundStyle(.white.opacity(item.isProcessed ? 0.4 : 0.8))
                                .strikethrough(item.isProcessed).lineLimit(1)
                            Spacer()
                            Text(item.timestamp, style: .relative).font(.system(size: 7)).foregroundStyle(.white.opacity(0.2))
                            Button { capture.processItem(item.id) } label: {
                                Image(systemName: item.isProcessed ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 12)).foregroundStyle(item.isProcessed ? .green : .white.opacity(0.2))
                            }.buttonStyle(.plain)
                        }.padding(6).innerGlass(cornerRadius: 6)
                    }
                }
            }.frame(maxHeight: 150)
        }.padding(16).frame(width: 340).glassBackground(cornerRadius: 20)
    }
    
    private func captureBtn(_ emoji: String, _ label: String, _ type: QuickCaptureInbox.CaptureItem.CaptureType) -> some View {
        Button { capture.capture(content: "\(label) capture", type: type) } label: {
            VStack(spacing: 2) {
                Text(emoji).font(.system(size: 14))
                Text(label).font(.system(size: 7)).foregroundStyle(.white.opacity(0.4))
            }.frame(maxWidth: .infinity).padding(.vertical, 6).innerGlass(cornerRadius: 6)
        }.buttonStyle(.plain)
    }
}

// MARK: - Desk Plants View

struct DeskPlantsView: View {
    @Environment(DeskPlantSystem.self) private var plants
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("🌱 Desk Plants").font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Text("\(plants.totalGrowthPoints) pts").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundStyle(.green)
            }
            
            HStack(spacing: 10) {
                ForEach(plants.plants) { plant in
                    VStack(spacing: 4) {
                        Text(plant.stageEmoji).font(.system(size: 30))
                        Text(plant.name).font(.system(size: 9, weight: .bold)).foregroundStyle(.white.opacity(0.7))
                        Text(plant.stageName).font(.system(size: 7)).foregroundStyle(.green.opacity(0.5))
                        
                        // Growth bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(.white.opacity(0.06)).frame(height: 3)
                                Capsule().fill(.green).frame(width: geo.size.width * CGFloat(plant.growthPoints) / CGFloat(max(plant.pointsToNext, 1)), height: 3)
                            }
                        }.frame(height: 3)
                        
                        Button { plants.waterPlant(plant.id) } label: {
                            HStack(spacing: 2) {
                                Text("💧").font(.system(size: 8))
                                Text("Water").font(.system(size: 7, weight: .medium)).foregroundStyle(.cyan)
                            }.padding(.horizontal, 6).padding(.vertical, 3).innerGlass(cornerRadius: 4)
                        }.buttonStyle(.plain)
                    }.frame(maxWidth: .infinity).padding(8).innerGlass(cornerRadius: 10)
                }
            }
        }.padding(16).frame(width: 380).glassBackground(cornerRadius: 20)
    }
}

// MARK: - Apple Ecosystem Panel

struct AppleEcosystemPanel: View {
    @Environment(AppleEcosystemManager.self) private var eco
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("🍎 Ecosystem").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 18)).foregroundStyle(.white.opacity(0.3))
                }.buttonStyle(.plain)
            }
            
            // Mac Virtual Display
            HStack(spacing: 10) {
                Image(systemName: "macbook").font(.system(size: 20)).foregroundStyle(.blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mac Virtual Display").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                    Text(eco.isMacDisplayConnected ? "\(eco.macDisplayName) • \(eco.macDisplayResolution)" : "Not connected")
                        .font(.system(size: 9)).foregroundStyle(.white.opacity(0.4))
                }
                Spacer()
                Button { if eco.isMacDisplayConnected { eco.disconnectMacDisplay() } else { eco.connectMacDisplay() } } label: {
                    Text(eco.isMacDisplayConnected ? "Disconnect" : "Connect")
                        .font(.system(size: 9, weight: .bold)).foregroundStyle(eco.isMacDisplayConnected ? .red : .blue)
                        .padding(.horizontal, 8).padding(.vertical, 4).innerGlass(cornerRadius: 6)
                }.buttonStyle(.plain)
            }.padding(10).innerGlass(cornerRadius: 10)
            
            // AirDrop Targets
            VStack(alignment: .leading, spacing: 6) {
                Text("AirDrop").font(.system(size: 11, weight: .bold)).foregroundStyle(.white.opacity(0.5))
                HStack(spacing: 8) {
                    ForEach(eco.airdropTargets) { target in
                        VStack(spacing: 3) {
                            Image(systemName: target.icon).font(.system(size: 18))
                                .foregroundStyle(target.isAvailable ? .blue : .white.opacity(0.2))
                            Text(target.name).font(.system(size: 7)).foregroundStyle(.white.opacity(0.4)).lineLimit(1)
                        }.frame(width: 65, height: 50).innerGlass(cornerRadius: 8).opacity(target.isAvailable ? 1 : 0.4)
                    }
                }
            }
            
            // iCloud Sync
            HStack(spacing: 8) {
                Image(systemName: "icloud.fill").font(.system(size: 14)).foregroundStyle(.blue)
                Text("iCloud Sync").font(.system(size: 11, weight: .medium)).foregroundStyle(.white)
                Spacer()
                Text(eco.syncStatus.rawValue).font(.system(size: 9)).foregroundStyle(.white.opacity(0.4))
                Button { eco.syncToiCloud() } label: {
                    Image(systemName: "arrow.triangle.2.circlepath").font(.system(size: 12)).foregroundStyle(.blue)
                }.buttonStyle(.plain)
            }.padding(8).innerGlass(cornerRadius: 8)
            
            // Floating Reminders
            VStack(alignment: .leading, spacing: 4) {
                Text("Reminders").font(.system(size: 11, weight: .bold)).foregroundStyle(.white.opacity(0.5))
                ForEach(eco.floatingReminders) { r in
                    HStack(spacing: 6) {
                        Button { eco.completeReminder(r.id) } label: {
                            Image(systemName: r.isComplete ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 12)).foregroundStyle(r.isComplete ? .green : r.priority.color)
                        }.buttonStyle(.plain)
                        Text(r.text).font(.system(size: 10)).foregroundStyle(.white.opacity(r.isComplete ? 0.3 : 0.8))
                            .strikethrough(r.isComplete)
                        Spacer()
                        Text(r.dueTime).font(.system(size: 8)).foregroundStyle(.white.opacity(0.3))
                    }
                }
            }.padding(8).innerGlass(cornerRadius: 8)
        }.padding(20).frame(width: 380).glassBackground(cornerRadius: 24)
    }
}

// MARK: - Privacy Dashboard View

struct PrivacyDashboardView: View {
    @Environment(PrivacyShieldSystem.self) private var privacy
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "lock.shield.fill").foregroundStyle(.green)
                Text("Privacy & Trust").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 18)).foregroundStyle(.white.opacity(0.3))
                }.buttonStyle(.plain)
            }
            
            // Status
            VStack(spacing: 6) {
                privacyRow("📸 Camera Data", privacy.dashboard.cameraAccess, .green)
                privacyRow("📍 Location", privacy.dashboard.locationAccess, .green)
                privacyRow("🌐 Network", privacy.dashboard.networkAccess, .green)
                privacyRow("💾 Data Storage", privacy.dashboard.dataRetention, .green)
            }
            
            Divider().overlay(Color.white.opacity(0.06))
            
            // Controls
            HStack(spacing: 8) {
                Button { privacy.isOfflineMode.toggle() } label: {
                    VStack(spacing: 3) {
                        Image(systemName: privacy.isOfflineMode ? "wifi.slash" : "wifi").font(.system(size: 16))
                            .foregroundStyle(privacy.isOfflineMode ? .orange : .green)
                        Text("Offline").font(.system(size: 8)).foregroundStyle(.white.opacity(0.4))
                    }.frame(maxWidth: .infinity).padding(.vertical, 8).innerGlass(cornerRadius: 8)
                }.buttonStyle(.plain)
                
                Button { privacy.instantConceal() } label: {
                    VStack(spacing: 3) {
                        Image(systemName: "eye.slash.fill").font(.system(size: 16)).foregroundStyle(.red)
                        Text("Conceal").font(.system(size: 8)).foregroundStyle(.white.opacity(0.4))
                    }.frame(maxWidth: .infinity).padding(.vertical, 8).innerGlass(cornerRadius: 8)
                }.buttonStyle(.plain)
                
                Button { privacy.isGuestSession ? privacy.endGuestSession() : privacy.startGuestSession() } label: {
                    VStack(spacing: 3) {
                        Image(systemName: "person.badge.shield.checkmark").font(.system(size: 16))
                            .foregroundStyle(privacy.isGuestSession ? .orange : .blue)
                        Text("Guest").font(.system(size: 8)).foregroundStyle(.white.opacity(0.4))
                    }.frame(maxWidth: .infinity).padding(.vertical, 8).innerGlass(cornerRadius: 8)
                }.buttonStyle(.plain)
            }
            
            // Data controls
            HStack(spacing: 8) {
                Button { } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up"); Text("Export Data")
                    }.font(.system(size: 10, weight: .medium)).foregroundStyle(.blue)
                        .frame(maxWidth: .infinity).padding(.vertical, 6).innerGlass(cornerRadius: 6)
                }.buttonStyle(.plain)
                
                Button { } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "trash"); Text("Delete All")
                    }.font(.system(size: 10, weight: .medium)).foregroundStyle(.red)
                        .frame(maxWidth: .infinity).padding(.vertical, 6).innerGlass(cornerRadius: 6)
                }.buttonStyle(.plain)
            }
        }.padding(20).frame(width: 380).glassBackground(cornerRadius: 24)
    }
    
    private func privacyRow(_ label: String, _ status: String, _ color: Color) -> some View {
        HStack {
            Text(label).font(.system(size: 11)).foregroundStyle(.white.opacity(0.7))
            Spacer()
            HStack(spacing: 4) {
                Circle().fill(color).frame(width: 6, height: 6)
                Text(status).font(.system(size: 9, weight: .medium)).foregroundStyle(color)
            }
        }
    }
}
