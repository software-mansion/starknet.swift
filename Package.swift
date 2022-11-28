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
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Starknet",
            dependencies: ["BigInt", "CryptoToolkit"]),
        .target(name: "CryptoToolkit", dependencies: ["CCryptoCppWrapper", "CSecp256K1"]),
        .target(name: "CCryptoCppWrapper", dependencies: ["ccryptocpp"]),
        .target(
            name: "CSecp256K1",
            exclude: [
                "secp256k1/autogen.sh",
                "secp256k1/build-aux",
                "secp256k1/ci",
                "secp256k1/configure.ac",
                "secp256k1/contrib",
                "secp256k1/COPYING",
                "secp256k1/doc",
                "secp256k1/examples",
                "secp256k1/libsecp256k1.pc.in",
                "secp256k1/Makefile.am",
                "secp256k1/README.md",
                "secp256k1/sage",
                "secp256k1/SECURITY.md",
                "secp256k1/src/asm",
                "secp256k1/src/bench_ecmult.c",
                "secp256k1/src/bench_internal.c",
                "secp256k1/src/bench.c",
                "secp256k1/src/modules",
                "secp256k1/src/precompute_ecmult_gen.c",
                "secp256k1/src/precompute_ecmult.c",
                "secp256k1/src/tests_exhaustive.c",
                "secp256k1/src/tests.c",
                "secp256k1/src/valgrind_ctime_test.c"
            ],
            sources: [
                "secp256k1/src/precomputed_ecmult_gen.c",
                "secp256k1/src/precomputed_ecmult.c",
                "secp256k1/src/secp256k1.c",
            ],
            cSettings: [
                // Basic config values that are universal and require no dependencies.
                // https://github.com/bitcoin-core/secp256k1/blob/master/src/basic-config.h#L12-L13
                .define("ECMULT_GEN_PREC_BITS", to: "4"),
                .define("ECMULT_WINDOW_SIZE", to: "15")
            ]
        ),
        .binaryTarget(name: "ccryptocpp", path: "Frameworks/ccryptocpp.xcframework"),
        .testTarget(
            name: "StarknetTests",
            dependencies: ["Starknet", "BigInt"]),
    ]
)
