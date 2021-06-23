// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ThreadGrid",
    platforms: [ .macOS(.v10_15), .iOS(.v9)],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", .branch("master")),
    ],
    targets: [
        .target(
            name: "ThreadGrid",
            dependencies: ["Files"]),
        .target(
            name: "Draw",
            dependencies: []),
        .target(
            name: "App",
            dependencies: ["Draw"]),
        .target(
            name: "Runner",
            dependencies: ["App", "ThreadGrid"]),
    ]
)
