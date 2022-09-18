// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftMETAR",
    platforms: [.macOS(.v10_15), .iOS(.v12), .watchOS(.v4), .tvOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftMETAR",
            targets: ["SwiftMETAR"]),
        .executable(name: "SwiftMETARGauntlet", targets: ["SwiftMETARGauntlet"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.2.0")),
        .package(url: "https://github.com/xwu/NumericAnnex.git", branch: "master"),
        .package(url: "https://github.com/sharplet/Regex.git", from: "2.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftMETAR",
            dependencies: ["NumericAnnex", "Regex"]),
        .testTarget(
            name: "SwiftMETARTests",
            dependencies: ["SwiftMETAR", "Quick", "Nimble"]),
        .executableTarget(
            name: "SwiftMETARGauntlet",
            dependencies: ["SwiftMETAR"])
    ]
)
