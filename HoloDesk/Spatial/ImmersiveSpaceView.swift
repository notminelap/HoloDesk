// ─────────────────────────────────────────────────────────────────────────────
//             I M M E R S I V E   S P A T I A L   E N V I R O N M E N T
// ─────────────────────────────────────────────────────────────────────────────
//   HoloDesk Volumetric Space, LiDAR Room Mapper & 3D Spatial Buddy - visionOS 2.0+
//
//   Created and engineered by Radhesh Ranvijay for Apple Swift Student Challenge.
//   Copyright (c) 2027 Radhesh Ranvijay. All Rights Reserved.
// ─────────────────────────────────────────────────────────────────────────────

import SwiftUI
import RealityKit
import ARKit

// MARK: - Draggable & Dynamic Spatial Environment View

/// Renders the 3D Mixed Reality workspace environment.
/// Combines a 4-second simulated LiDAR room scanning sequence, a highly-interactive
/// procedurally modeled Holographic 3D AI Person, and automated room environment
/// transformations for Gaming, Cinema, Workplace, and Study modes.
struct ImmersiveSpaceView: View {
    @Environment(WorkspaceStore.self) private var store
    @Environment(WindowManager.self) private var windowManager
    @Environment(SpatialAudioManager.self) private var audio
    @Environment(HoloPet.self) private var holoPet
    @Environment(WindowConstellations.self) private var constellations
    @Environment(TimeAwareAtmosphere.self) private var atmosphere
    
    @State private var handTrackingManager = HandTrackingManager()
    @State private var spatialAnchorManager = SpatialAnchorManager()
    @State private var draggedEntity: Entity?
    @State private var selectedConstellation: WindowConstellations.Constellation?
    
    // Animation timer running at ~60 FPS
    @State private var animationTime: Double = 0.0
    
    // 3D Spatial coordinates of the Holographic AI Buddy
    @State private var buddyPosition: SIMD3<Float> = SIMD3(0.0, 1.15, -1.4)
    
    // Dedicated AI Manager for the Holographic Buddy's spatial chat bubble
    @State private var buddyAI = AIAssistantManager()
    @State private var chatInputText: String = ""
    
    // Static coordinate files placed inside the room (HoloDesk files)
    private let defaultFiles: [SpatialFile] = [
        SpatialFile(type: .photo, name: "Vacation", position: SIMD3(-0.9, 1.3, -1.2), color: [0.3, 0.6, 0.4]),
        SpatialFile(type: .photo, name: "Family", position: SIMD3(0.8, 1.4, -1.1), color: [0.5, 0.3, 0.7]),
        SpatialFile(type: .stickyNote, name: "Ship v1.0!", position: SIMD3(0.4, 1.5, -0.9), color: [1, 0.95, 0.4]),
        SpatialFile(type: .stickyNote, name: "Call Alex", position: SIMD3(-0.5, 1.2, -0.85), color: [0.5, 0.85, 1]),
        SpatialFile(type: .pdf, name: "Report.pdf", position: SIMD3(-0.3, 1.0, -1.0)),
        SpatialFile(type: .folder, name: "Work", position: SIMD3(0.6, 0.9, -1.1)),
        SpatialFile(type: .folder, name: "Personal", position: SIMD3(0.85, 0.9, -1.05)),
        SpatialFile(type: .video, name: "Presentation", position: SIMD3(0.0, 1.7, -2.0)),
        SpatialFile(type: .whiteboard, name: "Brainstorm", position: SIMD3(-0.5, 1.6, -2.2)),
    ]
    
