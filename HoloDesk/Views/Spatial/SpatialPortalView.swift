// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import RealityKit

// MARK: - Spatial Portal View

/// A portal window that shows a preview of another workspace mode —
/// look through it to see what your workspace would look like in Cinema mode, etc.
struct SpatialPortalView: View {
    let targetMode: WorkspaceMode
    let portalSize: CGSize
    
    @Environment(WorkspaceStore.self) private var store
    @Environment(WindowManager.self) private var windowManager
    
    @State private var isHovering = false
    @State private var isTransitioning = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Portal background — shows target mode colors
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.modeTint(for: targetMode).opacity(0.4),
                                Color.modeTint(for: targetMode).opacity(0.1),
                                .black.opacity(0.3)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Portal rim glow
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.modeTint(for: targetMode).opacity(isHovering ? 0.8 : 0.3),
                                Color.modeTint(for: targetMode).opacity(isHovering ? 0.4 : 0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
                    .shadow(color: Color.modeTint(for: targetMode).opacity(0.3), radius: isHovering ? 15 : 5)
                
                // Preview content
                VStack(spacing: 10) {
                    // Sparkle effect
                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.modeTint(for: targetMode))
                        .scaleEffect(isHovering ? 1.2 : 1)
                    
                    Text(targetMode.emoji)
                        .font(.system(size: 36))
                    
                    Text(targetMode.displayName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Look through to preview")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.4))
                    
                    // Mini window previews
                    HStack(spacing: 4) {
                        ForEach(0..<min(previewWindowCount, 5), id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(.white.opacity(0.15))
                                .frame(width: 20, height: 14)
                        }
                    }
                    
                    // Enter button
                    Button {
                        enterPortal()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Enter")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.modeTint(for: targetMode), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: portalSize.width, height: portalSize.height)
        }
        .glassBackground(cornerRadius: 24)
        .scaleEffect(isHovering ? 1.05 : 1)
        .animation(.spatialInteract, value: isHovering)
        .onHover { isHovering = $0 }
    }
    
    private var previewWindowCount: Int {
        switch targetMode {
        case .work:    return 5
        case .study:   return 3
        case .cinema:  return 2
        case .gaming:  return 3
        case .custom:  return 4
        }
    }
    
    private func enterPortal() {
        isTransitioning = true
        HapticManager.shared.modeSwitched()
        Task {
            await windowManager.transitionToMode(targetMode, in: store)
            isTransitioning = false
        }
    }
}

// MARK: - Portal Gallery

struct PortalGalleryView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "door.left.hand.open")
                    .font(.system(size: 16))
                    .foregroundStyle(.holoTertiary)
                Text("Workspace Portals")
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
            
            Text("Step through a portal to switch workspaces")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.4))
            
            HStack(spacing: 12) {
                ForEach([WorkspaceMode.work, .study, .cinema, .gaming], id: \.self) { mode in
                    SpatialPortalView(targetMode: mode, portalSize: CGSize(width: 130, height: 180))
                }
            }
        }
        .padding(20)
        .glassBackground(cornerRadius: 24)
    }
}
