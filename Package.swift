// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Starknet",
    platforms: [
        .iOS(SupportedPlatform.IOSVersion.v13),
        .macOS(SupportedPlatform.MacOSVersion.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Starknet",
            targets: ["Starknet"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/GigaBitcoin/secp256k1.swift.git", .upToNextMajor(from: "0.8.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Starknet",
            dependencies: ["BigInt", "CryptoToolkit"]),
        .target(name: "CryptoToolkit", dependencies: ["CCryptoCppWrapper", .product(name: "secp256k1", package: "secp256k1.swift")]),
        .target(name: "CCryptoCppWrapper", dependencies: ["ccryptocpp"]),
        .binaryTarget(name: "ccryptocpp", path: "Frameworks/ccryptocpp.xcframework"),
        .testTarget(
            name: "StarknetTests",
            dependencies: ["Starknet", "BigInt"]),
    ]
)
