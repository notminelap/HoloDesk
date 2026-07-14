// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI

// MARK: - Enhanced Dock View

/// Bottom dock bar with action buttons — Apple-style dock with expanded feature set.
struct DockView: View {
    
    let onAddWindow: () -> Void
    let onDemo: () -> Void
    let onToggleImmersive: () -> Void
    let onSave: () -> Void
    let onVoice: () -> Void
    
    @Environment(WorkspaceStore.self) private var store
    @Environment(SpatialAudioManager.self) private var audio
    
    @State private var showEnvironment = false
    @State private var showSharePlay = false
    @State private var showApps = false
    @State private var showLayout = false
    @State private var showTimeline = false
    @State private var showProductivity = false
    @State private var showGestures = false
    @State private var showNotifications = false
    @State private var showScreenshots = false
    @State private var showThemes = false
    @State private var showPortals = false
    @State private var showWellness = false
    @State private var showSmartHome = false
    @State private var showAchievements = false
    @State private var showPrivacy = false
    @State private var showEcosystem = false
    @State private var showCreative = false
    @State private var showPowerUser = false
    @State private var showAutomation = false
    @State private var showTemplates = false
    
    // Environment managers
    @Environment(WorkspaceTimelineManager.self) private var timelineManager
    @Environment(WorkflowTemplateManager.self) private var templateManager
    
    // Managers (created locally for now — in production, inject via environment)
    @State private var envManager = EnvironmentEffectsManager()
    @State private var sharePlayManager = SharePlayManager()
    @State private var productivityTracker = ProductivityTracker()
    @State private var gestureManager = GestureShortcutManager()
    @State private var notificationManager = NotificationManager()
    @State private var screenshotManager = SpatialScreenshotManager()
    @State private var themeManager = ThemeManager()
    @State private var wellnessManager = WellnessManager()
    @State private var smartHomeHub = SmartHomeHub()
    @State private var achievementSystem = AchievementSystem()
    
