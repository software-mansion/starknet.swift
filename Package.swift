// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Starknet",
    platforms: [
        .iOS(SupportedPlatform.IOSVersion.v13),
        .macOS(SupportedPlatform.MacOSVersion.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Starknet",
            targets: ["Starknet"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.9.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Starknet",
            dependencies: ["BigInt", "CryptoToolkit", "CryptoSwift"]
        ),
        .target(name: "CryptoToolkit", dependencies: ["CFrameworkWrapper"]),
        .target(name: "CFrameworkWrapper", dependencies: ["ccryptocpp", "poseidon", "CryptoRs"]),
        .binaryTarget(name: "ccryptocpp", path: "Frameworks/ccryptocpp.xcframework"),
        .binaryTarget(name: "poseidon", path: "Frameworks/poseidon.xcframework"),
        .binaryTarget(name: "CryptoRs", path: "Frameworks/CryptoRs.xcframework"),
        .testTarget(
            name: "StarknetTests",
            dependencies: ["Starknet", "BigInt"],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "NetworkTests",
            dependencies: ["Starknet"]
        ),
    ]
)
