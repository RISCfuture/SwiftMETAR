import Foundation
@preconcurrency import RegexBuilder

class TurbulenceParser {
  private let typeRef = Reference<Character>()
  private let baseRef = Reference<UInt>()
  private let depthRef = Reference<UInt>()

  private lazy var rx = Regex {
    Anchor.wordBoundary
    "5"
    Capture(as: typeRef) {
      CharacterClass("0"..."9", .anyOf("X"))
    } transform: {
      $0.first!
    }
    Capture(as: baseRef) {
      Repeat(.digit, count: 3)
    } transform: {
      .init($0)! * 100
    }
    Capture(as: depthRef) {
      .digit
    } transform: {
      .init($0)! * 1000
    }
    Anchor.wordBoundary
  }

  func parse(_ parts: inout [String.SubSequence]) throws -> Turbulence? {
    guard !parts.isEmpty else { return nil }
    let turbStr = String(parts[0])
    guard let result = try rx.wholeMatch(in: turbStr) else { return nil }
    parts.removeFirst()

    let type = result[typeRef]
    let base = result[baseRef]
    let depth = result[depthRef]

    var intensity = Turbulence.Intensity.none
    var location: Turbulence.Location?
    var frequency: Turbulence.Frequency?
    switch type {
      case "0":
        break
      case "1":
        intensity = .light
      case "2":
        intensity = .moderate
        location = .clearAir
        frequency = .occasional
      case "3":
        intensity = .moderate
        location = .clearAir
        frequency = .frequent
      case "4":
        intensity = .moderate
        location = .inCloud
        frequency = .occasional
      case "5":
        intensity = .moderate
        location = .inCloud
        frequency = .frequent
      case "6":
        intensity = .severe
        location = .clearAir
        frequency = .occasional
      case "7":
        intensity = .severe
        location = .clearAir
        frequency = .frequent
      case "8":
        intensity = .severe
        location = .inCloud
        frequency = .occasional
      case "9":
        intensity = .severe
        location = .inCloud
        frequency = .frequent
      case "X":
        intensity = .extreme
      default:
        throw Error.invalidTurbulence(turbStr)
    }

    return Turbulence(
      location: location,
      intensity: intensity,
      frequency: frequency,
      base: base,
      depth: depth
    )
  }
}
