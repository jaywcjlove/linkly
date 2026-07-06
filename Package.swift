// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "linkly",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.122.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.5.2"),
    ],
    targets: [
        .executableTarget(
            name: "linkly",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Leaf", package: "leaf"),
            ],
            exclude: ["Resources"]
        ),
    ]
)
