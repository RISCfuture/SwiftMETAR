// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftMETAR",
    defaultLocalization: "en",
    platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftMETAR",
            targets: ["SwiftMETAR"]),
        .library(
            name: "METARFormatting",
            targets: ["METARFormatting"]),
        .executable(name: "decode-metar", targets: ["DecodeMETAR"]),
        .executable(name: "decode-taf", targets: ["DecodeTAF"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.6.0"),
        .package(url: "https://github.com/objecthub/swift-numberkit.git", from: "2.6.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.4.3"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/riscfuture/BuildableMacro.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftMETAR",
            dependencies: [.product(name: "NumberKit", package: "swift-numberkit")],
            resources: [.process("Resources")]),
        .target(
            name: "METARFormatting",
            dependencies: [
                "SwiftMETAR",
                .product(name: "BuildableMacro", package: "BuildableMacro")],
            resources: [.process("Resources")]),
        .testTarget(
            name: "SwiftMETARTests",
            dependencies: ["SwiftMETAR", "Quick", "Nimble"]),
        .executableTarget(
            name: "DecodeMETAR",
            dependencies: [
                "SwiftMETAR",
                "METARFormatting",
                .product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .executableTarget(
            name: "DecodeTAF",
            dependencies: [
                "SwiftMETAR",
                "METARFormatting",
                .product(name: "ArgumentParser", package: "swift-argument-parser")])
    ],
    swiftLanguageModes: [.v5, .v6]
)
