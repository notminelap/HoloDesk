// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import Observation

// MARK: - Window Constellations 🌐

/// Visualizes relationships between spatial windows as glowing light beams.
/// When 3+ windows are open, thin pulsing lines connect semantically related apps,
/// creating a living constellation map of the user's workspace.
@Observable
final class WindowConstellations {
    
    var isEnabled = true
    var connections: [Constellation] = []
    var pulsePhase: Double = 0
    
    // ────────────────────────────────────────
    // MARK: - Constellation Model
    // ────────────────────────────────────────
    
    struct Constellation: Identifiable {
        let id = UUID()
        var fromType: WindowType
        var toType: WindowType
        var relationship: String
        var strength: Double  // 0.0 - 1.0 (visual intensity)
        var color: Color
    }
    
    // ────────────────────────────────────────
    // MARK: - Relationship Map
    // ────────────────────────────────────────
    
    /// Defines which window types are semantically connected.
    private static let relationships: [(WindowType, WindowType, String, Color)] = [
        // Productivity links
        (.notes,        .todo,          "Tasks linked",       .cyan),
        (.calendar,     .todo,          "Due dates synced",   .blue),
        (.notes,        .calendar,      "Schedule refs",      .indigo),
        (.kanban,       .todo,          "Sprint items",       .purple),
        (.mail,         .calendar,      "Meeting invites",    .teal),
        (.notes,        .mindMap,       "Ideas connected",    .pink),
        (.spreadsheet,  .stocks,        "Data analysis",      .green),
        
        // Creative links
        (.music,        .visualizer,    "Audio stream",       .orange),
        (.spotify,      .visualizer,    "Audio stream",       .green),
        (.music,        .ambienceMixer, "Sound layers",       .mint),
        (.podcast,      .notes,         "Show notes",         .yellow),
        
        // Dev links
        (.codeEditor,   .terminal,      "Run commands",       .green),
        (.codeEditor,   .systemMonitor, "Performance",        .red),
        (.terminal,     .systemMonitor, "System stats",       .orange),
        
        // Communication links
        (.messages,     .facetime,      "Conversations",      .blue),
        (.mail,         .messages,      "Contacts linked",    .cyan),
    ]
    
    // ────────────────────────────────────────
    // MARK: - Update Connections
    // ────────────────────────────────────────
    
    /// Recalculates which constellations should be visible based on active windows.
    func updateConnections(activeWindowTypes: [WindowType]) {
        guard isEnabled else {
            connections.removeAll()
            return
        }
        
        var newConnections: [Constellation] = []
        
        for (fromType, toType, relationship, color) in Self.relationships {
            if activeWindowTypes.contains(fromType) && activeWindowTypes.contains(toType) {
                let conn = Constellation(
                    fromType: fromType,
                    toType: toType,
                    relationship: relationship,
                    strength: 0.6,
                    color: color
                )
                newConnections.append(conn)
            }
        }
        
        connections = newConnections
    }
    
    /// Whether there are active visible constellations.
    var hasActiveConstellations: Bool {
        isEnabled && !connections.isEmpty
    }
}

// MARK: - Constellation Overlay View

/// Renders the constellation connections as a status indicator in the control panel.
struct ConstellationIndicator: View {
    let constellations: WindowConstellations
    
    @State private var pulsePhase: Double = 0
    
    var body: some View {
        if constellations.hasActiveConstellations {
            VStack(spacing: 4) {
                // Header
                HStack(spacing: 4) {
                    Image(systemName: "link")
                        .font(.system(size: 8))
                        .foregroundStyle(.cyan.opacity(0.6))
                    Text("CONSTELLATIONS")
                        .font(.system(size: 7, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.35))
                    Spacer()
                    Text("\(constellations.connections.count)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundStyle(.cyan.opacity(0.6))
                }
                
                // Connection list
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(constellations.connections) { conn in
                            constellationChip(conn)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }
    
    private func constellationChip(_ conn: WindowConstellations.Constellation) -> some View {
        HStack(spacing: 3) {
            // From icon
            Image(systemName: conn.fromType.iconName)
                .font(.system(size: 7))
                .foregroundStyle(conn.color)
            
            // Pulsing beam
            HStack(spacing: 1) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(conn.color)
                        .frame(width: 2, height: 2)
                        .opacity(0.3 + 0.5 * abs(sin(pulsePhase + Double(i) * 0.8)))
                }
            }
            
            // To icon
            Image(systemName: conn.toType.iconName)
                .font(.system(size: 7))
                .foregroundStyle(conn.color)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(conn.color.opacity(0.08))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(conn.color.opacity(0.2), lineWidth: 0.5)
        )
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                pulsePhase = .pi * 2
            }
        }
    }
}
