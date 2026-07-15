import Foundation
import RegexBuilder

final class IcingParser: WarmableParser, @unchecked Sendable {
  private static let typeRef = Reference<Icing.IcingType?>()
  private static let baseRef = Reference<UInt>()
  private static let depthRef = Reference<UInt>()

  private static let rx = LockedRegex(
    Regex {
      Anchor.wordBoundary
      "6"
      Capture(as: typeRef) {
        .digit
      } transform: {
        .init(rawValue: String($0))
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
  )

  func parse(_ parts: inout [String.SubSequence]) throws -> Icing? {
    guard !parts.isEmpty else { return nil }
    let icingStr = String(parts[0])
    guard let result = try Self.rx.wholeMatch(in: icingStr) else { return nil }
    parts.removeFirst()

    guard let type = result[Self.typeRef] else { throw Error.invalidIcing(icingStr) }
    let base = result[Self.baseRef]
    let depth = result[Self.depthRef]

    return Icing(type: type, base: base, depth: depth)
  }
}
