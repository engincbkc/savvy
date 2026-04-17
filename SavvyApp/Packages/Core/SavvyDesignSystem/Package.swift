// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "SavvyDesignSystem",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "SavvyDesignSystem", targets: ["SavvyDesignSystem"]),
    ],
    dependencies: [
        .package(path: "../SavvyFoundation"),
    ],
    targets: [
        .target(
            name: "SavvyDesignSystem",
            dependencies: ["SavvyFoundation"],
            path: "Sources/SavvyDesignSystem"
        ),
        .testTarget(
            name: "SavvyDesignSystemTests",
            dependencies: ["SavvyDesignSystem"],
            path: "Tests/SavvyDesignSystemTests"
        ),
    ]
)
