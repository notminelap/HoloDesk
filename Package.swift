// swift-tools-version: 5.9
// HoloDesk — visionOS 2.0 Spatial Workspace Platform
// Xcode 16+ required

import PackageDescription

let package = Package(
    name: "HoloDesk",
    platforms: [
        .visionOS(.v2)
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
            path: "HoloDesk"
        ),
        .target(
            name: "RealityKitContent",
            path: "HoloDesk/RealityKitContent",
            sources: ["Sources/RealityKitContent"]
        ),
    ]
)
