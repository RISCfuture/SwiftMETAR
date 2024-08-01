// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftMETAR",
    defaultLocalization: "en",
    platforms: [.macOS(.v13), .iOS(.v16), .watchOS(.v9), .tvOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftMETAR",
            targets: ["SwiftMETAR"]),
        .executable(name: "SwiftMETARGauntlet", targets: ["SwiftMETARGauntlet"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Quick/Quick.git", from: "4.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.2.0"),
        .package(url: "https://github.com/objecthub/swift-numberkit.git", from: "2.4.2"),
        .package(url: "https://github.com/sharplet/Regex.git", from: "2.1.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.0.0"),
        .package(url: "https://github.com/1024jp/GzipSwift.git", from: "6.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftMETAR",
            dependencies: [.product(name: "NumberKit", package: "swift-numberkit"), "Regex"],
            resources: [.process("Resources")]),
        .testTarget(
            name: "SwiftMETARTests",
            dependencies: ["SwiftMETAR", "Quick", "Nimble"]),
        .executableTarget(
            name: "SwiftMETARGauntlet",
            dependencies: ["SwiftMETAR", .product(name: "Gzip", package: "GzipSwift")])
    ]
)