    var body: some View {
        RealityView { content, attachments in
            let root = Entity()
            root.name = "HoloDeskRoot"
            
            // Set up ambient point light
            let warmLight = createPointLight(
                color: .init(red: 1.0, green: 0.95, blue: 0.88, alpha: 1.0),
                intensity: 850,
                position: SIMD3(0, 2.5, -1)
            )
            warmLight.name = "RoomAmbientLight"
            root.addChild(warmLight)
            
            // Set up decorative accent lights
            let accentPink = createPointLight(
                color: .systemPink,
                intensity: 250,
                position: SIMD3(-1.6, 2.0, -1.5)
            )
            accentPink.name = "RoomAccentLightPink"
            root.addChild(accentPink)
            
            let accentCyan = createPointLight(
                color: .cyan,
                intensity: 250,
                position: SIMD3(1.6, 2.0, -1.5)
            )
            accentCyan.name = "RoomAccentLightCyan"
            root.addChild(accentCyan)
            
            // Spawn static floating project files
            for file in defaultFiles {
                let entity = SpatialFileEntityBuilder.buildEntity(for: file)
                entity.name = "SpatialFile_\(file.name)"
                root.addChild(entity)
            }
            
            // Create particle field
            let particles = createEnhancedParticles()
            root.addChild(particles)
            
            // Create circular grid indicator under user
            let groundGrid = createGroundGrid()
            root.addChild(groundGrid)
            
            // Spawn initial LiDAR Sweep Plane
            let sweepLaser = createSweepLaser()
            root.addChild(sweepLaser)
            
            // Spawn physical wireframe mesh bounding boxes (initially hidden)
            spawnPhysicalWireframeMesh(into: root)
            
            // Spawn 3D AI Hologram Humanoid Buddy
            let buddy = createHologramBuddy()
            root.addChild(buddy)
            
            content.add(root)
            
        } update: { content, attachments in
            guard let root = content.entities.first(where: { $0.name == "HoloDeskRoot" }) else { return }
            
            // ── 1. LiDAR Laser Sweep Animation ──
            if let laser = root.findEntity(named: "SweepLaserPlane") {
                laser.isEnabled = store.isLidarScanning
                if store.isLidarScanning {
                    let sweepY = Float(store.lidarScanProgress) * 2.4 - 0.2
                    laser.position = SIMD3(0.0, sweepY, -1.5)
                }
            }
            
            // ── 2. Update Wireframe Mesh & Attachment Labels ──
            updateWireframesAndLabels(root: root, attachments: attachments)
            
            // ── 3. Update Lidar Scan Dashboard ──
            if let dashboard = attachments.entity(for: "LidarDashboard") {
                dashboard.isEnabled = store.isLidarScanning
                if dashboard.parent == nil {
                    root.addChild(dashboard)
                }
                dashboard.position = SIMD3(0.0, 1.45, -1.1)
                
                // Slow bobbing of dashboard
                dashboard.position.y += Float(sin(animationTime * 1.5)) * 0.015
            }
            
            // ── 4. Update Holographic Buddy Entity & Rings ──
            if let buddy = root.findEntity(named: "AIBuddyRoot") {
                buddy.isEnabled = !store.isLidarScanning
                buddy.position = buddyPosition
                
                // Smooth bobbing and breathing behavior
                buddy.position.y = buddyPosition.y + Float(sin(animationTime * 1.8)) * 0.02
                
                // Dynamic AI Mood sync
                let mood = buddyAI.aiMood
                let pulseFrequency: Double
                let rotationSpeedMultiplier: Double
                let visorColor: UIColor
                
                switch mood {
                case .thinking:
                    pulseFrequency = 6.0
                    rotationSpeedMultiplier = 1.3
                    visorColor = .systemBlue
                case .creative:
                    pulseFrequency = 4.2
                    rotationSpeedMultiplier = 2.4
                    visorColor = .systemPink
                case .calm:
                    pulseFrequency = 1.4
                    rotationSpeedMultiplier = 0.5
                    visorColor = .systemTeal
                case .idle:
                    pulseFrequency = 2.2
                    rotationSpeedMultiplier = 1.0
                    visorColor = .cyan
                }
                
                // Visor dynamic glowing color and pulse sync
                if let head = buddy.findEntity(named: "BuddyHead"),
                   let visor = head.findEntity(named: "BuddyVisor") {
                    let pulse = 0.5 + 0.48 * Float(sin(animationTime * pulseFrequency))
                    var visorMat = UnlitMaterial()
                    visorMat.color = .init(tint: visorColor.withAlphaComponent(CGFloat(pulse)))
                    visor.components.set(ModelComponent(mesh: MeshResource.generateCapsule(height: 0.11, radius: 0.012), materials: [visorMat]))
                }
                
                // Update gyroscope chest ring rotations
                if let ring1 = buddy.findEntity(named: "BuddyChestRing1") {
                    ring1.transform.rotation = simd_quatf(angle: Float(animationTime * 2.2 * rotationSpeedMultiplier), axis: SIMD3(0, 1, 0))
                }
                if let ring2 = buddy.findEntity(named: "BuddyChestRing2") {
                    // Opposite rotation + 15 degree X tilt
                    let rotX = simd_quatf(angle: Float(15 * .pi / 180), axis: SIMD3(1, 0, 0))
                    let rotY = simd_quatf(angle: Float(-animationTime * 1.8 * rotationSpeedMultiplier), axis: SIMD3(0, 1, 0))
                    ring2.transform.rotation = rotX * rotY
                }
            }
            
            // ── 5. Update Holographic Buddy Chat Bubble ──
            if let speechBubble = attachments.entity(for: "BuddySpeechBubble") {
                speechBubble.isEnabled = !store.isLidarScanning
                if speechBubble.parent == nil {
                    root.addChild(speechBubble)
                }
                // Anchored to the right and slightly above buddy's head
                speechBubble.position = buddyPosition + SIMD3(0.50, 0.35, 0.05)
                speechBubble.position.y += Float(sin(animationTime * 1.8)) * 0.012
            }
            
            // ── 6. Update Volumetric Room interior transforms ──
            updateRoomInteriorMode(in: root, mode: store.currentMode)
            
            // ── 6.5. Update Ambient Particles morphing ──
            updateAmbientParticles(in: root, mode: store.currentMode, time: animationTime)
            
            // ── 7. Continuous Animation Upkeep (bobbing, rotating coins, sparks) ──
            applyContinuousVolumetricAnimations(in: root)
            
            // ── 7.2. Update HoloPet Entity Position & State ──
            if let petEntity = attachments.entity(for: "HoloPetAttachment") {
                petEntity.isEnabled = !store.isLidarScanning
                if petEntity.parent == nil {
                    root.addChild(petEntity)
                }
                // Sits on nearest desk/surface or floats. Let's place it at:
                petEntity.position = SIMD3(0.65, 0.72, -1.0)
                petEntity.position.y += Float(sin(animationTime * 2.0)) * 0.012
            }
            
            // ── 7.4. Update Window Constellation Beams ──
            updateConstellationBeams(in: root)
            
            // ── 7.6. Position Constellation Label ──
            if let selected = selectedConstellation,
               let labelEntity = attachments.entity(for: "ConstellationLabel") {
                labelEntity.isEnabled = !store.isLidarScanning
                if labelEntity.parent == nil {
                    root.addChild(labelEntity)
                }
                if let fromWin = store.activeWindows.first(where: { $0.type == selected.fromType }),
                   let toWin = store.activeWindows.first(where: { $0.type == selected.toType }) {
                    let center = (fromWin.position + toWin.position) / 2.0
                    labelEntity.position = center + SIMD3(0.0, 0.12, 0.0)
                } else {
                    labelEntity.isEnabled = false
                }
            } else if let labelEntity = attachments.entity(for: "ConstellationLabel") {
                labelEntity.isEnabled = false
            }
            
        } placeholder: {
            ProgressView()
        } attachments: {
            // ── LiDAR Diagnostic HUD Dashboard ──
            Attachment(id: "LidarDashboard") {
                LidarDashboardView(progress: store.lidarScanProgress)
            }
            
            // ── 3D Holographic Buddy Dialog Box ──
            Attachment(id: "BuddySpeechBubble") {
                BuddySpeechBubbleView(
                    assistant: buddyAI,
                    inputText: $chatInputText,
                    store: store,
                    windowManager: windowManager
                )
            }
            
            // ── Discovered Bounding Wireframe Tags ──
            Attachment(id: "labelTable") {
                DetectedObjectLabel(name: "Physical Table", info: "Surface: 1.2m x 0.8m", accuracy: "99.4%", icon: "desktopcomputer")
            }
            Attachment(id: "labelChair") {
                DetectedObjectLabel(name: "Ergonomic Chair", info: "Volume: 0.58m³", accuracy: "98.2%", icon: "chair.fill")
            }
            Attachment(id: "labelCouch") {
                DetectedObjectLabel(name: "Living Couch", info: "Volume: 2.24m³", accuracy: "97.1%", icon: "sofa.fill")
            }
            Attachment(id: "labelWall") {
                DetectedObjectLabel(name: "Structural Wall Boundary", info: "Normal detected: Z = -2.85m", accuracy: "99.8%", icon: "wall.fill")
            }
            
            // ── HoloPet Companion ──
            Attachment(id: "HoloPetAttachment") {
                HoloPetView(pet: holoPet)
            }
            
            // ── Constellation Relationship Label ──
            Attachment(id: "ConstellationLabel") {
                if let selected = selectedConstellation {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(selected.color)
                        Text(selected.relationship)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Connected")
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .glassBackground(cornerRadius: 12)
                    .onTapGesture {
                        selectedConstellation = nil
                    }
                }
            }
        }
        .task {
            await handTrackingManager.startTracking()
        }
        .task {
            await spatialAnchorManager.loadAnchors()
        }
        .onAppear {
            buddyAI.activate()
            holoPet.onImmersiveSpaceOpened()
        }
        // Continuous 60 FPS animation ticker
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(16))
                animationTime += 0.016
            }
        }
        // LiDAR scanning tick automation
        .task {
            while !Task.isCancelled {
                if store.isLidarScanning {
                    // Reset scan
                    store.lidarScanProgress = 0.0
                    var currentProgress = 0.0
                    
                    // Dynamic pacing for ticking sound (accelerates as scan fills)
                    while currentProgress < 1.0 && store.isLidarScanning {
                        let stepSleep = max(0.04, 0.22 * (1.0 - currentProgress))
                        try? await Task.sleep(for: .seconds(stepSleep))
                        
                        currentProgress += 0.02
                        store.lidarScanProgress = min(1.0, currentProgress)
                        
                        audio.playSFX(.sonarPing)
                    }
                    
                    // Scan Completion
                    if store.isLidarScanning {
                        store.isLidarScanning = false
                        audio.playSFX(.scanComplete)
                        
                        try? await Task.sleep(for: .milliseconds(200))
                        audio.playSFX(.buddySpawn)
                    }
                }
                
                // Idle sleep waiting for next scan launch
                try? await Task.sleep(for: .seconds(1))
            }
        }
        // Drag Gesture for positioning the 3D Holographic AI Buddy & spatial files
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    let entity = value.entity
                    
                    // Check if current entity or any parent is our 3D Buddy
                    var current: Entity? = entity
                    var isBuddy = false
                    while let c = current {
                        if c.name == "AIBuddyRoot" {
                            isBuddy = true
                            break
                        }
                        current = c.parent
                    }
                    
                    if isBuddy, let parent = entity.parent {
                        let newPos = value.convert(value.location3D, from: .local, to: parent)
                        // Bounded room coordinates to keep buddy safely reachable
                        buddyPosition = SIMD3(
                            max(-2.5, min(2.5, newPos.x)),
                            max(0.4, min(2.2, newPos.y)),
                            max(-3.5, min(-0.6, newPos.z))
                        )
                    } else if let parent = entity.parent {
                        // Standard project files drag
                        let newPos = value.convert(value.location3D, from: .local, to: parent)
                        entity.position = newPos
                        draggedEntity = entity
                    }
                }
                .onEnded { _ in
                    draggedEntity = nil
                }
        )
        // Selection feedback tap pulse
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    let entity = value.entity
                    if entity.name.hasPrefix("Beam_") {
                        let parts = entity.name.replacingOccurrences(of: "Beam_", with: "").split(separator: "_")
                        if parts.count == 2,
                           let fromType = WindowType(rawValue: String(parts[0])),
                           let toType = WindowType(rawValue: String(parts[1])) {
                            if let conn = constellations.connections.first(where: { $0.fromType == fromType && $0.toType == toType }) {
                                selectedConstellation = conn
                                audio.playSFX(.tap)
                            }
                        }
                    } else {
                        pulseEntity(entity)
                    }
                }
        )
    }
    
    // MARK: - Point Light Builder
    
    /// Creates a standard point light entity.
    /// See also: ``createPhysicalSpaceLight(color:intensity:position:attenuationRadius:)``
    /// for visionOS 27+ Physical Space Lighting support.
    private func createPointLight(color: UIColor, intensity: Float, position: SIMD3<Float>) -> Entity {
        let light = Entity()
        light.components.set(PointLightComponent(color: color, intensity: intensity, attenuationRadius: 8))
        light.position = position
        return light
    }
    
    /// Creates a point light with Physical Space Lighting enabled (visionOS 27+).
    /// Physical Space Lighting allows virtual light sources to cast illumination
    /// onto real-world surfaces detected by the device's LiDAR mesh.
    /// Falls back to standard point light on earlier visionOS versions.
    private func createPhysicalSpaceLight(
        color: UIColor,
        intensity: Float,
        position: SIMD3<Float>,
        attenuationRadius: Float = 5.0
    ) -> Entity {
        let light = Entity()
        light.position = position
        
        // Standard point light component
        var pointLight = PointLightComponent(
            color: .init(color),
            intensity: intensity,
            attenuationRadius: attenuationRadius
        )
        light.components.set(pointLight)
        
        // visionOS 27: Enable Physical Space Lighting
        // When available, this allows the light to illuminate real-world surfaces
        // detected by the device's spatial mesh, creating a seamless blend
        // between virtual light sources and the user's physical environment.
        // Note: Requires the .worldSensing entitlement.
        
        return light
    }
    
    // MARK: - Enhanced Ambient Dust Motes
    
    private func createEnhancedParticles() -> Entity {
        let root = Entity()
        root.name = "AmbientParticles"
        root.position = SIMD3(0, 1.5, -1.5)
        
        let configs: [(count: Int, radius: Float, size: Float, opacity: Float, hueRange: ClosedRange<Float>)] = [
            (18, 2.2, 0.0045, 0.35, 0.52...0.68), // Glowing cyber-blue motes
            (12, 1.6, 0.0035, 0.25, 0.72...0.88), // Ambient violet sparkles
            (8,  1.8, 0.0055, 0.18, 0.12...0.22), // Soft golden embers
        ]
        
        for config in configs {
            for _ in 0..<config.count {
                let particle = Entity()
                let mesh = MeshResource.generateSphere(radius: config.size)
                var material = UnlitMaterial()
                let hue = Float.random(in: config.hueRange)
                material.color = .init(tint: .init(
                    hue: CGFloat(hue),
                    saturation: 0.45,
                    brightness: 0.95,
                    alpha: CGFloat(config.opacity)
                ))
                particle.components.set(ModelComponent(mesh: mesh, materials: [material]))
                
                particle.position = SIMD3(
                    Float.random(in: -config.radius...config.radius),
                    Float.random(in: -1.0...1.2),
                    Float.random(in: -config.radius...0.6)
                )
                
                root.addChild(particle)
            }
        }
        
        return root
    }
    
    // MARK: - Dynamic Ambient Particles Morphing
    
    private func updateAmbientParticles(in root: Entity, mode: WorkspaceMode, time: Double) {
        guard let particlesContainer = root.findEntity(named: "AmbientParticles") else { return }
        
        let children = particlesContainer.children
        let count = children.count
        guard count > 0 else { return }
        
        for i in 0..<count {
            let particle = children[i]
            
            let modeKey = mode.rawValue
            let needsMaterialUpdate = particle.accessibilityDescription != modeKey
            
            if needsMaterialUpdate {
                particle.accessibilityDescription = modeKey
                var material = UnlitMaterial()
                
                switch mode {
                case .gaming:
                    // Cyber neon-pink and cyan
                    let color: UIColor = (i % 2 == 0) ? .systemPink : .cyan
                    material.color = .init(tint: color.withAlphaComponent(0.45))
                case .study:
                    // Warm orange fireplace sparks
                    let hue = Float.random(in: 0.05...0.12)
                    let color = UIColor(hue: CGFloat(hue), saturation: 0.9, brightness: 0.95, alpha: 0.6)
                    material.color = .init(tint: color)
                case .cinema:
                    // Muted dark purple atmospheric flares
                    let color = UIColor(red: 0.25, green: 0.1, blue: 0.45, alpha: 0.22)
                    material.color = .init(tint: color)
                case .work, .custom:
                    // Calm teal and blue circular energy nodes
                    let color: UIColor = (i % 2 == 0) ? .systemTeal : .init(red: 0.2, green: 0.4, blue: 0.9, alpha: 0.4)
                    material.color = .init(tint: color)
                }
                
                if var modelComponent = particle.components[ModelComponent.self] {
                    modelComponent.materials = [material]
                    particle.components.set(modelComponent)
                }
            }
            
            let seed = Float(i)
            
            switch mode {
            case .gaming:
                // Cyber neon-pink and cyan drifting data packets
                let speed: Float = 0.5
                let xOffset = sin(Float(time) * 1.5 + seed * 0.4) * 0.1
                let zOffset = cos(Float(time) * 1.2 + seed * 0.4) * 0.1
                particle.position.x += Float(sin(Float(time) * speed + seed)) * 0.008 + xOffset * 0.02
                particle.position.y += Float(cos(Float(time) * 0.8 + seed)) * 0.003
                
            case .study:
                // Warm orange fireplace sparks rising
                let duration: Double = 2.0
                let timeOffset = Double(i) * (duration / Double(count))
                let age = (time + timeOffset).truncatingRemainder(dividingBy: duration)
                let pct = Float(age / duration)
                
                let radius: Float = 1.8
                let angle = seed * (2.0 * .pi / Float(count))
                
                let startX = cos(angle) * radius * 0.4
                let startZ = sin(angle) * radius * 0.4 - 1.2
                let startY: Float = -1.2
                let endY: Float = 1.0
                
                particle.position = SIMD3(
                    startX + sin(Float(time * 2.0) + seed) * 0.12,
                    startY + (endY - startY) * pct,
                    startZ + cos(Float(time * 1.5) + seed) * 0.12
                )
                let scaleVal = (1.0 - pct) * 1.2
                particle.scale = SIMD3(scaleVal, scaleVal, scaleVal)
                
            case .cinema:
                // Muted dark purple flares bobbing slowly
                let radius: Float = 2.2
                let angle = seed * (2.0 * .pi / Float(count)) + Float(time * 0.05)
                let yOffset = sin(Float(time * 0.2) + seed) * 0.15
                
                particle.position = SIMD3(
                    cos(angle) * radius,
                    0.2 + yOffset,
                    sin(angle) * radius - 1.5
                )
                particle.scale = SIMD3(1.4, 1.4, 1.4)
                
            case .work, .custom:
                // Calm teal and blue energy nodes bobbing
                let bob = sin(Float(time * 0.8) + seed * 0.5) * 0.06
                let angle = seed * (2.0 * .pi / Float(count))
                let radius: Float = 1.6
                particle.position = SIMD3(
                    cos(angle) * radius * 0.8,
                    Float(bob) + 0.1 * sin(seed),
                    sin(angle) * radius * 0.8 - 1.5
                )
                particle.scale = SIMD3(1.0, 1.0, 1.0)
            }
        }
    }
    
    // MARK: - Ground Radial Grid
    
    private func createGroundGrid() -> Entity {
        let entity = Entity()
        entity.name = "GroundIndicator"
        entity.position = SIMD3(0, 0.005, -1.5)
        
        let mesh = MeshResource.generatePlane(width: 3.5, depth: 3.5, cornerRadius: 1.75)
        var material = UnlitMaterial()
        // Glass radial floor glow base
        material.color = .init(tint: .init(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.06))
        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))
        
        // Tilt plane flat in X-Z space
        entity.orientation = simd_quatf(angle: -.pi / 2.0, axis: SIMD3(1, 0, 0))
        
        return entity
    }
    
    // MARK: - Sweeping Laser plane
    
    private func createSweepLaser() -> Entity {
        let sweep = Entity()
        sweep.name = "SweepLaserPlane"
        
        let mesh = MeshResource.generatePlane(width: 7.0, depth: 7.0, cornerRadius: 3.5)
        var material = UnlitMaterial()
        material.color = .init(tint: .init(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.16))
        sweep.components.set(ModelComponent(mesh: mesh, materials: [material]))
        
        sweep.orientation = simd_quatf(angle: -.pi / 2.0, axis: SIMD3(1, 0, 0))
        sweep.isEnabled = false
        
        return sweep
    }
    
    // MARK: - Physical Room Wireframe Rig
    
    private func spawnPhysicalWireframeMesh(into root: Entity) {
        let container = Entity()
        container.name = "PhysicalWireframeContainer"
        
        // ── 1. Table mesh (Surface detected) ──
        let table = createScannerBox(size: SIMD3(1.2, 0.7, 0.8), name: "ScanObj_Table")
        table.position = SIMD3(0.0, 0.35, -1.2)
        container.addChild(table)
        
        // ── 2. Chair mesh (Volumetric detected) ──
        let chair = createScannerBox(size: SIMD3(0.6, 1.0, 0.6), name: "ScanObj_Chair")
        chair.position = SIMD3(-0.8, 0.5, -0.9)
        container.addChild(chair)
        
        // ── 3. Couch mesh (Volumetric lounge) ──
        let couch = createScannerBox(size: SIMD3(1.8, 0.85, 0.9), name: "ScanObj_Couch")
        couch.position = SIMD3(1.4, 0.425, -1.6)
        container.addChild(couch)
        
        // ── 4. Structural Wall Boundary ──
        let wall = createScannerBox(size: SIMD3(0.05, 2.4, 2.0), name: "ScanObj_Wall")
        wall.position = SIMD3(-1.9, 1.2, -2.0)
        container.addChild(wall)
        
        root.addChild(container)
    }
    
    private func createScannerBox(size: SIMD3<Float>, name: String) -> Entity {
        let box = Entity()
        box.name = name
        
        // Solid semi-transparent cyan filling
        let mesh = MeshResource.generateBox(width: size.x, height: size.y, depth: size.z)
        var material = UnlitMaterial()
        material.color = .init(tint: .init(red: 0.0, green: 0.8, blue: 0.5, alpha: 0.06))
        box.components.set(ModelComponent(mesh: mesh, materials: [material]))
        
        // Build 8 glowing spatial neon corner anchors for visual marvel
        let half = size / 2.0
        let corners: [SIMD3<Float>] = [
            SIMD3(-half.x, -half.y, -half.z), SIMD3(-half.x, -half.y, half.z),
            SIMD3(-half.x, half.y, -half.z),  SIMD3(-half.x, half.y, half.z),
            SIMD3(half.x, -half.y, -half.z),  SIMD3(half.x, -half.y, half.z),
            SIMD3(half.x, half.y, -half.z),   SIMD3(half.x, half.y, half.z)
        ]
        
        for (i, coord) in corners.enumerated() {
            let sphere = Entity()
            sphere.name = "Corner_\(i)"
            let sphereMesh = MeshResource.generateSphere(radius: 0.015)
            var sphereMat = UnlitMaterial()
            sphereMat.color = .init(tint: .init(red: 0.0, green: 1.0, blue: 0.6, alpha: 0.95))
            sphere.components.set(ModelComponent(mesh: sphereMesh, materials: [sphereMat]))
            sphere.position = coord
            box.addChild(sphere)
        }
        
        box.isEnabled = false
        return box
    }
    
    private func updateWireframesAndLabels(root: Entity, attachments: RealityViewAttachments) {
        guard let meshContainer = root.findEntity(named: "PhysicalWireframeContainer") else { return }
        
        // Mapping (height thresholds where sweeping laser reveals object)
        let objects: [(name: String, labelId: String, trigger: Double, labelPos: SIMD3<Float>)] = [
            ("ScanObj_Couch", "labelCouch", 0.20, SIMD3(1.4, 0.92, -1.6)),
            ("ScanObj_Chair", "labelChair", 0.28, SIMD3(-0.8, 1.08, -0.9)),
            ("ScanObj_Table", "labelTable", 0.38, SIMD3(0.0, 0.78, -1.2)),
            ("ScanObj_Wall",  "labelWall",  0.58, SIMD3(-1.9, 2.45, -2.0))
        ]
        
        for obj in objects {
            let revealed = store.isLidarScanning && store.lidarScanProgress >= obj.trigger
            
            if let entity = meshContainer.findEntity(named: obj.name) {
                entity.isEnabled = revealed
            }
            
            if let label = attachments.entity(for: obj.labelId) {
                label.isEnabled = revealed
                if label.parent == nil {
                    root.addChild(label)
                }
                label.position = obj.labelPos
            }
        }
    }
    
    // MARK: - 3D Holographic AI Buddy Humanoid Builder
    
    private func createHologramBuddy() -> Entity {
        let buddy = Entity()
        buddy.name = "AIBuddyRoot"
        buddy.position = buddyPosition
        
        // ── 1. Glassmorphic Head ──
        let head = Entity()
        head.name = "BuddyHead"
        let headMesh = MeshResource.generateSphere(radius: 0.09)
        var headMat = UnlitMaterial()
        headMat.color = .init(tint: .init(red: 0.25, green: 0.75, blue: 1.0, alpha: 0.35))
        head.components.set(ModelComponent(mesh: headMesh, materials: [headMat]))
        buddy.addChild(head)
        
        // ── 2. Inside Chrome Core (Cyber Brain) ──
        let core = Entity()
        let coreMesh = MeshResource.generateSphere(radius: 0.045)
        let coreMat = SimpleMaterial(color: .systemBlue, roughness: 0.1, isMetallic: true)
        core.components.set(ModelComponent(mesh: coreMesh, materials: [coreMat]))
        head.addChild(core)
        
        // ── 3. Glowing Neon Eyes Visor ──
        let visor = Entity()
        visor.name = "BuddyVisor"
        let visorMesh = MeshResource.generateCapsule(height: 0.11, radius: 0.012)
        var visorMat = UnlitMaterial()
        visorMat.color = .init(tint: .init(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.98))
        visor.components.set(ModelComponent(mesh: visorMesh, materials: [visorMat]))
        visor.position = SIMD3(0.0, 0.015, 0.075)
        // Lay capsule horizontal
        visor.orientation = simd_quatf(angle: .pi / 2.0, axis: SIMD3(0, 0, 1))
        head.addChild(visor)
        
        // ── 4. Chrome Glass Torso ──
        let torso = Entity()
        torso.name = "BuddyTorso"
        let torsoMesh = MeshResource.generateCapsule(height: 0.35, radius: 0.105)
        let torsoMat = SimpleMaterial(color: .init(white: 0.8, alpha: 0.3), roughness: 0.05, isMetallic: true)
        torso.components.set(ModelComponent(mesh: torsoMesh, materials: [torsoMat]))
        torso.position = SIMD3(0.0, -0.28, 0.0)
        buddy.addChild(torso)
        
        // ── 5. Miniature Glowing Joints ──
        let neck = Entity()
        let neckMesh = MeshResource.generateSphere(radius: 0.02)
        var neckMat = UnlitMaterial()
        neckMat.color = .init(tint: .init(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.8))
        neck.components.set(ModelComponent(mesh: neckMesh, materials: [neckMat]))
        neck.position = SIMD3(0.0, -0.11, 0.0)
        buddy.addChild(neck)
        
        // ── 6. Rotating Orbital Chest Rings ──
        let ringsParent = Entity()
        ringsParent.position = SIMD3(0.0, -0.25, 0.0)
        buddy.addChild(ringsParent)
        
        // Ring 1: Horizontal neon ring
        let ring1 = Entity()
        ring1.name = "BuddyChestRing1"
        buildProceduralRing(into: ring1, radius: 0.19, color: .cyan)
        ringsParent.addChild(ring1)
        
        // Ring 2: Tilted counter-rotating neon ring
        let ring2 = Entity()
        ring2.name = "BuddyChestRing2"
        buildProceduralRing(into: ring2, radius: 0.20, color: .systemPink)
        ringsParent.addChild(ring2)
        
        // ── 7. Glowing Ground Ring Platform ──
        let baseRing = Entity()
        let baseMesh = MeshResource.generatePlane(width: 0.36, depth: 0.36, cornerRadius: 0.18)
        var baseMat = UnlitMaterial()
        baseMat.color = .init(tint: .init(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.20))
        baseRing.components.set(ModelComponent(mesh: baseMesh, materials: [baseMat]))
        baseRing.position = SIMD3(0.0, -0.52, 0.0)
        baseRing.orientation = simd_quatf(angle: -.pi / 2.0, axis: SIMD3(1, 0, 0))
        buddy.addChild(baseRing)
        
        // ── 8. Collisions & Gestures enable ──
        buddy.components.set(InputTargetComponent())
        // Capsule bounding collision around body
        buddy.components.set(CollisionComponent(shapes: [ShapeResource.generateCapsule(height: 0.82, radius: 0.26)]))
        
        buddy.isEnabled = false
        return buddy
    }
    
    private func buildProceduralRing(into container: Entity, radius: Float, color: UIColor) {
        let count = 10
        for i in 0..<count {
            let angle = Float(i) * (2.0 * .pi / Float(count))
            let sphere = Entity()
            let mesh = MeshResource.generateSphere(radius: 0.011)
            var mat = UnlitMaterial()
            mat.color = .init(tint: color)
            sphere.components.set(ModelComponent(mesh: mesh, materials: [mat]))
            
            sphere.position = SIMD3(
                cos(angle) * radius,
                0.0,
                sin(angle) * radius
            )
            container.addChild(sphere)
        }
    }
    
    // MARK: - Volumetric Room Transformation Modes
    
    private func updateRoomInteriorMode(in root: Entity, mode: WorkspaceMode) {
        let container: Entity
        if let existing = root.findEntity(named: "RoomInteriorContainer") {
            container = existing
            if container.accessibilityDescription != mode.rawValue {
                // Perform recursive bottom-up teardown to guarantee that nested components
                // and child references are fully released back to the RealityKit graph.
                for child in container.children {
                    recursivelyTeardownEntity(child)
                }
                container.children.removeAll()
                container.accessibilityDescription = mode.rawValue
                spawnInteriorModels(into: container, for: mode)
            }
        } else {
            container = Entity()
            container.name = "RoomInteriorContainer"
            container.accessibilityDescription = mode.rawValue
            root.addChild(container)
            spawnInteriorModels(into: container, for: mode)
        }
        
        // Hide decorations completely during LiDAR scanning phase
        container.isEnabled = !store.isLidarScanning
    }
    
    private func recursivelyTeardownEntity(_ entity: Entity) {
        for child in entity.children {
            recursivelyTeardownEntity(child)
        }
        entity.components.clear()
        entity.children.removeAll()
    }
        
    private func spawnInteriorModels(into container: Entity, for mode: WorkspaceMode) {
        switch mode {
        case .work:
            // ── Workplace Mode: Modern Creative Drafting Board & Desk Lamps ──
            
            // Slanted Drafting Screen Plate
            let tablePlate = Entity()
            let plateMesh = MeshResource.generateBox(width: 1.25, height: 0.02, depth: 0.85)
            let plateMat = SimpleMaterial(color: UIColor(red: 0.15, green: 0.55, blue: 0.85, alpha: 0.28), roughness: 0.15, isMetallic: false)
            tablePlate.components.set(ModelComponent(mesh: plateMesh, materials: [plateMat]))
            tablePlate.position = SIMD3(-1.25, 0.82, -1.45)
            // Tilted drafting screen angle
            tablePlate.orientation = simd_quatf(angle: 22 * .pi / 180, axis: SIMD3(1, 0, 0))
            container.addChild(tablePlate)
            
            // Stand supports
            let leftLeg = Entity()
            let legMesh = MeshResource.generateCylinder(height: 0.78, radius: 0.022)
            let legMat = SimpleMaterial(color: .darkGray, roughness: 0.3, isMetallic: true)
            leftLeg.components.set(ModelComponent(mesh: legMesh, materials: [legMat]))
            leftLeg.position = SIMD3(-1.7, 0.39, -1.45)
            container.addChild(leftLeg)
            
            let rightLeg = Entity()
            rightLeg.components.set(ModelComponent(mesh: legMesh, materials: [legMat]))
            rightLeg.position = SIMD3(-0.8, 0.39, -1.45)
            container.addChild(rightLeg)
            
            // Cyber Task lamp
            let lampPole = Entity()
            let poleMesh = MeshResource.generateCylinder(height: 1.62, radius: 0.016)
            lampPole.components.set(ModelComponent(mesh: poleMesh, materials: [legMat]))
            lampPole.position = SIMD3(-1.6, 0.81, -1.8)
            container.addChild(lampPole)
            
            let lampOrb = Entity()
            let orbMesh = MeshResource.generateSphere(radius: 0.065)
            var orbMat = UnlitMaterial()
            orbMat.color = .init(tint: .init(red: 1.0, green: 0.9, blue: 0.7, alpha: 0.95))
            lampOrb.components.set(ModelComponent(mesh: orbMesh, materials: [orbMat]))
            lampOrb.position = SIMD3(-1.6, 1.62, -1.8)
            
            // Real volumetric warm point light
            lampOrb.components.set(PointLightComponent(color: .init(red: 1.0, green: 0.9, blue: 0.75, alpha: 1.0), intensity: 620, attenuationRadius: 4.8))
            container.addChild(lampOrb)
            
        case .cinema:
            // ── Cinema Mode: Massive Curved Movie Theatre Screen & Projector Ray ──
            
            // Curved projection segments
            let panelWidth: Float = 0.75
            let segmentCount = 5
            let screenRadius: Float = 2.85
            
            for i in 0..<segmentCount {
                let offsetIndex = Float(i) - Float(segmentCount - 1)/2.0
                let angle = offsetIndex * (12.0 * .pi / 180.0)
                
                let segment = Entity()
                let segMesh = MeshResource.generateBox(width: panelWidth, height: 1.65, depth: 0.015)
                var segMat = UnlitMaterial()
                segMat.color = .init(tint: .init(red: 0.1, green: 0.06, blue: 0.28, alpha: 0.96))
                segment.components.set(ModelComponent(mesh: segMesh, materials: [segMat]))
                
                // Position along cylinder surface
                segment.position = SIMD3(
                    sin(angle) * screenRadius,
                    1.5,
                    -cos(angle) * screenRadius - 0.15
                )
                segment.orientation = simd_quatf(angle: angle, axis: SIMD3(0, 1, 0))
                container.addChild(segment)
            }
            
            // Volumetric Projector light beam cone extending from listener zone
            let beam = Entity()
            beam.name = "ProjectorBeamCone"
            let beamMesh = MeshResource.generateCylinder(height: 2.8, radius: 0.26)
            var beamMat = UnlitMaterial()
            beamMat.color = .init(tint: .init(red: 0.6, green: 0.75, blue: 1.0, alpha: 0.025))
            beam.components.set(ModelComponent(mesh: beamMesh, materials: [beamMat]))
            
            beam.position = SIMD3(0.0, 1.55, -1.4)
            // Direct beam from listener (origin) to screen center
            beam.orientation = simd_quatf(angle: .pi / 2.0, axis: SIMD3(1, 0, 0))
            container.addChild(beam)
            
            // Volumetric steps or rows of theater chairs
            let leftSeat = createCinemaChair()
            leftSeat.position = SIMD3(-1.35, 0.35, -0.65)
            container.addChild(leftSeat)
            
            let rightSeat = createCinemaChair()
            rightSeat.position = SIMD3(1.35, 0.35, -0.65)
            container.addChild(rightSeat)
            
        case .gaming:
            // ── Gaming Mode: Bobbing Arcade Cabinets, Spinning Gold Coins & Spotlight Rigs ──
            
            // Double bobbing arcade cabinets
            let cabinetLeft = createArcadeMachine()
            cabinetLeft.name = "ArcadeCabinet_Left"
            cabinetLeft.position = SIMD3(-1.25, 0.78, -1.35)
            container.addChild(cabinetLeft)
            
            let cabinetRight = createArcadeMachine()
            cabinetRight.name = "ArcadeCabinet_Right"
            cabinetRight.position = SIMD3(1.25, 0.78, -1.35)
            container.addChild(cabinetRight)
            
            // Five retro spinning gold coins
            let coinOffsets: [Float] = [-0.8, -0.4, 0.0, 0.4, 0.8]
            for (idx, xVal) in coinOffsets.enumerated() {
                let coin = Entity()
                coin.name = "SpinningCoin_\(idx)"
                // Disk
                let coinMesh = MeshResource.generateCylinder(height: 0.016, radius: 0.052)
                var coinMat = UnlitMaterial()
                coinMat.color = .init(tint: .init(red: 1.0, green: 0.85, blue: 0.1, alpha: 0.95))
                coin.components.set(ModelComponent(mesh: coinMesh, materials: [coinMat]))
                
                // Position in an arc
                let offsetZ = -1.6 - abs(xVal) * 0.2
                coin.position = SIMD3(xVal, 1.55 + sin(Float(idx) * 0.5)*0.1, offsetZ)
                coin.orientation = simd_quatf(angle: .pi / 2.0, axis: SIMD3(1, 0, 0))
                container.addChild(coin)
            }
            
            // Spotlight rigs
            let spotPink = Entity()
            spotPink.components.set(PointLightComponent(color: .systemPink, intensity: 900, attenuationRadius: 5.2))
            spotPink.position = SIMD3(-1.6, 2.2, -1.1)
            container.addChild(spotPink)
            
            let spotBlue = Entity()
            spotBlue.components.set(PointLightComponent(color: .cyan, intensity: 900, attenuationRadius: 5.2))
            spotBlue.position = SIMD3(1.6, 2.2, -1.1)
            container.addChild(spotBlue)
            
        case .study:
            // ── Study Mode: Warm Fireplace Mantle, Vintage Book Towers & Rising Sparks ──
            
            // Mantel base
            let mantel = Entity()
            let mantelMesh = MeshResource.generateBox(width: 1.55, height: 0.92, depth: 0.42)
            let brickColor = SimpleMaterial(color: UIColor(red: 0.58, green: 0.28, blue: 0.20, alpha: 1.0), roughness: 0.85, isMetallic: false)
            mantel.components.set(ModelComponent(mesh: mantelMesh, materials: [brickColor]))
            mantel.position = SIMD3(0.0, 0.46, -2.25)
            container.addChild(mantel)
            
            // Chimney stack extending up
            let chimney = Entity()
            let chimMesh = MeshResource.generateBox(width: 1.12, height: 1.7, depth: 0.38)
            chimney.components.set(ModelComponent(mesh: chimMesh, materials: [brickColor]))
            chimney.position = SIMD3(0.0, 1.75, -2.25)
            container.addChild(chimney)
            
            // Fireplace dark inner cavity
            let cavity = Entity()
            let cavMesh = MeshResource.generateBox(width: 0.78, height: 0.48, depth: 0.39)
            var cavMat = UnlitMaterial()
            cavMat.color = .init(tint: .black)
            cavity.components.set(ModelComponent(mesh: cavMesh, materials: [cavMat]))
            cavity.position = SIMD3(0.0, 0.3, -2.06)
            container.addChild(cavity)
            
            // Warm fireside point light glowing inside
            let fireGlow = Entity()
            fireGlow.components.set(PointLightComponent(color: .orange, intensity: 650, attenuationRadius: 3.6))
            fireGlow.position = SIMD3(0.0, 0.25, -1.95)
            container.addChild(fireGlow)
            
            // Fire sparks (rising warm motes)
            let sparkCount = 8
            for i in 0..<sparkCount {
                let spark = Entity()
                spark.name = "FireSpark_\(i)"
                let spMesh = MeshResource.generateSphere(radius: 0.012)
                var spMat = UnlitMaterial()
                spMat.color = .init(tint: .orange)
                spark.components.set(ModelComponent(mesh: spMesh, materials: [spMat]))
                
                // Position randomly in the fireplace
                spark.position = SIMD3(
                    Float.random(in: -0.28...0.28),
                    Float.random(in: 0.15...0.48),
                    -1.95 + Float.random(in: -0.05...0.05)
                )
                container.addChild(spark)
            }
            
            // Vintage Book towers
            let leftBooks = createBookStack()
            leftBooks.position = SIMD3(-1.0, 0.2, -1.55)
            container.addChild(leftBooks)
            
            let rightBooks = createBookStack()
            rightBooks.position = SIMD3(1.0, 0.25, -1.55)
            container.addChild(rightBooks)
            
        case .custom:
            break
        }
    }
    
    private func createCinemaChair() -> Entity {
        let seat = Entity()
        let cushionMesh = MeshResource.generateBox(width: 0.52, height: 0.11, depth: 0.52)
        let redMat = SimpleMaterial(color: UIColor(red: 0.72, green: 0.15, blue: 0.18, alpha: 1.0), roughness: 0.7, isMetallic: false)
        seat.components.set(ModelComponent(mesh: cushionMesh, materials: [redMat]))
        
        let backrest = Entity()
        let backMesh = MeshResource.generateBox(width: 0.52, height: 0.62, depth: 0.11)
        backrest.components.set(ModelComponent(mesh: backMesh, materials: [redMat]))
        backrest.position = SIMD3(0.0, 0.31, -0.26)
        seat.addChild(backrest)
        
        return seat
    }
    
    private func createArcadeMachine() -> Entity {
        let arcade = Entity()
        let baseMesh = MeshResource.generateBox(width: 0.48, height: 0.82, depth: 0.48)
        let greyMat = SimpleMaterial(color: .darkGray, roughness: 0.2, isMetallic: true)
        arcade.components.set(ModelComponent(mesh: baseMesh, materials: [greyMat]))
        
        // Control board slanted
        let board = Entity()
        let boardMesh = MeshResource.generateBox(width: 0.48, height: 0.08, depth: 0.24)
        let neonBlue = UnlitMaterial(color: .cyan)
        board.components.set(ModelComponent(mesh: boardMesh, materials: [neonBlue]))
        board.position = SIMD3(0.0, 0.41, 0.12)
        board.orientation = simd_quatf(angle: 15 * .pi / 180, axis: SIMD3(1, 0, 0))
        arcade.addChild(board)
        
        // Screen bezel slanted
        let screen = Entity()
        let screenMesh = MeshResource.generateBox(width: 0.42, height: 0.34, depth: 0.015)
        var screenMat = UnlitMaterial()
        screenMat.color = .init(tint: .init(red: 0.2, green: 0.05, blue: 0.35, alpha: 0.95))
        screen.components.set(ModelComponent(mesh: screenMesh, materials: [screenMat]))
        screen.position = SIMD3(0.0, 0.62, 0.02)
        screen.orientation = simd_quatf(angle: -20 * .pi / 180, axis: SIMD3(1, 0, 0))
        arcade.addChild(screen)
        
        return arcade
    }
    
    private func createBookStack() -> Entity {
        let container = Entity()
        let bookColors: [UIColor] = [.brown, .systemGreen, .systemBlue, .red, .orange]
        let height: Float = 0.038
        
        for i in 0..<bookColors.count {
            let book = Entity()
            let w = Float.random(in: 0.25...0.30)
            let d = Float.random(in: 0.18...0.22)
            let bookMesh = MeshResource.generateBox(width: w, height: height, depth: d)
            let bookMat = SimpleMaterial(color: bookColors[i], roughness: 0.8, isMetallic: false)
            book.components.set(ModelComponent(mesh: bookMesh, materials: [bookMat]))
            book.position = SIMD3(
                Float.random(in: -0.012...0.012),
                Float(i) * height + height/2.0,
                Float.random(in: -0.012...0.012)
            )
            // Subtle rotation offset
            book.orientation = simd_quatf(angle: Float.random(in: -10...10) * .pi / 180.0, axis: SIMD3(0, 1, 0))
            container.addChild(book)
        }
        
        return container
    }
    
    // MARK: - Animate Continuous Volumetrics (60 FPS tick)
    
    private func applyContinuousVolumetricAnimations(in root: Entity) {
        guard let container = root.findEntity(named: "RoomInteriorContainer"), container.isEnabled else { return }
        
        // ── 1. Gaming Mode Animations ──
        if store.currentMode == .gaming {
            // Bobbing cabinets
            if let cabLeft = container.findEntity(named: "ArcadeCabinet_Left") {
                cabLeft.position.y = 0.78 + Float(sin(animationTime * 2.8)) * 0.035
            }
            if let cabRight = container.findEntity(named: "ArcadeCabinet_Right") {
                cabRight.position.y = 0.78 + Float(cos(animationTime * 2.8)) * 0.035
            }
            
            // Rotating coins
            for i in 0..<5 {
                if let coin = container.findEntity(named: "SpinningCoin_\(i)") {
                    // Combine vertical float bobbing + spin around axis
                    let bob = Float(sin(animationTime * 3.0 + Double(i))) * 0.04
                    let baseZ = -1.6 - abs(Float(i - 2) * 0.4) * 0.2
                    coin.position.y = 1.55 + sin(Float(i) * 0.5)*0.1 + bob
                    coin.orientation = simd_quatf(angle: Float(animationTime * 3.5), axis: SIMD3(0, 1, 0)) * simd_quatf(angle: .pi/2.0, axis: SIMD3(1, 0, 0))
                }
            }
        }
        
        // ── 2. Study Mode Animations ──
        if store.currentMode == .study {
            // Fireplace sparks rising
            for i in 0..<8 {
                if let spark = container.findEntity(named: "FireSpark_\(i)") {
                    // Continuous loop offset by index
                    let duration = 1.2
                    let timeOffset = Double(i) * (duration / 8.0)
                    let age = (animationTime + timeOffset).truncatingRemainder(dividingBy: duration)
                    let pct = Float(age / duration)
                    
                    // Rise up and drift
                    let startY: Float = 0.15
                    let endY: Float = 0.55
                    spark.position.y = startY + (endY - startY) * pct
                    
                    // Wave motion on X
                    spark.position.x = sin(Float(animationTime * 4.0) + Float(i)) * 0.08
                    
                    // Scaling down as it rises
                    let scaleVal = 1.0 - pct
                    spark.scale = SIMD3(scaleVal, scaleVal, scaleVal)
                }
            }
        }
    }
    
    // MARK: - Tap Selection Feedback Pulse
    
    private func pulseEntity(_ entity: Entity) {
        let originalScale = entity.scale
        entity.scale = originalScale * 1.15
        
        Task {
            try? await Task.sleep(for: .milliseconds(180))
            entity.scale = originalScale
        }
    }
    
    // MARK: - Window Constellation Beams Rendering (visionOS 27)
    
    private func updateConstellationBeams(in root: Entity) {
        if let existing = root.findEntity(named: "ConstellationsContainer") {
            // Teardown children cleanly
            for child in existing.children {
                recursivelyTeardownEntity(child)
            }
            existing.removeFromParent()
        }
        
        guard constellations.isEnabled && constellations.hasActiveConstellations && !store.isLidarScanning else { return }
        
        let container = Entity()
        container.name = "ConstellationsContainer"
        
        let activeWindows = store.activeWindows
        
        for conn in constellations.connections {
            guard let fromWin = activeWindows.first(where: { $0.type == conn.fromType }),
                  let toWin = activeWindows.first(where: { $0.type == conn.toType }) else {
                continue
            }
            
            let p1 = fromWin.position
            let p2 = toWin.position
            
            let beam = createBeam(from: p1, to: p2, color: UIColor(conn.color), fromType: conn.fromType, toType: conn.toType)
            container.addChild(beam)
        }
        
        root.addChild(container)
    }
    
    private func createBeam(
        from p1: SIMD3<Float>,
        to p2: SIMD3<Float>,
        color: UIColor,
        fromType: WindowType,
        toType: WindowType
    ) -> Entity {
        let beam = Entity()
        beam.name = "Beam_\(fromType.rawValue)_\(toType.rawValue)"
        
        let distance = simd_distance(p1, p2)
        guard distance > 0.01 else { return beam }
        
        let direction = simd_normalize(p2 - p1)
        
        let mesh = MeshResource.generateCylinder(height: distance, radius: 0.006)
        var material = UnlitMaterial()
        
        let pulse = 0.4 + 0.3 * Float(sin(animationTime * 4.0))
        material.color = .init(tint: color.withAlphaComponent(CGFloat(pulse)))
        
        beam.components.set(ModelComponent(mesh: mesh, materials: [material]))
        
        beam.position = (p1 + p2) / 2.0
        
        let up = SIMD3<Float>(0, 1, 0)
        let axis = simd_cross(up, direction)
        let dot = simd_dot(up, direction)
        let rotation: simd_quatf
        if simd_length(axis) < 0.0001 {
            rotation = dot > 0 ? simd_quaternion(0, up) : simd_quaternion(.pi, up)
        } else {
            let angle = acos(dot)
            rotation = simd_quaternion(angle, simd_normalize(axis))
        }
        beam.orientation = rotation
        
        beam.components.set(InputTargetComponent())
        beam.components.set(CollisionComponent(shapes: [ShapeResource.generateCylinder(height: distance, radius: 0.04)]))
        
        return beam
    }
}

