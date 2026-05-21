// swift-tools-version: 5.9
// ──────────────────────────────────────────────────────────────
// HoloDesk — Spatial Workspace Platform for Apple Vision Pro
// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// ──────────────────────────────────────────────────────────────

import PackageDescription

let package = Package(
    name: "HoloDesk",
    platforms: [
        .visionOS(.v2),
        .macOS(.v14),       // macOS compatibility
        .iOS(.v17)          // iPad fallback
    ],
    products: [
        .library(
            name: "HoloDesk",
            targets: ["HoloDesk"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "HoloDesk",
            dependencies: ["RealityKitContent"],
            path: "HoloDesk",
            exclude: ["RealityKitContent", "App/Info.plist"],
            resources: [
                .process("Assets/Resources"),
                .process("Assets/Presets")
            ]
        ),
        .target(
            name: "RealityKitContent",
            path: "HoloDesk/RealityKitContent"
        ),
    ]
)
