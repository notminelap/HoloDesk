// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

import SwiftUI
import RealityKit

// MARK: - Spatial File Object

/// Represents a 3D file object that exists in immersive space —
/// the "Finder in real life" concept. Files are physical objects you can grab.

enum SpatialFileType: String, Codable, CaseIterable, Identifiable {
    case pdf
    case photo
    case folder
    case video
    case stickyNote
    case whiteboard
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .pdf:        return "Document"
        case .photo:      return "Photo Frame"
        case .folder:     return "Folder Box"
        case .video:      return "Video Screen"
        case .stickyNote: return "Sticky Note"
        case .whiteboard: return "Whiteboard"
        }
    }
    
    var iconName: String {
        switch self {
        case .pdf:        return "doc.fill"
        case .photo:      return "photo.artframe"
        case .folder:     return "archivebox.fill"
        case .video:      return "tv"
        case .stickyNote: return "note.text"
        case .whiteboard: return "rectangle.3.group"
        }
    }
    
    var emoji: String {
        switch self {
        case .pdf:        return "📄"
        case .photo:      return "🖼️"
        case .folder:     return "📦"
        case .video:      return "🎬"
        case .stickyNote: return "📝"
        case .whiteboard: return "🧑‍🏫"
        }
    }
}

/// Data model for a spatial file placed in the room.
struct SpatialFile: Identifiable, Codable {
    let id: UUID
    var type: SpatialFileType
    var name: String
    var position: SIMD3<Float>
    var rotation: SIMD4<Float>
    var scale: Float
    var color: [Float]  // RGB
    var content: String  // Text content for notes/whiteboards
    
    init(
        id: UUID = UUID(),
        type: SpatialFileType,
        name: String,
        position: SIMD3<Float> = SIMD3(0, 1.2, -1.0),
        rotation: SIMD4<Float> = SIMD4(0, 0, 0, 1),
        scale: Float = 1.0,
        color: [Float] = [1, 1, 1],
        content: String = ""
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.position = position
        self.rotation = rotation
        self.scale = scale
        self.color = color
        self.content = content
    }
}

// MARK: - Entity Builder

/// Creates RealityKit entities for each spatial file type.
struct SpatialFileEntityBuilder {
    
    static func buildEntity(for file: SpatialFile) -> Entity {
        switch file.type {
        case .pdf:        return buildPDF(file)
        case .photo:      return buildPhotoFrame(file)
        case .folder:     return buildFolderBox(file)
        case .video:      return buildVideoScreen(file)
        case .stickyNote: return buildStickyNote(file)
        case .whiteboard: return buildWhiteboard(file)
        }
    }
    
    // MARK: - PDF Document
    
    private static func buildPDF(_ file: SpatialFile) -> Entity {
        let entity = Entity()
        entity.name = "PDF_\(file.id.uuidString)"
        entity.position = file.position
        
        // Paper sheet — A4 ratio
        let paperMesh = MeshResource.generateBox(
            size: SIMD3(0.21, 0.297, 0.002),
            cornerRadius: 0.003
        )
        var paperMaterial = SimpleMaterial()
        paperMaterial.color = .init(tint: .init(white: 0.95, alpha: 1))
        paperMaterial.roughness = 0.9
        entity.components.set(ModelComponent(mesh: paperMesh, materials: [paperMaterial]))
        
        // Slight curl shadow using a thin dark strip at bottom
        let shadowEntity = Entity()
        let shadowMesh = MeshResource.generateBox(size: SIMD3(0.21, 0.01, 0.001))
        var shadowMat = SimpleMaterial()
        shadowMat.color = .init(tint: .init(white: 0, alpha: 0.15))
        shadowEntity.components.set(ModelComponent(mesh: shadowMesh, materials: [shadowMat]))
        shadowEntity.position = SIMD3(0, -0.148, -0.002)
        entity.addChild(shadowEntity)
        
        // Blue header bar (like a PDF viewer)
        let headerEntity = Entity()
        let headerMesh = MeshResource.generateBox(size: SIMD3(0.19, 0.015, 0.001))
        var headerMat = SimpleMaterial()
        headerMat.color = .init(tint: .init(red: 0.2, green: 0.4, blue: 0.9, alpha: 1))
        headerEntity.components.set(ModelComponent(mesh: headerMesh, materials: [headerMat]))
        headerEntity.position = SIMD3(0, 0.13, 0.002)
        entity.addChild(headerEntity)
        
        // Text line placeholders
        for i in 0..<8 {
            let line = Entity()
            let width: Float = Float.random(in: 0.1...0.17)
            let lineMesh = MeshResource.generateBox(size: SIMD3(width, 0.004, 0.0005))
            var lineMat = SimpleMaterial()
            lineMat.color = .init(tint: .init(white: 0.7, alpha: 1))
            line.components.set(ModelComponent(mesh: lineMesh, materials: [lineMat]))
            line.position = SIMD3(-(0.17 - width) / 2, 0.1 - Float(i) * 0.025, 0.002)
            entity.addChild(line)
        }
        
        addInteraction(to: entity, size: SIMD3(0.21, 0.297, 0.01))
        return entity
    }
    
