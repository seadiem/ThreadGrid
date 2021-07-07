// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ThreadGrid",
    platforms: [ .macOS(.v10_15), .iOS(.v9)],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", .branch("master")),
        .package(url: "https://github.com/apple/swift-algorithms", .branch("main")),
    ],
    targets: [
        .target(
            name: "ThreadGrid",
            dependencies: ["Files", .product(name: "Algorithms", package: "swift-algorithms")]),
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
