import Foundation
import RegexBuilder

final class ConditionsParser: WarmableParser, @unchecked Sendable {
  private static let coverageRef = Reference<Coverage>()
  private static let heightRef = Reference<UInt>()
  private static let ceilingTypeRef = Reference<Condition.CeilingType?>()
  // swiftlint:disable force_try
  private static let rx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      Capture(as: coverageRef) {
        try! Coverage.rx
      } transform: {
        .init(rawValue: String($0))!
      }
      Capture(as: heightRef) {
        Repeat(.digit, count: 3)
      } transform: {
        .init($0)! * 100
      }
      Capture(as: ceilingTypeRef) {
        Optionally(try! Condition.CeilingType.rx)
      } transform: {
        .init(rawValue: String($0))
      }
      Anchor.endOfSubject
    }
  )
  // swiftlint:enable force_try

  func parse(_ parts: inout [String.SubSequence]) throws -> [Condition] {
    if parts.isEmpty { return [] }

    var conditions = [Condition]()

    while true {
      if parts.isEmpty { return conditions }
      let condStr = String(parts[0])

      switch condStr {
        case "SKC":
          parts.removeFirst()
          return [.skyClear]
        case "CLR", "NCD":
          parts.removeFirst()
          return [.clear]
        case "NSC":
          parts.removeFirst()
          return [.noSignificantClouds]
        default:
          break
      }

      if let match = try Self.rx.wholeMatch(in: condStr) {
        parts.removeFirst()

        let coverage = match[Self.coverageRef]
        let height = match[Self.heightRef]
        let type = match[Self.ceilingTypeRef]

        if type != nil {
          guard coverage != .verticalVis else { throw Error.invalidConditions(condStr) }
        }

        switch coverage {
          case .few: conditions.append(.few(height, type: type))
          case .scattered: conditions.append(.scattered(height, type: type))
          case .broken: conditions.append(.broken(height, type: type))
          case .overcast: conditions.append(.overcast(height, type: type))
          case .verticalVis: conditions.append(.indefinite(height))
        }
      } else {
        return conditions
      }
    }
  }

  private enum Coverage: String, RegexCases {
    case few = "FEW"
    case scattered = "SCT"
    case broken = "BKN"
    case overcast = "OVC"
    case verticalVis = "VV"
  }
}
