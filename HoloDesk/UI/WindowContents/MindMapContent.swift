// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Mind Map Content

/// Spatial mind map — nodes with connections, add/edit/link ideas visually.
struct MindMapContent: View {
    
    @State private var nodes: [MindNode] = MindNode.defaults
    @State private var selectedNodeId: UUID?
    @State private var newNodeText = ""
    @State private var audio = SpatialAudioManager.shared
    
    struct MindNode: Identifiable {
        let id = UUID()
        var text: String
        var position: CGPoint
        var color: Color
        var connections: [UUID]
        var emoji: String
        
        static var defaults: [MindNode] {
            let center = MindNode(text: "HoloDesk", position: CGPoint(x: 200, y: 150), color: .holoPrimary, connections: [], emoji: "🧊")
            let ux = MindNode(text: "UX Design", position: CGPoint(x: 70, y: 60), color: .pink, connections: [center.id], emoji: "🎨")
            let tech = MindNode(text: "Technology", position: CGPoint(x: 330, y: 60), color: .cyan, connections: [center.id], emoji: "⚙️")
            let features = MindNode(text: "Features", position: CGPoint(x: 70, y: 240), color: .orange, connections: [center.id], emoji: "✨")
            let market = MindNode(text: "Market", position: CGPoint(x: 330, y: 240), color: .green, connections: [center.id], emoji: "📈")
            let glass = MindNode(text: "Glassmorphism", position: CGPoint(x: 30, y: 130), color: .purple, connections: [ux.id], emoji: "🪟")
            let arkit = MindNode(text: "ARKit", position: CGPoint(x: 380, y: 130), color: .blue, connections: [tech.id], emoji: "📱")
            return [center, ux, tech, features, market, glass, arkit]
        }
    }
    
    var body: some View {
        ZStack {
            // Neural connection lines with travelling energy pulses
            TimelineView(.animation) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                Canvas { context, size in
                    for node in nodes {
                        for connId in node.connections {
                            if let target = nodes.first(where: { $0.id == connId }) {
                                var path = Path()
                                path.move(to: node.position)
                                
                                // Bezier curve
                                let mid = CGPoint(
                                    x: (node.position.x + target.position.x) / 2,
                                    y: (node.position.y + target.position.y) / 2
                                )
                                path.addQuadCurve(to: target.position, control: CGPoint(x: mid.x, y: mid.y - 20))
                                
                                // Draw base connections track
                                context.stroke(
                                    path,
                                    with: .color(.white.opacity(0.08)),
                                    style: StrokeStyle(lineWidth: 1.5)
                                )
                                
                                // Draw traveling neon light pulse dash along the Bezier links
                                let dashPhase = -time * 36.0
                                context.stroke(
                                    path,
                                    with: .linearGradient(
                                        Gradient(colors: [node.color.opacity(0.8), target.color.opacity(0.8)]),
                                        startPoint: node.position,
                                        endPoint: target.position
                                    ),
                                    style: StrokeStyle(
                                        lineWidth: 2.2,
                                        lineCap: .round,
                                        dash: [8, 14],
                                        dashPhase: CGFloat(dashPhase)
                                    )
                                )
                            }
                        }
                    }
                }
            }
            
            // Nodes
            ForEach(Array(nodes.enumerated()), id: \.element.id) { index, node in
                nodeView(node, index: index)
                    .position(node.position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                nodes[index].position = value.location
                            }
                    )
            }
            
            // Add node button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        let newNode = MindNode(
                            text: "New Idea",
                            position: CGPoint(x: CGFloat.random(in: 60...340), y: CGFloat.random(in: 60...240)),
                            color: [Color.pink, .cyan, .orange, .green, .purple, Color.holoPrimary].randomElement() ?? .pink,
                            connections: selectedNodeId != nil ? [selectedNodeId!] : [],
                            emoji: ["💡", "🔑", "🎯", "📌", "🧩", "🌪️"].randomElement() ?? "💡"
                        )
                        nodes.append(newNode)
                        audio.playSFX(.success)
                        HapticManager.shared.mediumTap()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.holoPrimary)
                            .shadow(color: Color.holoPrimary.opacity(0.4), radius: 6)
                    }
                    .buttonStyle(.plain)
                    .padding(10)
                }
                Spacer()
            }
        }
        .padding(8)
    }
    
    private func nodeView(_ node: MindNode, index: Int) -> some View {
        let isSelected = selectedNodeId == node.id
        
        return Button {
            selectedNodeId = selectedNodeId == node.id ? nil : node.id
            audio.playSFX(.softTick)
            HapticManager.shared.lightTap()
        } label: {
            HStack(spacing: 5) {
                Text(node.emoji)
                    .font(.system(size: 12))
                Text(node.text)
                    .font(.system(size: 10, weight: isSelected ? .bold : .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(node.color.opacity(isSelected ? 0.38 : 0.16))
                    .shadow(color: isSelected ? node.color.opacity(0.5) : .clear, radius: 10)
                    .overlay(
                        Capsule()
                            .strokeBorder(isSelected ? node.color : .white.opacity(0.12), lineWidth: isSelected ? 1.5 : 0.8)
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.08 : 1.0)
        .animation(.spring(response: 0.32, dampingFraction: 0.72), value: isSelected)
    }
}
