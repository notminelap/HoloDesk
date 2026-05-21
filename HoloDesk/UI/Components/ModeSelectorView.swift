// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Mode Selector View

/// Horizontal pill selector for workspace modes — Work, Study, Cinema, Gaming.
struct ModeSelectorView: View {
    
    @Environment(WorkspaceStore.self) private var store
    @Environment(WindowManager.self) private var windowManager
    @Environment(SpatialAudioManager.self) private var audio
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(WorkspaceMode.allCases.filter { $0 != .custom }) { mode in
                modeButton(mode)
            }
        }
        .padding(4)
        .innerGlass(cornerRadius: 18)
    }
    
    private func modeButton(_ mode: WorkspaceMode) -> some View {
        let isSelected = store.currentMode == mode
        
        return Button {
            guard !windowManager.isTransitioning else { return }
            audio.playSFX(.success)
            Task {
                await windowManager.transitionToMode(mode, in: store)
            }
        } label: {
            HStack(spacing: 6) {
                Text(mode.emoji)
                    .font(.system(size: 13))
                
                Text(mode.displayName)
                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.modeTint(for: mode).opacity(0.35))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(Color.modeTint(for: mode).opacity(0.5), lineWidth: 0.5)
                            )
                    }
                }
            )
            .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .animation(.spatialInteract, value: isSelected)
        .disabled(windowManager.isTransitioning)
    }
}
