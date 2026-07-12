// swift-tools-version: 6.2
// ──────────────────────────────────────────────────────────────
// HoloDesk — Spatial Workspace Platform for Apple Vision Pro
// Swift Student Challenge 2027 — visionOS 27 Submission
// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// ──────────────────────────────────────────────────────────────

import PackageDescription

#if canImport(AppleProductTypes) && !os(macOS)
import AppleProductTypes

let productsList: [Product] = [
    .iOSApplication(
        name: "HoloDesk",
        targets: ["HoloDesk"],
        bundleIdentifier: "com.notminelap.holodesk",
        teamIdentifier: "",
        displayVersion: "3.0.0",
        bundleVersion: "1",
        appIcon: .placeholder(icon: .cube),
        accentColor: .presetColor(.cyan),
        supportedDeviceFamilies: [
            .vision
        ],
        supportedInterfaceOrientations: [
            .portrait,
            .landscapeRight,
            .landscapeLeft
        ],
        capabilities: [
            .camera(purposeString: "Spatial scanning and 3D object capture"),
            .microphone(purposeString: "Voice commands and audio recording")
        ],
        appCategory: .productivity
    )
]
#else
let productsList: [Product] = [
    .executable(
        name: "HoloDesk",
        targets: ["HoloDesk"]
    )
]
#endif

let package = Package(
    name: "HoloDesk",
    platforms: [
        .visionOS(.v2),
        .macOS(.v15)
    ],
    products: productsList,
    dependencies: [],
    targets: [
        .executableTarget(
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
            path: "HoloDesk/RealityKitContent",
            exclude: ["Package.swift"]
        ),
    ]
)
