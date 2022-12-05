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
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Starknet",
            dependencies: ["BigInt", "CryptoToolkit"]),
        .target(name: "CryptoToolkit", dependencies: ["CCryptoCppWrapper", "CCryptopp"]),
        .target(name: "CCryptoCppWrapper", dependencies: ["ccryptocpp"]),
        .target(name: "CCryptopp", dependencies: ["CppCryptopp"]),
        .target(
            name: "CppCryptopp",
            dependencies: [],
            exclude: [
                "TestData",
                "TestPrograms",
                "TestScripts",
                "TestVectors",
                "cryptest.nmake",
                "cryptest.sln",
                "cryptest.vcxproj",
                "cryptest.vcxproj.filters",
                "cryptest.vcxproj.user",
                "datatest.cpp",
                "dlltest.cpp",
                "dlltest.vcxproj",
                "dlltest.vcxproj.filters",
                "fipstest.cpp",
                "regtest1.cpp",
                "regtest2.cpp",
                "regtest3.cpp",
                "regtest4.cpp",
                "test.cpp",
                "bench.h",
                "bench1.cpp",
                "bench2.cpp",
                "bench3.cpp",
                "aes_armv4.S",
                "aes_armv4.h",
                "sha1_armv4.S",
                "sha1_armv4.h",
                "sha256_armv4.S",
                "sha256_armv4.h",
                "sha512_armv4.S",
                "sha512_armv4.h",
                "validat0.cpp",
                "validat1.cpp",
                "validat10.cpp",
                "validat2.cpp",
                "validat3.cpp",
                "validat4.cpp",
                "validat5.cpp",
                "validat6.cpp",
                "validat7.cpp",
                "validat8.cpp",
                "validat9.cpp",
                "validate.h"
            ],
            publicHeadersPath: "."
        ),
        .binaryTarget(name: "ccryptocpp", path: "Frameworks/ccryptocpp.xcframework"),
        .testTarget(
            name: "StarknetTests",
            dependencies: ["Starknet", "BigInt"]),
    ]
)
