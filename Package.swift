// swift-tools-version: 6.2
// ──────────────────────────────────────────────────────────────
// HoloDesk — Spatial Workspace Platform for Apple Vision Pro
// Swift Student Challenge 2027 — visionOS 27 Submission
// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// ──────────────────────────────────────────────────────────────

import PackageDescription

// AppleProductTypes exists in Xcode and Swift Playgrounds — both must take the
// app-product path or the simulator gets a UI-less command-line executable that
// builds fine but never launches a window. os(macOS) here tests the manifest
// HOST (always the Mac in Xcode), so it must NOT gate this branch.
#if canImport(AppleProductTypes)
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
