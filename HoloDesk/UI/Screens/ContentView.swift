// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Content View

/// Main control window — the primary HoloDesk UI with dock, mode selector,
/// AI assistant, room selector, and all controls.
struct ContentView: View {
    
    @Environment(WorkspaceStore.self) private var store
    @Environment(WindowManager.self) private var windowManager
    @Environment(VoiceCommandManager.self) private var voiceManager
    @Environment(RoomManager.self) private var roomManager
    @Environment(SpatialAudioManager.self) private var audio
    @Environment(AccessibilityEngine.self) private var accessibility
    @Environment(SpatialEasterEggs.self) private var easterEggs
    @Environment(HoloPet.self) private var holoPet
    @Environment(WindowConstellations.self) private var constellations
    @Environment(TimeAwareAtmosphere.self) private var atmosphere
    @Environment(\.openWindow) private var openWindow
    #if os(visionOS)
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    #endif
    
    @State private var aiAssistant = AIAssistantManager()
    @State private var showWindowPicker = false
    @State private var showCommandPalette = false
    @State private var showSaveDialog = false
    @State private var showSettings = false
    @State private var customWorkspaceName = ""
    @State private var isAppeared = false
    @State private var isOnboardingComplete = UserDefaults.standard.bool(forKey: "holodesk_onboarding_complete")
    @State private var isSplashComplete = false
    @State private var showGuidedDemo = false
    
    var body: some View {
        ZStack {
            if !isSplashComplete {
                SplashView(isComplete: $isSplashComplete)
                    .transition(.opacity)
            } else if !isOnboardingComplete {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
                    .transition(.spatialAppear)
            } else {
                mainContent
                    .transition(.spatialFlyUp)
            }
        }
        .animation(.spatialTransition, value: isOnboardingComplete)
        .animation(.easeInOut(duration: 0.6), value: isSplashComplete)
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        ZStack {
            Color.clear
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.bottom, 6)
                
                // Room selector
                RoomSelectorView(roomManager: roomManager)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 8)
                
                Spacer()
                
                // Window Constellations indicator
                if constellations.hasActiveConstellations {
                    ConstellationIndicator(constellations: constellations)
                        .padding(.bottom, 4)
                }
                
                // Active windows indicator
                if !store.activeWindows.isEmpty {
                    activeWindowsBar
                        .padding(.bottom, 6)
                }
                
                // Spatial file objects bar
                spatialFilesBar
                    .padding(.bottom, 6)
                
                // Mode Selector
                ModeSelectorView()
                    .padding(.bottom, 10)
                
