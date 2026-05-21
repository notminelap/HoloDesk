// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Save / Load Panel View

/// Panel for managing saved workspace presets — list, load, rename, delete.
struct SaveLoadPanelView: View {
    
    @Environment(WorkspaceStore.self) private var store
    @Environment(WindowManager.self) private var windowManager
    @Binding var isPresented: Bool
    
    @State private var editingId: UUID?
    @State private var editName = ""
    
    var body: some View {
        VStack(spacing: 14) {
            // Header
            HStack {
                Image(systemName: "tray.2.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.holoPrimary)
                
                Text("Saved Workspaces")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
            
            Divider().overlay(Color.white.opacity(0.08))
            
            if store.savedWorkspaces.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(store.savedWorkspaces) { workspace in
                            workspaceCard(workspace)
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
            
            // Save current
            Button {
                store.saveCurrentWorkspace()
                HapticManager.shared.workspaceSaved()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Save Current Layout")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(LinearGradient.accentGradient, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(width: 380)
        .glassBackground(cornerRadius: 24)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundStyle(.white.opacity(0.2))
            
            Text("No saved workspaces yet")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.4))
            
            Text("Set up your windows and save the layout")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(.vertical, 30)
    }
    
    // MARK: - Workspace Card
    
    private func workspaceCard(_ workspace: Workspace) -> some View {
        HStack(spacing: 12) {
            // Mode icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.modeTint(for: workspace.mode).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: workspace.mode.iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.modeTint(for: workspace.mode))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(workspace.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                
                HStack(spacing: 4) {
                    Text("\(workspace.windows.count) windows")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.4))
                    
                    Text("•")
                        .foregroundStyle(.white.opacity(0.2))
                    
                    Text(workspace.mode.displayName)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.modeTint(for: workspace.mode).opacity(0.7))
                }
            }
            
            Spacer()
            
            // Load button
            Button {
                Task {
                    HapticManager.shared.modeSwitched()
                    await windowManager.transitionToMode(workspace.mode, in: store)
                }
            } label: {
                Text("Load")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.holoPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .innerGlass(cornerRadius: 8)
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .innerGlass(cornerRadius: 14)
    }
}