    var body: some View {
        VStack(spacing: 6) {
            // Primary dock
            HStack(spacing: 4) {
                dockButton(icon: "house.fill", label: "Home") {
                    store.loadPreset(mode: .work)
                    HapticManager.shared.mediumTap()
                }
                
                dockButton(icon: "plus.rectangle.on.rectangle", label: "Add") {
                    onAddWindow()
                }
                
                dockButton(
                    icon: store.isImmersiveSpaceOpen ? "cube.fill" : "cube.transparent",
                    label: "Space"
                ) {
                    onToggleImmersive()
                }
                
                dockButton(icon: "square.and.arrow.down", label: "Save") {
                    onSave()
                }
                
                dockButton(
                    icon: store.isListening ? "mic.fill" : "mic",
                    label: "Voice",
                    isActive: store.isListening
                ) {
                    onVoice()
                }
                
                dockDivider
                
                dockButton(icon: "rectangle.3.group", label: "Layout") {
                    showLayout = true
                }
                
                dockButton(icon: "sparkles.rectangle.stack", label: "Effects") {
                    showEnvironment = true
                }
                
                dockButton(icon: "paintpalette.fill", label: "Theme") {
                    showThemes = true
                }
                
                dockDivider
                
                dockButton(icon: "sparkles", label: "Demo", isAccent: true) {
                    onDemo()
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .innerGlass(cornerRadius: 20)
            
            // Secondary dock (smaller)
            HStack(spacing: 3) {
                miniDockButton(icon: "chart.bar", label: "Stats") { showProductivity = true }
                miniDockButton(icon: "clock.arrow.circlepath", label: "History") { showTimeline = true }
                miniDockButton(icon: "person.2", label: "Share") { showSharePlay = true }
                miniDockButton(icon: "square.grid.3x3", label: "Apps") { showApps = true }
                miniDockButton(icon: "doc.text.grid.cols", label: "Templates") { showTemplates = true }
                miniDockButton(icon: "hand.raised.fingers.spread", label: "Gestures") { showGestures = true }
                miniDockButton(icon: "camera.viewfinder", label: "Capture") { showScreenshots = true }
                miniDockButton(icon: "door.left.hand.open", label: "Portals") { showPortals = true }
                
                // Notification badge
                miniDockButton(
                    icon: "bell.fill", label: "Alerts",
                    badge: notificationManager.unreadCount
                ) { showNotifications = true }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .innerGlass(cornerRadius: 14)
            
            // Tertiary dock — system panels
            HStack(spacing: 3) {
                miniDockButton(icon: "leaf.fill", label: "Wellness") { showWellness = true }
                miniDockButton(icon: "house.fill", label: "Home") { showSmartHome = true }
                miniDockButton(icon: "trophy.fill", label: "Awards") { showAchievements = true }
                miniDockButton(icon: "lock.shield", label: "Privacy") { showPrivacy = true }
                miniDockButton(icon: "apple.logo", label: "Ecosystem") { showEcosystem = true }
                miniDockButton(icon: "paintbrush.fill", label: "Creative") { showCreative = true }
                miniDockButton(icon: "bolt.fill", label: "Power") { showPowerUser = true }
                miniDockButton(icon: "gearshape.2", label: "Auto") { showAutomation = true }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .innerGlass(cornerRadius: 14)
        }
        // Sheets
        .sheet(isPresented: $showEnvironment) {
            EnvironmentEffectsView(manager: envManager, isPresented: $showEnvironment)
        }
        .sheet(isPresented: $showSharePlay) {
            SharePlayView(manager: sharePlayManager, isPresented: $showSharePlay)
                .environment(store)
        }
        .sheet(isPresented: $showApps) {
            AppLauncherView(isPresented: $showApps)
        }
        .sheet(isPresented: $showLayout) {
            SnapLayoutPickerView(isPresented: $showLayout)
                .environment(store)
        }
        .sheet(isPresented: $showTimeline) {
            WorkspaceTimelineView(timeline: timelineManager, isPresented: $showTimeline)
                .environment(store)
        }
        .sheet(isPresented: $showTemplates) {
            WorkflowTemplatePickerView(manager: templateManager, isPresented: $showTemplates)
                .environment(store)
        }
        .sheet(isPresented: $showProductivity) {
            ProductivityDashboardView(tracker: productivityTracker, isPresented: $showProductivity)
        }
        .sheet(isPresented: $showGestures) {
            GestureShortcutsView(manager: gestureManager, isPresented: $showGestures)
        }
        .sheet(isPresented: $showNotifications) {
            NotificationCenterView(manager: notificationManager, isPresented: $showNotifications)
        }
        .sheet(isPresented: $showScreenshots) {
            ScreenshotGalleryView(manager: screenshotManager, isPresented: $showScreenshots)
                .environment(store)
        }
        .sheet(isPresented: $showThemes) {
            ThemePickerView(themeManager: themeManager, isPresented: $showThemes)
        }
        .sheet(isPresented: $showPortals) {
            PortalGalleryView(isPresented: $showPortals)
                .environment(store)
        }
        .sheet(isPresented: $showWellness) {
            WellnessDashboardView(wellness: wellnessManager, isPresented: $showWellness)
        }
        .sheet(isPresented: $showSmartHome) {
            SmartHomeView(hub: smartHomeHub, isPresented: $showSmartHome)
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView(system: achievementSystem, isPresented: $showAchievements)
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyDashboardView(isPresented: $showPrivacy)
        }
        .sheet(isPresented: $showEcosystem) {
            AppleEcosystemPanel(isPresented: $showEcosystem)
        }
        .sheet(isPresented: $showCreative) {
            CreativeStudioPanel(isPresented: $showCreative)
        }
        .sheet(isPresented: $showPowerUser) {
            PowerUserPanel(isPresented: $showPowerUser)
        }
        .sheet(isPresented: $showAutomation) {
            AutomationPanel(isPresented: $showAutomation)
        }
    }
    
    // MARK: - Dock Divider
    
    private var dockDivider: some View {
        Divider()
            .frame(height: 24)
            .overlay(Color.white.opacity(0.12))
    }
    
    // MARK: - Primary Dock Button
    
    private func dockButton(
        icon: String,
        label: String,
        isActive: Bool = false,
        isAccent: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            audio.playSFX(.tap)
            action()
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(
                        isAccent ? AnyShapeStyle(LinearGradient.accentGradient) :
                        isActive ? AnyShapeStyle(Color.holoPrimary) :
                        AnyShapeStyle(Color.white.opacity(0.7))
                    )
                    .frame(width: 32, height: 24)
                
                Text(label)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .frame(width: 46)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .hoverGlow()
        .accessibilityLabel(label)
        .accessibilityHint(isActive ? "Currently active. Double tap to toggle." : "Double tap to activate.")
    }
    
    // MARK: - Mini Dock Button
    
    private func miniDockButton(
        icon: String,
        label: String,
        badge: Int = 0,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            audio.playSFX(.tap)
            action()
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 2) {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(width: 24, height: 18)
                    
                    Text(label)
                        .font(.system(size: 7, weight: .medium))
                        .foregroundStyle(.white.opacity(0.35))
                }
                .frame(width: 42)
                
                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(.red, in: Capsule())
                        .offset(x: 4, y: -2)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .hoverGlow()
        .accessibilityLabel(label)
        .accessibilityHint(badge > 0 ? "\(badge) notifications. Double tap to open." : "Double tap to open.")
    }
}
