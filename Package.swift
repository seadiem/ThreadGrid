// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ThreadGrid",
    platforms: [ .macOS(.v10_15), .iOS(.v9)],
    products: [
        .library(name: "Lights", targets: ["ThreadGrid"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", .branch("master")),
        .package(url: "https://github.com/apple/swift-algorithms", .branch("main")),
        .package(url: "/Users/oktet/Code/Learn/HanoyTowers", .branch("metal")),
    ],
    targets: [
        .target(
            name: "ThreadGrid",
            dependencies: ["Files", .product(name: "Algorithms", package: "swift-algorithms"), "HanoyTowers"]),
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
