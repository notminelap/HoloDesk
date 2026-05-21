// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import RealityKit

// MARK: - Skybox Environment System

/// Custom 360° immersive environments — space station, mountain, underwater, cozy cabin.
struct SkyboxEnvironment {
    
    enum Skybox: String, CaseIterable, Identifiable {
        case passthrough = "Passthrough"
        case spaceStation = "Space Station"
        case mountaintop = "Mountain Top"
        case underwater = "Deep Ocean"
        case cozyCabin = "Cozy Cabin"
        case nightCity = "Night City"
        case zenGarden = "Zen Garden"
        case cloudKingdom = "Cloud Kingdom"
        case aurora = "Northern Lights"
        case library = "Grand Library"
        
        var id: String { rawValue }
        
        var emoji: String {
            switch self {
            case .passthrough:  return "👁️"
            case .spaceStation: return "🛸"
            case .mountaintop:  return "🏔️"
            case .underwater:   return "🐋"
            case .cozyCabin:    return "🏡"
            case .nightCity:    return "🌃"
            case .zenGarden:    return "🎋"
            case .cloudKingdom: return "☁️"
            case .aurora:       return "🌌"
            case .library:      return "📚"
            }
        }
        
        var description: String {
            switch self {
            case .passthrough:  return "See your real room"
            case .spaceStation: return "Orbiting Earth at 400km altitude"
            case .mountaintop:  return "Sunrise at 4,000m with panoramic views"
            case .underwater:   return "Bioluminescent deep sea creatures"
            case .cozyCabin:    return "Fireplace, wood walls, snow outside"
            case .nightCity:    return "Neon-lit cyberpunk rooftop"
            case .zenGarden:    return "Japanese rock garden with flowing water"
            case .cloudKingdom: return "Above the clouds, golden sunlight"
            case .aurora:       return "Arctic night with dancing lights"
            case .library:      return "Victorian library with warm lamplight"
            }
        }
        
        var ambientColor: SIMD3<Float> {
            switch self {
            case .passthrough:  return SIMD3(1, 1, 1)
            case .spaceStation: return SIMD3(0.2, 0.25, 0.4)
            case .mountaintop:  return SIMD3(1.0, 0.85, 0.7)
            case .underwater:   return SIMD3(0.1, 0.3, 0.5)
            case .cozyCabin:    return SIMD3(1.0, 0.7, 0.4)
            case .nightCity:    return SIMD3(0.3, 0.1, 0.5)
            case .zenGarden:    return SIMD3(0.6, 0.8, 0.5)
            case .cloudKingdom: return SIMD3(1.0, 0.95, 0.8)
            case .aurora:       return SIMD3(0.1, 0.5, 0.4)
            case .library:      return SIMD3(0.9, 0.75, 0.5)
            }
        }
        
        var immersionLevel: Double {
            switch self {
            case .passthrough: return 0
            default: return 0.85
            }
        }
    }
    
    /// Generate RealityKit entities for the skybox environment.
    static func createEnvironment(for skybox: Skybox) -> Entity {
        let root = Entity()
        root.name = "Skybox_\(skybox.rawValue)"
        
        // Create a large sphere for the sky
        let skyMesh = MeshResource.generateSphere(radius: 50)
        var skyMaterial = UnlitMaterial()
        skyMaterial.color = .init(tint: .init(
            red: CGFloat(skybox.ambientColor.x),
            green: CGFloat(skybox.ambientColor.y),
            blue: CGFloat(skybox.ambientColor.z),
            alpha: 1
        ))
        
        let skyEntity = Entity()
        skyEntity.components.set(ModelComponent(mesh: skyMesh, materials: [skyMaterial]))
        skyEntity.scale = SIMD3(-1, 1, 1) // Invert normals
        root.addChild(skyEntity)
        
        return root
    }
}

// MARK: - Skybox Picker View

struct SkyboxPickerView: View {
    @Binding var currentSkybox: SkyboxEnvironment.Skybox
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.cyan)
                Text("Environments")
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
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(SkyboxEnvironment.Skybox.allCases) { skybox in
                    skyboxCard(skybox)
                }
            }
        }
        .padding(20)
        .frame(width: 380)
        .glassBackground(cornerRadius: 24)
    }
    
    private func skyboxCard(_ skybox: SkyboxEnvironment.Skybox) -> some View {
        let isActive = currentSkybox == skybox
        let color = Color(
            red: Double(skybox.ambientColor.x),
            green: Double(skybox.ambientColor.y),
            blue: Double(skybox.ambientColor.z)
        )
        
        return Button {
            currentSkybox = skybox
            HapticManager.shared.mediumTap()
        } label: {
            VStack(spacing: 6) {
                Text(skybox.emoji)
                    .font(.system(size: 22))
                    .frame(width: 50, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color.opacity(isActive ? 0.35 : 0.15))
                    )
                
                Text(skybox.rawValue)
                    .font(.system(size: 10, weight: isActive ? .bold : .medium))
                    .foregroundStyle(.white.opacity(isActive ? 1 : 0.5))
                    .lineLimit(1)
                
                Text(skybox.description)
                    .font(.system(size: 7))
                    .foregroundStyle(.white.opacity(0.3))
                    .lineLimit(1)
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isActive ? color.opacity(0.1) : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isActive ? color.opacity(0.3) : .clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
