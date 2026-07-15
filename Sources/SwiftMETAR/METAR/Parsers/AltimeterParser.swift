import Foundation
import RegexBuilder

final class AltimeterParser: WarmableParser, @unchecked Sendable {
  private static let unitRef = Reference<Substring>()
  private static let valueRef = Reference<UInt16>()

  private static let METARAltRx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      Capture(as: unitRef) { CharacterClass.anyOf("AQ") }
      Capture(as: valueRef) {
        Repeat(.digit, count: 4)
      } transform: {
        .init($0)!
      }
      Anchor.endOfSubject
    }
  )

  private static let TAFAltRx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      "QNH"
      Capture(as: valueRef) {
        Repeat(.digit, count: 4)
      } transform: {
        .init($0)!
      }
      Capture(as: unitRef) {
        ChoiceOf {
          "INS"
          "HPA"
        }
      }
    }
  )

  func parseMETAR(_ parts: inout [String.SubSequence]) throws -> Altimeter? {
    guard !parts.isEmpty else { return nil }

    let altStr = String(parts[0])
    guard let match = try Self.METARAltRx.wholeMatch(in: altStr) else { return nil }
    parts.removeFirst()

    let value = match[Self.valueRef]

    switch match[Self.unitRef] {
      case "A": return .inHg(value)
      case "Q": return .hPa(value)
      default: throw Error.invalidAltimeter(String(altStr))
    }
  }

  func parseTAF(_ parts: inout [String.SubSequence]) throws -> Altimeter? {
    guard !parts.isEmpty else { return nil }

    let altStr = String(parts[0])
    guard let match = try Self.TAFAltRx.wholeMatch(in: altStr) else {
      return nil
    }
    parts.removeFirst()

    let value = match[Self.valueRef]

    switch match[Self.unitRef] {
      case "INS": return .inHg(value)
      case "HPA": return .hPa(value)
      default: throw Error.invalidAltimeter(String(altStr))
    }
  }
}
