// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "codex-theme-controller",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "codex-theme-controller",
            targets: ["CodexThemeController"]
        )
    ],
    targets: [
        .target(
            name: "CodexThemeControllerCore",
            path: "Sources/CodexThemeControllerCore"
        ),
        .executableTarget(
            name: "CodexThemeController",
            dependencies: ["CodexThemeControllerCore"],
            path: "Sources/CodexThemeController"
        ),
        .testTarget(
            name: "CodexThemeControllerCoreTests",
            dependencies: ["CodexThemeControllerCore"],
            path: "Tests/CodexThemeControllerCoreTests"
        )
    ]
)
