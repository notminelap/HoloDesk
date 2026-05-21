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
            // Connection lines
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
                            
                            context.stroke(path, with: .color(.white.opacity(0.15)), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
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
                            position: CGPoint(x: CGFloat.random(in: 50...350), y: CGFloat.random(in: 50...250)),
                            color: [Color.pink, .cyan, .orange, .green, .purple].randomElement()!,
                            connections: selectedNodeId != nil ? [selectedNodeId!] : [],
                            emoji: ["💡", "🔑", "🎯", "📌", "🧩"].randomElement()!
                        )
                        nodes.append(newNode)
                        HapticManager.shared.lightTap()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.holoPrimary)
                    }
                    .buttonStyle(.plain)
                    .padding(8)
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
        } label: {
            HStack(spacing: 4) {
                Text(node.emoji)
                    .font(.system(size: 11))
                Text(node.text)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(node.color.opacity(isSelected ? 0.35 : 0.2))
                    .overlay(
                        Capsule()
                            .strokeBorder(isSelected ? node.color : .clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
