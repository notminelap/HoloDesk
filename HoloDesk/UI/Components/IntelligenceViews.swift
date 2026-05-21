// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - AI Daily Briefing View

/// Morning briefing panel — weather, meetings, tasks, quote, focus hours.
struct DailyBriefingView: View {
    @Environment(AIWorkspaceIntelligence.self) private var ai
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            if let briefing = ai.dailyBriefing {
                // Greeting
                Text(briefing.greeting)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                // Stats row
                HStack(spacing: 16) {
                    briefStat("☁️", briefing.weather)
                    briefStat("📅", "\(briefing.meetingCount) meetings")
                    briefStat("⏱️", "\(briefing.focusHoursAvailable)h focus")
                }
                
                // Tasks
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Priorities").font(.system(size: 11, weight: .bold)).foregroundStyle(.white.opacity(0.5))
                    ForEach(Array(briefing.topTasks.enumerated()), id: \.offset) { i, task in
                        HStack(spacing: 6) {
                            Text("\(i + 1)").font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundStyle(.blue).frame(width: 18, height: 18)
                                .background(.blue.opacity(0.15), in: Circle())
                            Text(task).font(.system(size: 11)).foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }.padding(10).innerGlass(cornerRadius: 10)
                
                // Quote
                VStack(spacing: 4) {
                    Text(""\(briefing.motivationalQuote)"")
                        .font(.system(size: 11, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.6)).multilineTextAlignment(.center)
                }.padding(10).innerGlass(cornerRadius: 10)
                
                // AI suggested layout
                VStack(alignment: .leading, spacing: 6) {
                    Text("Suggested Layout").font(.system(size: 11, weight: .bold)).foregroundStyle(.white.opacity(0.5))
                    HStack(spacing: 6) {
                        ForEach(ai.suggestLayout(), id: \.self) { type in
                            VStack(spacing: 2) {
                                Image(systemName: type.iconName).font(.system(size: 14))
                                    .foregroundStyle(Color.windowAccent(for: type))
                                Text(type.displayName).font(.system(size: 7)).foregroundStyle(.white.opacity(0.4))
                            }.frame(width: 50, height: 40).innerGlass(cornerRadius: 6)
                        }
                    }
                }.padding(10).innerGlass(cornerRadius: 10)
                
                Button { isPresented = false } label: {
                    Text("Let's Go! 🚀").font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                        .background(.blue.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
                }.buttonStyle(.plain)
            }
        }.padding(20).frame(width: 400).glassBackground(cornerRadius: 24)
    }
    
    private func briefStat(_ emoji: String, _ text: String) -> some View {
        VStack(spacing: 2) {
            Text(emoji).font(.system(size: 16))
            Text(text).font(.system(size: 9, weight: .medium)).foregroundStyle(.white.opacity(0.6))
        }.frame(maxWidth: .infinity).padding(.vertical, 6).innerGlass(cornerRadius: 8)
    }
}

// MARK: - Weekly Insights View

struct WeeklyInsightsView: View {
    @Environment(AIWorkspaceIntelligence.self) private var ai
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("📊 Weekly Insights").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 18)).foregroundStyle(.white.opacity(0.3))
                }.buttonStyle(.plain)
            }
            
            if let insights = ai.weeklyInsights {
                HStack(spacing: 12) {
                    insightCard("⏱️", "\(insights.totalFocusHours, specifier: "%.1f")h", "Focus", .blue)
                    insightCard("🏆", insights.mostProductiveDay, "Best Day", .yellow)
                    insightCard("🔥", "\(insights.streakDays)d", "Streak", .orange)
                }
                
                Text(insights.improvement).font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.green).padding(8).innerGlass(cornerRadius: 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Top Apps").font(.system(size: 10, weight: .bold)).foregroundStyle(.white.opacity(0.4))
                    ForEach(Array(insights.topApps.enumerated()), id: \.offset) { _, app in
                        HStack {
                            Text(app.0).font(.system(size: 11)).foregroundStyle(.white.opacity(0.7))
                            Spacer()
                            Text("\(app.1, specifier: "%.1f")h").font(.system(size: 10, design: .monospaced)).foregroundStyle(.white.opacity(0.4))
                            GeometryReader { geo in
                                Capsule().fill(.blue.opacity(0.3)).frame(width: geo.size.width * (app.1 / 5.0), height: 4)
                            }.frame(width: 60, height: 4)
                        }
                    }
                }.padding(10).innerGlass(cornerRadius: 10)
            }
        }.padding(20).frame(width: 380).glassBackground(cornerRadius: 24)
    }
    
    private func insightCard(_ emoji: String, _ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 3) {
            Text(emoji).font(.system(size: 18))
            Text(value).font(.system(size: 14, weight: .bold)).foregroundStyle(color)
            Text(label).font(.system(size: 8)).foregroundStyle(.white.opacity(0.3))
        }.frame(maxWidth: .infinity).padding(.vertical, 10).innerGlass(cornerRadius: 10)
    }
}

