// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import RealityKit

// MARK: - HoloDesk App (visionOS 2.0)

/// Main app entry point — configures window groups, immersive spaces, and volumes.
/// All state is centralized here and distributed via SwiftUI environment.
@main
struct HoloDeskApp: App {
    
    // ────────────────────────────────────────
    // MARK: - Core State
    // ────────────────────────────────────────
    @State private var store = WorkspaceStore()
    @State private var windowManager = WindowManager()
    @State private var voiceManager = VoiceCommandManager()
    @State private var roomManager = RoomManager()
    @State private var audio = SpatialAudioManager()
    
    // ────────────────────────────────────────
    // MARK: - Spatial Foundation
    // ────────────────────────────────────────
    @State private var deskEngine = DeskDetectionEngine()
    @State private var postureEngine = PostureEngine()
    @State private var comfortSystem = ComfortAnimationSystem()
    @State private var deskInteraction = DeskInteractionEngine()
    
    // ────────────────────────────────────────
    // MARK: - Privacy & Accessibility
    // ────────────────────────────────────────
    @State private var privacyShield = PrivacyShieldSystem()
    @State private var accessibilityEngine = AccessibilityEngine()
    
    // ────────────────────────────────────────
    // MARK: - Tracking & AI
    // ────────────────────────────────────────
    @State private var eyeTracking = EyeTrackingManager()
    @State private var screenTime = ScreenTimeTracker()
    @State private var aiIntelligence = AIWorkspaceIntelligence()
    @State private var automation = AutomationEngine()
    
    // ────────────────────────────────────────
    // MARK: - Collaboration & Ecosystem
    // ────────────────────────────────────────
    @State private var collaboration = CollaborationEngine()
    @State private var appleEcosystem = AppleEcosystemManager()
    @State private var spotlightSearch = SpotlightSpatialSearch()
    
    // ────────────────────────────────────────
    // MARK: - Creative & Power Tools
    // ────────────────────────────────────────
    @State private var creativeToolkit = CreativeToolkit()
    @State private var powerTools = PowerUserTools()
    
    // ────────────────────────────────────────
    // MARK: - Productivity
    // ────────────────────────────────────────
    @State private var stickyNotes = StickyNotesLayer()
    @State private var quickCapture = QuickCaptureInbox()
    @State private var versionHistory = VersionHistoryManager()
    @State private var smartTags = SmartTaggingSystem()
    @State private var workflowTemplates = WorkflowTemplateManager()
    
    // ────────────────────────────────────────
    // MARK: - Wellness & Life
    // ────────────────────────────────────────
    @State private var wellness = WellnessManager()
    @State private var smartHome = SmartHomeHub()
    
    // ────────────────────────────────────────
    // MARK: - Delight & Magic
    // ────────────────────────────────────────
    @State private var achievements = AchievementSystem()
    @State private var performance = PerformanceGuardian()
    @State private var deskPlants = DeskPlantSystem()
    @State private var delight = DelightSystem()
    @State private var spatialMagic = SpatialMagicEngine()
    
    // ═══════════════════════════════════════
    // MARK: - Scene Declarations
    // ═══════════════════════════════════════
    
    var body: some Scene {
        
        // ── Main Control Window ──────────────
        WindowGroup("HoloDesk", id: "main") {
            ContentView()
                .environment(store)
                .environment(windowManager)
                .environment(voiceManager)
                .environment(roomManager)
                .environment(audio)
                .environment(accessibilityEngine)
                .environment(deskEngine)
                .environment(postureEngine)
                .environment(privacyShield)
                .environment(eyeTracking)
                .environment(screenTime)
                .environment(aiIntelligence)
                .environment(collaboration)
                .environment(appleEcosystem)
                .environment(creativeToolkit)
                .environment(stickyNotes)
                .environment(quickCapture)
                .environment(smartTags)
                .environment(achievements)
                .environment(delight)
                .environment(deskPlants)
                .environment(spatialMagic)
                .environment(wellness)
                .environment(smartHome)
                .onAppear {
                    initializeApp()
                }
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 800)
        
        // ── Individual Spatial Windows ───────
        WindowGroup("Spatial Window", id: "spatial-window", for: UUID.self) { $windowId in
            if let id = windowId,
               let window = store.window(for: id) {
                SpatialWindowView(window: window)
                    .environment(store)
                    .environment(windowManager)
                    .environment(voiceManager)
                    .environment(roomManager)
                    .environment(audio)
                    .environment(accessibilityEngine)
            }
        }
        .windowStyle(.plain)
        .defaultSize(width: 450, height: 400)
        
        // ── Immersive Space ──────────────────
        ImmersiveSpace(id: "immersive") {
            ImmersiveSpaceView()
                .environment(store)
                .environment(deskEngine)
                .environment(postureEngine)
                .environment(audio)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed, .progressive, .full)
        
        // ── Volumetric Window (3D Viewer) ────
        WindowGroup("3D Viewer", id: "volumetric") {
            ModelViewerContent()
                .environment(audio)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.5, height: 0.5, depth: 0.5, in: .meters)
    }
    
    // ═══════════════════════════════════════
    // MARK: - App Initialization
    // ═══════════════════════════════════════
    
    private func initializeApp() {
        // Start audio systems
        audio.startEngine()
        audio.playSFX(.chime)
        
        // Generate daily briefing
        aiIntelligence.generateBriefing()
        aiIntelligence.generateWeeklyInsights()
        
        // Start spatial systems
        deskEngine.startScanning()
        
        // Delight system
        delight.generateGreeting()
        
        // Save launch version
        versionHistory.saveVersion(from: store, label: "Launch")
        
        // Wellness check
        wellness.checkBreak()
        
        // Auto-save setup
        performance.autoSave(store: store)
    }
}
