// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "SavvyNetworking",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "SavvyNetworking", targets: ["SavvyNetworking"]),
    ],
    dependencies: [
        .package(path: "../SavvyFoundation"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", "10.25.0"..<"11.0.0"),
    ],
    targets: [
        .target(
            name: "SavvyNetworking",
            dependencies: [
                "SavvyFoundation",
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            ],
            path: "Sources/SavvyNetworking"
        ),
        .testTarget(
            name: "SavvyNetworkingTests",
            dependencies: ["SavvyNetworking"],
            path: "Tests/SavvyNetworkingTests"
        ),
    ]
)
