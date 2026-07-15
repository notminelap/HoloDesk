// swift-tools-version: 6.2
// ──────────────────────────────────────────────────────────────
// HoloDesk — Spatial Workspace Platform for Apple Vision Pro
// Swift Student Challenge 2027 — visionOS 27 Submission
// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// ──────────────────────────────────────────────────────────────

import PackageDescription

// This branch is for Swift Playgrounds on iPad only (os(macOS) tests the
// manifest HOST, so it is always false there and always true in Xcode).
// Xcode users must open HoloDesk.xcodeproj — the native visionOS app target.
// The executable product below builds under Xcode but can never install in
// the simulator (no app bundle), which is why the xcodeproj exists.
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
        // .cube is not a valid PlaceholderIcon and AppleProductTypes has no
        // .vision device family (both CI-verified) — the original values had
        // never actually compiled. Native visionOS ships via HoloDesk.xcodeproj.
        appIcon: .asset("AppIcon"),
        accentColor: .presetColor(.cyan),
        supportedDeviceFamilies: [
            .pad
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
