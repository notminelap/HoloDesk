// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import RealityKit
import ARKit

// MARK: - Enhanced Immersive Space View

struct ImmersiveSpaceView: View {
    @Environment(WorkspaceStore.self) private var store
    @Environment(WindowManager.self) private var windowManager
    
    @State private var handTrackingManager = HandTrackingManager()
    @State private var spatialAnchorManager = SpatialAnchorManager()
    @State private var draggedEntity: Entity?
    
    // Default spatial files to populate the room
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
        RealityView { content in
            let root = Entity()
            root.name = "HoloDeskRoot"
            
            // Ambient lighting
            let warmLight = createPointLight(
                color: .init(red: 1, green: 0.95, blue: 0.85, alpha: 1),
                intensity: 800,
                position: SIMD3(0, 2.5, -1)
            )
            root.addChild(warmLight)
            
            // Accent lights for atmosphere
            let accentLight1 = createPointLight(
                color: .init(red: 0.4, green: 0.6, blue: 1, alpha: 1),
                intensity: 300,
                position: SIMD3(-1.5, 2, -1.5)
            )
            root.addChild(accentLight1)
            
            let accentLight2 = createPointLight(
                color: .init(red: 0.8, green: 0.4, blue: 1, alpha: 1),
                intensity: 200,
                position: SIMD3(1.5, 2, -1.5)
            )
            root.addChild(accentLight2)
            
            // Spawn all spatial file objects
            for file in defaultFiles {
                let entity = SpatialFileEntityBuilder.buildEntity(for: file)
                // Add subtle floating animation
                addFloatingAnimation(to: entity, seed: file.id.hashValue)
                root.addChild(entity)
            }
            
            // Ambient particle system
            let particles = createEnhancedParticles()
            root.addChild(particles)
            
            // Ground plane indicator (subtle grid)
            let groundIndicator = createGroundIndicator()
            root.addChild(groundIndicator)
            
            content.add(root)
            
        } update: { content in
            updateEnvironmentForMode(content: content)
        }
        .task {
            await handTrackingManager.startTracking()
        }
        .task {
            await spatialAnchorManager.loadAnchors()
        }
        // Drag gesture for spatial objects
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    guard let parent = value.entity.parent else { return }
                    let newPos = value.convert(value.location3D, from: .local, to: parent)
                    value.entity.position = newPos
                    draggedEntity = value.entity
                }
                .onEnded { _ in
                    draggedEntity = nil
                }
        )
        // Tap gesture for selection feedback
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    pulseEntity(value.entity)
                }
        )
    }
    
    // MARK: - Point Light
    
    private func createPointLight(color: UIColor, intensity: Float, position: SIMD3<Float>) -> Entity {
        let light = Entity()
        light.components.set(PointLightComponent(color: color, intensity: intensity, attenuationRadius: 8))
        light.position = position
        return light
    }
    
    // MARK: - Enhanced Particles
    
    private func createEnhancedParticles() -> Entity {
        let root = Entity()
        root.name = "AmbientParticles"
        root.position = SIMD3(0, 1.5, -1.5)
        
        let particleConfigs: [(count: Int, radius: Float, size: Float, opacity: Float, hueRange: ClosedRange<Float>)] = [
            (15, 2.0, 0.004, 0.3, 0.5...0.7),   // Blue-ish dust
            (10, 1.5, 0.003, 0.2, 0.75...0.85),  // Purple sparkles
            (8, 1.8, 0.005, 0.15, 0.15...0.2),    // Warm motes
        ]
        
        for config in particleConfigs {
            for i in 0..<config.count {
                let particle = Entity()
                let mesh = MeshResource.generateSphere(radius: config.size)
                var material = UnlitMaterial()
                let hue = Float.random(in: config.hueRange)
                material.color = .init(tint: .init(
                    hue: CGFloat(hue),
                    saturation: 0.4,
                    brightness: 0.9,
                    alpha: CGFloat(config.opacity)
                ))
                particle.components.set(ModelComponent(mesh: mesh, materials: [material]))
                
                particle.position = SIMD3(
                    Float.random(in: -config.radius...config.radius),
                    Float.random(in: -0.8...1.2),
                    Float.random(in: -config.radius...0.5)
                )
                
                root.addChild(particle)
            }
        }
        
        return root
    }
    
    // MARK: - Ground Indicator
    
    private func createGroundIndicator() -> Entity {
        let entity = Entity()
        entity.name = "GroundIndicator"
        entity.position = SIMD3(0, 0.01, -1.5)
        
        // Subtle circular ground glow
        let mesh = MeshResource.generatePlane(width: 3, depth: 3, cornerRadius: 1.5)
        var material = UnlitMaterial()
        material.color = .init(tint: .init(white: 0.3, alpha: 0.05))
        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))
        entity.orientation = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0))
        
        return entity
    }
    
    // MARK: - Floating Animation
    
    private func addFloatingAnimation(to entity: Entity, seed: Int) {
        // Gentle idle bob using transform animation
        let offset: Float = Float(seed % 100) / 100.0
        let amplitude: Float = 0.008
        
        // In a real implementation, this would use RealityKit's animation system
        // For now, the entity is placed at a static position
        // The animation can be driven by a Timer or RealityKit FromToByAnimation
        entity.position.y += sin(offset * .pi * 2) * amplitude
    }
    
    // MARK: - Entity Pulse Effect
    
    private func pulseEntity(_ entity: Entity) {
        // Scale up briefly then back — selection feedback
        let originalScale = entity.scale
        entity.scale = originalScale * 1.15
        
        Task {
            try? await Task.sleep(for: .milliseconds(200))
            entity.scale = originalScale
        }
    }
    
    // MARK: - Environment Update
    
    private func updateEnvironmentForMode(content: RealityViewContent) {
        guard let root = content.entities.first(where: { _ in true })?
            .findEntity(named: "HoloDeskRoot") else { return }
        
        let settings: EnvironmentSettings
        switch store.currentMode {
        case .cinema:  settings = .cinemaDefault
        case .gaming:  settings = .gamingDefault
        case .study:   settings = .studyDefault
        default:       settings = .workDefault
        }
        
        // Update all lights
        for child in root.children {
            if var light = child.components[PointLightComponent.self] {
                light.intensity *= settings.ambientIntensity
                child.components.set(light)
            }
        }
        
        // Update particle visibility
        if let particles = root.findEntity(named: "AmbientParticles") {
            particles.isEnabled = settings.particleDensity > 0.1
        }
    }
}
