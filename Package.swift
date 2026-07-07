// swift-tools-version: 6.0

import PackageDescription

let approachableConcurrency: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances")
]

// METARFormatting (and DecodeMETAR/DecodeTAF, which depend on it) format `Measurement`
// values using `Measurement.FormatStyle` and the `\(_, format:)` string interpolation
// sugar for custom `FormatStyle` types. Neither is implemented by swift-corelibs-foundation,
// so these targets/products are only defined on Apple platforms; SwiftMETAR and
// DecodeWindsAloft don't use these APIs and build fine everywhere.
var products: [Product] = [
  // Products define the executables and libraries a package produces, and make them visible to other packages.
  .library(
    name: "SwiftMETAR",
    targets: ["SwiftMETAR"]
  ),
  .executable(name: "decode-winds-aloft", targets: ["DecodeWindsAloft"])
]

var targets: [Target] = [
  // Targets are the basic building blocks of a package. A target can define a module or a test suite.
  // Targets can depend on other targets in this package, and on products in packages this package depends on.
  .target(
    name: "SwiftMETAR",
    dependencies: [.product(name: "NumberKit", package: "swift-numberkit")],
    resources: [.process("Resources")],
    swiftSettings: approachableConcurrency
  ),
  .testTarget(
    name: "SwiftMETARTests",
    dependencies: ["SwiftMETAR"],
    swiftSettings: approachableConcurrency
  ),
  .executableTarget(
    name: "DecodeWindsAloft",
    dependencies: [
      "SwiftMETAR",
      .product(name: "ArgumentParser", package: "swift-argument-parser")
    ],
    swiftSettings: approachableConcurrency
  )
]

#if !os(Linux)
  products += [
    .library(
      name: "METARFormatting",
      targets: ["METARFormatting"]
    ),
    .executable(name: "decode-metar", targets: ["DecodeMETAR"]),
    .executable(name: "decode-taf", targets: ["DecodeTAF"])
  ]

  targets += [
    .target(
      name: "METARFormatting",
      dependencies: [
        "SwiftMETAR",
        .product(name: "BuildableMacro", package: "BuildableMacro")
      ],
      resources: [.process("Resources")],
      swiftSettings: approachableConcurrency
    ),
    .executableTarget(
      name: "DecodeMETAR",
      dependencies: [
        "SwiftMETAR",
        "METARFormatting",
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      swiftSettings: approachableConcurrency
    ),
    .executableTarget(
      name: "DecodeTAF",
      dependencies: [
        "SwiftMETAR",
        "METARFormatting",
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      swiftSettings: approachableConcurrency
    )
  ]
#endif

let package = Package(
  name: "SwiftMETAR",
  defaultLocalization: "en",
  platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1)],
  products: products,
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/objecthub/swift-numberkit.git", from: "2.6.0"),
    .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.4.3"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    .package(url: "https://github.com/riscfuture/BuildableMacro.git", from: "1.0.0")
  ],
  targets: targets,
  swiftLanguageModes: [.v5, .v6]
)
