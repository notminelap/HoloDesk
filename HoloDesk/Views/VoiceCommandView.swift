// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Voice Command View

/// Floating voice command overlay — shows when listening with waveform visualization.
struct VoiceCommandView: View {
    
    @Environment(WorkspaceStore.self) private var store
    @State private var waveformHeights: [CGFloat] = Array(repeating: 4, count: 12)
    @State private var animateWave = false
    
    var body: some View {
        if store.isListening {
            VStack(spacing: 12) {
                // Waveform visualization
                HStack(spacing: 3) {
                    ForEach(0..<12, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(LinearGradient.accentGradient)
                            .frame(width: 3, height: animateWave ? CGFloat.random(in: 4...24) : 4)
                            .animation(
                                .easeInOut(duration: 0.3)
                                .repeatForever()
                                .delay(Double(i) * 0.05),
                                value: animateWave
                            )
                    }
                }
                .frame(height: 24)
                
                // Transcript
                if !store.voiceTranscript.isEmpty {
                    Text(store.voiceTranscript)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .transition(.opacity)
                } else {
                    Text("Listening for commands...")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                // Available commands hint
                HStack(spacing: 8) {
                    commandHint("\"Open work mode\"")
                    commandHint("\"Save workspace\"")
                    commandHint("\"Add notes\"")
                }
            }
            .padding(16)
            .glassBackground(cornerRadius: 20)
            .frame(width: 350)
            .onAppear { animateWave = true }
            .onDisappear { animateWave = false }
            .transition(.spatialFlyUp)
        }
    }
    
    private func commandHint(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .medium, design: .monospaced))
            .foregroundStyle(.white.opacity(0.35))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .innerGlass(cornerRadius: 6)
    }
}