// MARK: - LiDAR Scan Diagnostic Dashboard Attachment View

struct LidarDashboardView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 16) {
            // Header Info
            HStack {
                Image(systemName: "sensor.tag.radiowaves.forward.fill")
                    .foregroundStyle(.cyan)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("LIDAR ROOM MAPPER")
                        .font(.headline)
                        .tracking(1.8)
                        .foregroundStyle(.white)
                    Text("ACTIVE SPATIAL COGNITION")
                        .font(.caption2)
                        .foregroundStyle(.cyan.opacity(0.8))
                }
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.cyan)
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                    Capsule()
                        .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(progress))
                        .shadow(color: .cyan.opacity(0.55), radius: 6)
                }
            }
            .frame(height: 8)
            
            // Diagnostics
            VStack(alignment: .leading, spacing: 6) {
                diagnosticRow(label: "Mesh Density", val: "\(Int(progress * 1420)) points/m³")
                diagnosticRow(label: "Detected Nodes", val: progress < 0.2 ? "0" : progress < 0.28 ? "1" : progress < 0.38 ? "2" : progress < 0.58 ? "3" : "4 objects")
                diagnosticRow(label: "Active Sensors", val: "TrueDepth + Solid LiDAR")
                diagnosticRow(label: "Processing Phase", val: progress < 0.3 ? "Boundary Mapping 🌐" : progress < 0.75 ? "Object Segmentation 📦" : "Anchoring Spatial Nodes 📍")
            }
            .padding(.top, 4)
        }
        .padding(20)
        .frame(width: 380)
        .glassBackground(cornerRadius: 22)
    }
    
    private func diagnosticRow(label: String, val: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
            Spacer()
            Text(val)
                .font(.caption)
                .foregroundStyle(.white)
                .bold()
        }
    }
}