                // Bottom Dock
                DockView(
                    onAddWindow: { showWindowPicker = true },
                    onDemo: { showGuidedDemo = true },
                    onToggleImmersive: { toggleImmersive() },
                    onSave: { showSaveDialog = true },
                    onVoice: { toggleVoice() }
                )
            }
            .padding(16)
            
            // AI Buddy overlay (bottom-right)
            VStack {
                Spacer()
                HStack {
                    // HoloPet (bottom-left)
                    HoloPetView(pet: holoPet)
                    
                    Spacer()
                    
                    // AI Buddy (bottom-right)
                    AIBuddyView(assistant: aiAssistant)
                        .environment(store)
                        .environment(windowManager)
                }
            }
            .padding(16)
            
            // Easter Egg: Confetti overlay
            ConfettiOverlay(particles: easterEggs.confettiEmojis, isActive: easterEggs.showConfetti)
            
            // Easter Egg: Secret message overlay
            if easterEggs.secretMessage != nil {
                SecretMessageOverlay(message: easterEggs.secretMessage)
            }

            // Command Palette overlay (⌘K)
            if showCommandPalette {
                CommandPaletteView(
                    isPresented: $showCommandPalette,
                    onSave: { showSaveDialog = true },
                    onToggleImmersive: { toggleImmersive() },
                    onDemo: { showGuidedDemo = true },
                    onSettings: { showSettings = true }
                )
                .transition(.spatialAppear)
                .zIndex(10)
            }
        }
        .glassBackground(cornerRadius: 32)
        .timeAwareTint(atmosphere)
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: showCommandPalette)
        .frame(width: 620, height: 480)
        .spawnAnimation(isPresented: isAppeared)
        .onAppear {
            isAppeared = true
            if store.activeWindows.isEmpty {
                store.loadPreset(mode: .work)
                spawnAllWindows()
            }
            // Update constellations whenever windows change
            constellations.updateConnections(activeWindowTypes: store.activeWindows.map { $0.type })
        }
        .sheet(isPresented: $showWindowPicker) {
            windowPickerSheet
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(isPresented: $showSettings)
                .environment(store)
        }
        .alert("Save Workspace", isPresented: $showSaveDialog) {
            TextField("Workspace name", text: $customWorkspaceName)
            Button("Save") {
                store.saveCurrentWorkspace(name: customWorkspaceName.isEmpty ? nil : customWorkspaceName)
                holoPet.onWorkspaceSaved()
                // Also save to active room
                if let roomId = roomManager.activeRoomId {
                    let workspace = Workspace(
                        name: customWorkspaceName.isEmpty ? store.currentMode.displayName : customWorkspaceName,
                        mode: store.currentMode,
                        windows: store.activeWindows
                    )
                    roomManager.saveWorkspaceToRoom(roomId: roomId, workspace: workspace)
                }
                customWorkspaceName = ""
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter a name for this workspace layout.")
        }
        .sheet(isPresented: $showGuidedDemo) {
            GuidedDemoView(isPresented: $showGuidedDemo)
                .environment(store)
                .environment(windowManager)
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            // App icon & title
            HStack(spacing: 10) {
                HoloLogoView(size: 36, isAnimated: true)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("HoloDesk")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.green)
                            .frame(width: 6, height: 6)
                        Text("Spatial Workspace Active")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                }
            }
            
            Spacer()
            
            // Room indicator
            if let room = roomManager.activeRoom {
                HStack(spacing: 5) {
                    Text(room.emoji)
                        .font(.system(size: 12))
                    Text(room.name)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .innerGlass(cornerRadius: 10)
            }
            
            // Time-aware atmosphere indicator
            AtmosphereIndicator(atmosphere: atmosphere)
            
            // Current mode badge
            HStack(spacing: 6) {
                Text(store.currentMode.emoji)
                    .font(.system(size: 14))
                Text(store.currentMode.displayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .innerGlass(cornerRadius: 16)
            
            // Command palette (⌘K)
            Button {
                audio.playSFX(.tap)
                showCommandPalette = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                    Text("⌘K")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.35))
                }
                .padding(.horizontal, 8)
                .frame(height: 30)
                .innerGlass(cornerRadius: 8)
            }
            .buttonStyle(.plain)
            .hoverGlow()
            .keyboardShortcut("k", modifiers: .command)
            .accessibilityLabel("Command palette")
            .accessibilityHint("Search and launch apps, modes, and actions.")

            // Settings button
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 30, height: 30)
                    .innerGlass(cornerRadius: 8)
            }
            .buttonStyle(.plain)
            
            // Voice indicator
            if store.isListening {
                voiceIndicator
            }
        }
    }
    
    // MARK: - Voice Indicator
    
    private var voiceIndicator: some View {
        HStack(spacing: 6) {
            // Animated waveform bars
            HStack(spacing: 2) {
                ForEach(0..<4, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.red)
                        .frame(width: 2, height: store.isListening ? CGFloat.random(in: 4...12) : 4)
                        .animation(
                            .easeInOut(duration: 0.3).repeatForever().delay(Double(i) * 0.1),
                            value: store.isListening
                        )
                }
            }
            
            Text(store.voiceTranscript.isEmpty ? "Listening..." : store.voiceTranscript)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(1)
                .frame(maxWidth: 120)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .innerGlass(cornerRadius: 12)
        .transition(.spatialAppear)
    }
    
    // MARK: - Active Windows Bar
    
    private var activeWindowsBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Active Windows")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.4))
                    .textCase(.uppercase)
                
                Spacer()
                
                Text("\(store.activeWindows.count)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.holoPrimary)
            }
            .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(store.activeWindows) { window in
                        windowChip(window)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .frame(height: 50)
    }
    
    private func windowChip(_ window: SpatialWindow) -> some View {
        HStack(spacing: 5) {
            Image(systemName: window.type.iconName)
                .font(.system(size: 10))
                .foregroundStyle(Color.windowAccent(for: window.type))
            
            Text(window.type.displayName)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            
            Button {
                windowManager.dismissWindow(id: window.id, in: store)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(.white.opacity(0.35))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .innerGlass(cornerRadius: 8)
    }
    
    // MARK: - Spatial Files Bar
    
    private var spatialFilesBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SpatialFileType.allCases) { fileType in
                    Button {
                        // Add spatial file to immersive space
                        // This triggers ImmersiveSpaceView to spawn the object
                    } label: {
                        VStack(spacing: 3) {
                            Text(fileType.emoji)
                                .font(.system(size: 16))
                            Text(fileType.displayName)
                                .font(.system(size: 8, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                                .lineLimit(1)
                        }
                        .frame(width: 56, height: 42)
                        .innerGlass(cornerRadius: 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
        .frame(height: 46)
    }
    
    // MARK: - Window Picker Sheet
    
    private var windowPickerSheet: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Add Window")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button {
                    showWindowPicker = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
            
            Text("Tap to place a window in your space")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.5))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(WindowType.allCases) { type in
                    Button {
                        windowManager.spawnWindow(type: type, in: store)
                        openWindow(id: "spatial-window", value: store.activeWindows.last?.id)
                        showWindowPicker = false
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.windowAccent(for: type).opacity(0.15))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: type.iconName)
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.windowAccent(for: type))
                            }
                            
                            Text(type.displayName)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .innerGlass()
                        .hoverGlow()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(24)
        .frame(width: 420)
        .glassBackground(cornerRadius: 24)
    }
    
    // MARK: - Actions
    
    private func spawnAllWindows() {
        for window in store.activeWindows {
            openWindow(id: "spatial-window", value: window.id)
        }
    }
    
    private func runDemo() {
        Task {
            await windowManager.runDemoSequence(in: store)
        }
    }
    
    private func toggleImmersive() {
        Task {
            #if os(visionOS)
            if store.isImmersiveSpaceOpen {
                audio.playSFX(.windowClose)
                audio.stopAmbientDrone()
                await dismissImmersiveSpace()
                store.isImmersiveSpaceOpen = false
                store.isLidarScanning = false
                store.lidarScanProgress = 0.0
            } else {
                audio.playSFX(.cosmicSweep)
                store.isLidarScanning = true
                store.lidarScanProgress = 0.0
                let result = await openImmersiveSpace(id: "immersive")
                store.isImmersiveSpaceOpen = (result == .opened)
                if store.isImmersiveSpaceOpen {
                    audio.startAmbientDrone()
                } else {
                    store.isLidarScanning = false
                }
            }
            #else
            store.isImmersiveSpaceOpen.toggle()
            if store.isImmersiveSpaceOpen {
                audio.playSFX(.cosmicSweep)
                audio.startAmbientDrone()
            } else {
                audio.playSFX(.windowClose)
                audio.stopAmbientDrone()
            }
            #endif
        }
    }
    
    private func toggleVoice() {
        if store.isListening {
            voiceManager.stopListening()
            audio.playSFX(.tap)
        } else {
            voiceManager.startListening(store: store, windowManager: windowManager)
            audio.playSFX(.aiActivate)
        }
    }
}
