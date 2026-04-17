// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "SavvyFoundation",
    platforms: [.iOS(.v17), .macOS(.v14), .watchOS(.v10)],
    products: [
        .library(name: "SavvyFoundation", targets: ["SavvyFoundation"]),
    ],
    targets: [
        .target(
            name: "SavvyFoundation",
            path: "Sources/SavvyFoundation"
        ),
        .testTarget(
            name: "SavvyFoundationTests",
            dependencies: ["SavvyFoundation"],
            path: "Tests/SavvyFoundationTests"
        ),
    ]
)