// MARK: - Collaboration Session View

struct CollaborationSessionView: View {
    @Environment(CollaborationEngine.self) private var collab
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("🤝 Collaboration").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Spacer()
                if collab.isSessionActive {
                    HStack(spacing: 4) {
                        Circle().fill(.green).frame(width: 6, height: 6)
                        Text("Live").font(.system(size: 9, weight: .bold)).foregroundStyle(.green)
                    }.padding(.horizontal, 8).padding(.vertical, 3).innerGlass(cornerRadius: 6)
                }
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 18)).foregroundStyle(.white.opacity(0.3))
                }.buttonStyle(.plain)
            }
            
            if !collab.isSessionActive {
                // Start session
                Button { collab.startSession(name: "Team Session") } label: {
                    HStack { Image(systemName: "person.2.circle.fill"); Text("Start Session") }
                        .font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(.blue.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
                }.buttonStyle(.plain)
                
                // Quick invite
                HStack(spacing: 6) {
                    ForEach(["Alex", "Sarah", "James"], id: \.self) { name in
                        Button {
                            collab.startSession(name: "Session")
                            collab.inviteParticipant(name: name, avatar: String(name.prefix(1)))
                        } label: {
                            VStack(spacing: 3) {
                                Circle().fill(.blue.opacity(0.2)).frame(width: 36, height: 36).overlay(
                                    Text(String(name.prefix(1))).font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                                )
                                Text(name).font(.system(size: 8)).foregroundStyle(.white.opacity(0.4))
                            }
                        }.buttonStyle(.plain)
                    }
                }
            } else {
                // Active session
                VStack(spacing: 6) {
                    ForEach(collab.participants) { p in
                        HStack(spacing: 8) {
                            Circle().fill(p.color.opacity(0.3)).frame(width: 30, height: 30).overlay(
                                Text(p.avatar).font(.system(size: 10, weight: .bold)).foregroundStyle(.white)
                            )
                            Text(p.name).font(.system(size: 11, weight: .medium)).foregroundStyle(.white)
                            Spacer()
                            Circle().fill(p.isOnline ? .green : .gray).frame(width: 6, height: 6)
                            if p.isInPrivacyBubble {
                                Image(systemName: "lock.shield").font(.system(size: 10)).foregroundStyle(.orange)
                            }
                        }.padding(6).innerGlass(cornerRadius: 8)
                    }
                }
                
                HStack(spacing: 8) {
                    Button { collab.togglePresentation() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: collab.isPresenting ? "rectangle.fill.on.rectangle.fill" : "play.rectangle")
                            Text(collab.isPresenting ? "Stop" : "Present")
                        }.font(.system(size: 10, weight: .bold)).foregroundStyle(.white)
                            .padding(.horizontal, 12).padding(.vertical, 6).innerGlass(cornerRadius: 6)
                    }.buttonStyle(.plain)
                    
                    Button { collab.endSession() } label: {
                        Text("End Session").font(.system(size: 10, weight: .bold)).foregroundStyle(.red)
                            .padding(.horizontal, 12).padding(.vertical, 6).innerGlass(cornerRadius: 6)
                    }.buttonStyle(.plain)
                }
            }
        }.padding(20).frame(width: 380).glassBackground(cornerRadius: 24)
    }
}
