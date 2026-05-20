// Copyright (c) 2026 Notminelap Industries. All Rights Reserved.
// Licensed under the HoloDesk Source-Available License.
// See LICENSE file for details.

// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RealityKitContent",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "RealityKitContent",
            targets: ["RealityKitContent"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RealityKitContent",
            dependencies: [],
            resources: [
                // Add .reality files, .usdz models, and materials here
                // .process("Scene.usda"),
                // .process("Materials"),
            ]
        ),
    ]
)
