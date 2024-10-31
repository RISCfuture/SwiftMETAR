// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftMETAR",
    defaultLocalization: "en",
    platforms: [.macOS(.v15), .iOS(.v18), .watchOS(.v11), .tvOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftMETAR",
            targets: ["SwiftMETAR"]),
        .executable(name: "SwiftMETARGauntlet", targets: ["SwiftMETARGauntlet"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.6.0"),
        .package(url: "https://github.com/objecthub/swift-numberkit.git", from: "2.6.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.4.3"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftMETAR",
            dependencies: [.product(name: "NumberKit", package: "swift-numberkit")]),
        .testTarget(
            name: "SwiftMETARTests",
            dependencies: ["SwiftMETAR", "Quick", "Nimble"]),
        .executableTarget(
            name: "SwiftMETARGauntlet",
            dependencies: [
                "SwiftMETAR",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ])
    ],
    swiftLanguageModes: [.v5, .v6]
)