    // MARK: - Photo Frame
    
    private static func buildPhotoFrame(_ file: SpatialFile) -> Entity {
        let entity = Entity()
        entity.name = "Photo_\(file.id.uuidString)"
        entity.position = file.position
        
        // Wooden frame
        let frameMesh = MeshResource.generateBox(
            size: SIMD3(0.28, 0.22, 0.015),
            cornerRadius: 0.005
        )
        var frameMaterial = SimpleMaterial()
        frameMaterial.color = .init(tint: .init(red: 0.35, green: 0.22, blue: 0.12, alpha: 1))
        frameMaterial.roughness = 0.4
        frameMaterial.metallic = 0.1
        entity.components.set(ModelComponent(mesh: frameMesh, materials: [frameMaterial]))
        
        // Inner photo (gradient to simulate landscape)
        let photoEntity = Entity()
        let photoMesh = MeshResource.generateBox(size: SIMD3(0.24, 0.18, 0.001))
        var photoMat = SimpleMaterial()
        photoMat.color = .init(tint: .init(
            red: CGFloat(file.color[0]),
            green: CGFloat(file.color[1]),
            blue: CGFloat(file.color[2]),
            alpha: 1
        ))
        photoEntity.components.set(ModelComponent(mesh: photoMesh, materials: [photoMat]))
        photoEntity.position.z = 0.008
        entity.addChild(photoEntity)
        
        addInteraction(to: entity, size: SIMD3(0.28, 0.22, 0.02))
        return entity
    }
    
    // MARK: - Folder Box (3D container)
    
    private static func buildFolderBox(_ file: SpatialFile) -> Entity {
        let entity = Entity()
        entity.name = "Folder_\(file.id.uuidString)"
        entity.position = file.position
        
        // Box base
        let boxMesh = MeshResource.generateBox(
            size: SIMD3(0.15, 0.12, 0.12),
            cornerRadius: 0.008
        )
        var boxMaterial = SimpleMaterial()
        boxMaterial.color = .init(tint: .init(red: 0.2, green: 0.5, blue: 0.95, alpha: 0.9))
        boxMaterial.roughness = 0.3
        boxMaterial.metallic = 0.2
        entity.components.set(ModelComponent(mesh: boxMesh, materials: [boxMaterial]))
        
        // Label strip on front
        let labelEntity = Entity()
        let labelMesh = MeshResource.generateBox(size: SIMD3(0.1, 0.025, 0.001))
        var labelMat = SimpleMaterial()
        labelMat.color = .init(tint: .init(white: 0.95, alpha: 1))
        labelEntity.components.set(ModelComponent(mesh: labelMesh, materials: [labelMat]))
        labelEntity.position = SIMD3(0, -0.02, 0.061)
        entity.addChild(labelEntity)
        
        addInteraction(to: entity, size: SIMD3(0.15, 0.12, 0.12))
        return entity
    }
    
    // MARK: - Video Screen
    
    private static func buildVideoScreen(_ file: SpatialFile) -> Entity {
        let entity = Entity()
        entity.name = "Video_\(file.id.uuidString)"
        entity.position = file.position
        
        // Screen bezel
        let bezelMesh = MeshResource.generateBox(
            size: SIMD3(0.45, 0.28, 0.008),
            cornerRadius: 0.01
        )
        var bezelMat = SimpleMaterial()
        bezelMat.color = .init(tint: .init(white: 0.08, alpha: 1))
        bezelMat.roughness = 0.1
        bezelMat.metallic = 0.9
        entity.components.set(ModelComponent(mesh: bezelMesh, materials: [bezelMat]))
        
        // Screen surface
        let screenEntity = Entity()
        let screenMesh = MeshResource.generateBox(size: SIMD3(0.42, 0.25, 0.001))
        var screenMat = UnlitMaterial()
        screenMat.color = .init(tint: .init(red: 0.05, green: 0.05, blue: 0.12, alpha: 1))
        screenEntity.components.set(ModelComponent(mesh: screenMesh, materials: [screenMat]))
        screenEntity.position.z = 0.005
        entity.addChild(screenEntity)
        
        // Play button indicator (triangle)
        let playEntity = Entity()
        let playMesh = MeshResource.generateBox(size: SIMD3(0.03, 0.04, 0.001))
        var playMat = UnlitMaterial()
        playMat.color = .init(tint: .init(white: 0.6, alpha: 0.8))
        playEntity.components.set(ModelComponent(mesh: playMesh, materials: [playMat]))
        playEntity.position = SIMD3(0, 0, 0.006)
        entity.addChild(playEntity)
        
        addInteraction(to: entity, size: SIMD3(0.45, 0.28, 0.02))
        return entity
    }
    
