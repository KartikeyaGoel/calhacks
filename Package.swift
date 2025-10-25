// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VOICE",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // The main VOICE library
        .library(
            name: "VOICE",
            targets: ["VOICE"]),
        // Optional CLI executable for testing from command line
        .executable(
            name: "voice-cli",
            targets: ["VOICECLI"])
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        // Main library target containing all business logic
        .target(
            name: "VOICE",
            dependencies: [],
            path: "Sources/VOICE",
            exclude: [
                // Exclude iOS-specific assets and UI files that can't compile on macOS
                "Assets.xcassets",
                "Info.plist",
                "Resources"
            ]
        ),
        
        // CLI executable target for command-line testing
        .executableTarget(
            name: "VOICECLI",
            dependencies: ["VOICE"],
            path: "Sources/VOICECLI"
        ),
        
        // Test target
        .testTarget(
            name: "VOICETests",
            dependencies: ["VOICE"],
            path: "Tests",
            exclude: ["README.md", "Fixtures/README.md"]
        ),
    ]
)