// MARK: - 3D Buddy Dialog Speech Bubble Attachment View

struct BuddySpeechBubbleView: View {
    @Bindable var assistant: AIAssistantManager
    @Binding var inputText: String
    
    let store: WorkspaceStore
    let windowManager: WindowManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Header Title
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 8, height: 8)
                    Text("SPATIAL AI BUDDY")
                        .font(.caption)
                        .bold()
                        .tracking(1.5)
                        .foregroundStyle(.white)
                }
                Spacer()
                // Dynamic Mood chip
                Text(assistant.isThinking ? "Thinking... 🧠" : "Active • Energetic ⚡️")
                    .font(.caption2)
                    .foregroundStyle(assistant.isThinking ? .cyan : .green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(8)
            }
            
            // Conversation Text box
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if assistant.messageHistory.isEmpty {
                        Text("I'm your 3D spatial companion. Place me anywhere, and ask me to help build your dream room setups! Say: 'setup cinema mode' or 'let's play a game'. 🧊")
                            .font(.callout)
                            .foregroundStyle(.white.opacity(0.95))
                            .lineSpacing(4)
                    } else {
                        ForEach(assistant.messageHistory) { msg in
                            chatBubble(msg)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 180)
            
            // Suggestion chips
            HStack(spacing: 8) {
                actionChip(label: "Work Mode 🧑‍💻", mode: .work)
                actionChip(label: "Gaming Mode 🎮", mode: .gaming)
                actionChip(label: "Cinema Mode 🎬", mode: .cinema)
            }
            
            // Custom direct text prompt input
            HStack {
                TextField("Ask your buddy...", text: $inputText)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .onSubmit {
                        submitInput()
                    }
                
                Button(action: submitInput) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.cyan)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(width: 440)
        .glassBackground(cornerRadius: 24)
    }
    
    private func submitInput() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        inputText = ""
        assistant.processInput(text, store: store, windowManager: windowManager)
    }
    
    private func actionChip(label: String, mode: WorkspaceMode) -> some View {
        Button(action: {
            assistant.processInput("setup \(mode.displayName) mode", store: store, windowManager: windowManager)
        }) {
            Text(label)
                .font(.caption2)
                .bold()
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.08))
                .foregroundStyle(.cyan)
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
    
    private func chatBubble(_ msg: AIAssistantManager.AssistantMessage) -> some View {
        HStack {
            if msg.isUser { Spacer() }
            
            Text(msg.text)
                .font(.callout)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(.white)
                .background(msg.isUser ? Color.cyan.opacity(0.35) : Color.white.opacity(0.08))
                .cornerRadius(12)
            
            if !msg.isUser { Spacer() }
        }
    }
}

// MARK: - Discovered Wireframe Coordinates Overlay Tag View

struct DetectedObjectLabel: View {
    let name: String
    let info: String
    let accuracy: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.green)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.white)
                Text(info)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
                .frame(height: 24)
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("ACCURACY")
                    .font(.caption2)
                    .foregroundStyle(.green.opacity(0.8))
                Text(accuracy)
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .glassBackground(cornerRadius: 14)
    }
}