    // MARK: - Sticky Note
    
    private static func buildStickyNote(_ file: SpatialFile) -> Entity {
        let entity = Entity()
        entity.name = "StickyNote_\(file.id.uuidString)"
        entity.position = file.position
        
        let mesh = MeshResource.generateBox(
            size: SIMD3(0.1, 0.1, 0.001),
            cornerRadius: 0.002
        )
        var material = SimpleMaterial()
        material.color = .init(tint: .init(
            red: CGFloat(file.color[0]),
            green: CGFloat(file.color[1]),
            blue: CGFloat(file.color[2]),
            alpha: 0.92
        ))
        material.roughness = 0.85
        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))
        
        // Slight fold at top corner
        let foldEntity = Entity()
        let foldMesh = MeshResource.generateBox(size: SIMD3(0.015, 0.015, 0.0015))
        var foldMat = SimpleMaterial()
        foldMat.color = .init(tint: .init(
            red: CGFloat(file.color[0]) * 0.85,
            green: CGFloat(file.color[1]) * 0.85,
            blue: CGFloat(file.color[2]) * 0.85,
            alpha: 1
        ))
        foldEntity.components.set(ModelComponent(mesh: foldMesh, materials: [foldMat]))
        foldEntity.position = SIMD3(0.042, 0.042, 0.001)
        entity.addChild(foldEntity)
        
        addInteraction(to: entity, size: SIMD3(0.1, 0.1, 0.01))
        return entity
    }
    
    // MARK: - Whiteboard
    
    private static func buildWhiteboard(_ file: SpatialFile) -> Entity {
        let entity = Entity()
        entity.name = "Whiteboard_\(file.id.uuidString)"
        entity.position = file.position
        
        // Board
        let boardMesh = MeshResource.generateBox(
            size: SIMD3(0.6, 0.4, 0.01),
            cornerRadius: 0.01
        )
        var boardMat = SimpleMaterial()
        boardMat.color = .init(tint: .init(white: 0.97, alpha: 1))
        boardMat.roughness = 0.95
        entity.components.set(ModelComponent(mesh: boardMesh, materials: [boardMat]))
        
        // Frame border
        let frameMesh = MeshResource.generateBox(
            size: SIMD3(0.62, 0.42, 0.012),
            cornerRadius: 0.012
        )
        var frameMat = SimpleMaterial()
        frameMat.color = .init(tint: .init(white: 0.4, alpha: 1))
        frameMat.metallic = 0.7
        let frameEntity = Entity()
        frameEntity.components.set(ModelComponent(mesh: frameMesh, materials: [frameMat]))
        frameEntity.position.z = -0.002
        entity.addChild(frameEntity)
        
        // Sketch lines (simulate whiteboard content)
        for i in 0..<5 {
            let line = Entity()
            let w: Float = Float.random(in: 0.15...0.4)
            let lineMesh = MeshResource.generateBox(size: SIMD3(w, 0.003, 0.0005))
            var lineMat = SimpleMaterial()
            let colors: [(CGFloat, CGFloat, CGFloat)] = [
                (0.1, 0.1, 0.8), (0.8, 0.1, 0.1), (0.1, 0.6, 0.1), (0.1, 0.1, 0.1), (0.6, 0.1, 0.6)
            ]
            let c = colors[i]
            lineMat.color = .init(tint: .init(red: c.0, green: c.1, blue: c.2, alpha: 1))
            line.components.set(ModelComponent(mesh: lineMesh, materials: [lineMat]))
            line.position = SIMD3(
                Float.random(in: -0.15...0.05),
                0.15 - Float(i) * 0.07,
                0.006
            )
            entity.addChild(line)
        }
        
        addInteraction(to: entity, size: SIMD3(0.62, 0.42, 0.02))
        return entity
    }
    
    // MARK: - Helper
    
    private static func addInteraction(to entity: Entity, size: SIMD3<Float>) {
        entity.components.set(InputTargetComponent())
        entity.components.set(CollisionComponent(shapes: [.generateBox(size: size)]))
        entity.components.set(HoverEffectComponent())
    }
}
