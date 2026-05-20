// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import RealityKit

// MARK: - Room Environment

/// Controls the immersive room environment — lighting, atmosphere, mood.
/// Adapts to workspace mode (Cinema = dim, Work = bright, etc.)
struct RoomEnvironment {
    
    // MARK: - Lighting Presets
    
    struct LightingPreset {
        var ambientIntensity: Float
        var ambientColor: SIMD3<Float>
        var directionalIntensity: Float
        var directionalColor: SIMD3<Float>
        var directionalDirection: SIMD3<Float>
        var accentLights: [(position: SIMD3<Float>, color: SIMD3<Float>, intensity: Float)]
    }
    
    static func preset(for mode: WorkspaceMode) -> LightingPreset {
        switch mode {
        case .work:
            return LightingPreset(
                ambientIntensity: 600,
                ambientColor: SIMD3(1.0, 0.97, 0.92),
                directionalIntensity: 400,
                directionalColor: SIMD3(1.0, 0.98, 0.95),
                directionalDirection: SIMD3(0, -1, -0.5),
                accentLights: [
                    (SIMD3(-1.5, 2, -1.5), SIMD3(0.4, 0.6, 1.0), 200),
                    (SIMD3(1.5, 2, -1.5), SIMD3(0.4, 0.6, 1.0), 200),
                ]
            )
        case .study:
            return LightingPreset(
                ambientIntensity: 450,
                ambientColor: SIMD3(1.0, 0.95, 0.85),
                directionalIntensity: 300,
                directionalColor: SIMD3(1.0, 0.92, 0.8),
                directionalDirection: SIMD3(0, -1, -0.3),
                accentLights: [
                    (SIMD3(0, 2, -1.5), SIMD3(1.0, 0.85, 0.5), 300),
                ]
            )
        case .cinema:
            return LightingPreset(
                ambientIntensity: 80,
                ambientColor: SIMD3(0.2, 0.15, 0.3),
                directionalIntensity: 50,
                directionalColor: SIMD3(0.3, 0.2, 0.5),
                directionalDirection: SIMD3(0, -1, -0.5),
                accentLights: [
                    (SIMD3(0, 0.5, -3), SIMD3(0.6, 0.4, 1.0), 100), // Screen glow
                    (SIMD3(-2, 1, 0), SIMD3(0.2, 0.1, 0.4), 50),     // Ambient purple
                ]
            )
        case .gaming:
            return LightingPreset(
                ambientIntensity: 150,
                ambientColor: SIMD3(0.1, 0.15, 0.25),
                directionalIntensity: 100,
                directionalColor: SIMD3(0.2, 0.3, 0.5),
                directionalDirection: SIMD3(0, -1, -0.5),
                accentLights: [
                    (SIMD3(-2, 1.5, -1), SIMD3(1.0, 0.0, 0.5), 250), // Neon pink
                    (SIMD3(2, 1.5, -1), SIMD3(0.0, 0.5, 1.0), 250),  // Neon blue
                    (SIMD3(0, 2.5, -2), SIMD3(0.5, 0.0, 1.0), 150),  // Top purple
                ]
            )
        case .custom:
            return preset(for: .work) // Fallback to work
        }
    }
    
    // MARK: - Apply to Entity
    
    /// Apply a lighting preset to a RealityKit root entity.
    static func applyLighting(_ preset: LightingPreset, to root: Entity) {
        // Remove existing lights
        let existingLights = root.children.filter { $0.name.hasPrefix("RoomLight_") }
        for light in existingLights {
            root.removeChild(light)
        }
        
        // Ambient light (from above)
        let ambientEntity = Entity()
        ambientEntity.name = "RoomLight_Ambient"
        ambientEntity.components.set(PointLightComponent(
            color: .init(
                red: CGFloat(preset.ambientColor.x),
                green: CGFloat(preset.ambientColor.y),
                blue: CGFloat(preset.ambientColor.z),
                alpha: 1
            ),
            intensity: preset.ambientIntensity,
            attenuationRadius: 10
        ))
        ambientEntity.position = SIMD3(0, 3, -1)
        root.addChild(ambientEntity)
        
        // Accent lights
        for (index, accent) in preset.accentLights.enumerated() {
            let accentEntity = Entity()
            accentEntity.name = "RoomLight_Accent_\(index)"
            accentEntity.components.set(PointLightComponent(
                color: .init(
                    red: CGFloat(accent.color.x),
                    green: CGFloat(accent.color.y),
                    blue: CGFloat(accent.color.z),
                    alpha: 1
                ),
                intensity: accent.intensity,
                attenuationRadius: 6
            ))
            accentEntity.position = accent.position
            root.addChild(accentEntity)
        }
    }
    
    // MARK: - Atmosphere Particles
    
    /// Create mode-specific atmosphere particles.
    static func createAtmosphere(for mode: WorkspaceMode) -> Entity {
        let root = Entity()
        root.name = "RoomAtmosphere"
        root.position = SIMD3(0, 1.5, -1.5)
        
        let config: (count: Int, hueRange: ClosedRange<Float>, opacity: Float, size: Float)
        switch mode {
        case .work:
            config = (8, 0.55...0.65, 0.08, 0.003)
        case .study:
            config = (6, 0.1...0.15, 0.06, 0.003)
        case .cinema:
            config = (20, 0.7...0.85, 0.12, 0.004)
        case .gaming:
            config = (25, 0.75...0.95, 0.15, 0.005)
        case .custom:
            config = (8, 0.55...0.65, 0.08, 0.003)
        }
        
        for _ in 0..<config.count {
            let particle = Entity()
            let mesh = MeshResource.generateSphere(radius: config.size)
            var material = UnlitMaterial()
            material.color = .init(tint: .init(
                hue: CGFloat(Float.random(in: config.hueRange)),
                saturation: 0.4,
                brightness: 0.9,
                alpha: CGFloat(config.opacity)
            ))
            particle.components.set(ModelComponent(mesh: mesh, materials: [material]))
            particle.position = SIMD3(
                Float.random(in: -2...2),
                Float.random(in: -0.8...1.2),
                Float.random(in: -2...0.5)
            )
            root.addChild(particle)
        }
        
        return root
    }
}
