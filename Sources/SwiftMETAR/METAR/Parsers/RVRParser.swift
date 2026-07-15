import Foundation
import RegexBuilder

final class RVRParser: WarmableParser, @unchecked Sendable {
  private static let runwayRef = Reference<Substring>()
  private static let signRef = Reference<Character?>()
  private static let sign1Ref = Reference<Character?>()
  private static let sign2Ref = Reference<Character?>()
  private static let distanceRef = Reference<UInt16>()
  private static let distance1Ref = Reference<UInt16>()
  private static let distance2Ref = Reference<UInt16>()
  private static let unitRef = Reference<Substring>()

  private static let runwayRx = Regex {
    "R"
    Capture(as: RVRParser.runwayRef) {
      OneOrMore { CharacterClass("A"..."Z", "0"..."9") }
    }
  }
  private static let visRx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      RVRParser.runwayRx
      "/"
      Capture(as: RVRParser.signRef) {
        Optionally {
          ChoiceOf {
            "M"
            "P"
          }
        }
      } transform: {
        $0.first
      }
      Capture(as: RVRParser.distanceRef) {
        Repeat(.digit, 1...4)
      } transform: {
        .init($0)!
      }
      Capture(as: RVRParser.unitRef) {
        ChoiceOf {
          "FT"
          "M"
        }
      }
      Anchor.endOfSubject
    }
  )
  private static let variableRx = LockedRegex(
    Regex {
      Anchor.startOfSubject
      RVRParser.runwayRx
      "/"
      Capture(as: RVRParser.sign1Ref) {
        Optionally {
          ChoiceOf {
            "M"
            "P"
          }
        }
      } transform: {
        $0.first
      }
      Capture(as: RVRParser.distance1Ref) {
        Repeat(.digit, 1...4)
      } transform: {
        .init($0)!
      }
      "V"
      Capture(as: RVRParser.sign2Ref) {
        Optionally {
          ChoiceOf {
            "M"
            "P"
          }
        }
      } transform: {
        $0.first
      }
      Capture(as: RVRParser.distance2Ref) {
        Repeat(.digit, 1...4)
      } transform: {
        .init($0)!
      }
      Capture(as: RVRParser.unitRef) {
        ChoiceOf {
          "FT"
          "M"
        }
      }
      Anchor.endOfSubject
    }
  )

  func parse(_ parts: inout [String.SubSequence]) throws -> [RunwayVisibility] {
    var visibilities = [RunwayVisibility]()

    while true {
      if parts.isEmpty { return visibilities }

      if let match = try Self.visRx.wholeMatch(in: parts[0]) {
        parts.removeFirst()

        let runway = match[Self.runwayRef]
        let bound = match[Self.signRef]
        let quantity = match[Self.distanceRef]
        let units = match[Self.unitRef]

        let value = visibilityValue(quantity, bound: bound, units: units)
        visibilities.append(RunwayVisibility(runwayID: String(runway), visibility: value))
      } else if let match = try Self.variableRx.wholeMatch(in: parts[0]) {
        parts.removeFirst()

        let runway = match[Self.runwayRef]
        let lowBound = match[Self.sign1Ref]
        let lowQuantity = match[Self.distance1Ref]
        let highBound = match[Self.sign2Ref]
        let highQuantity = match[Self.distance2Ref]
        let units = match[Self.unitRef]

        let low = visibilityValue(lowQuantity, bound: lowBound, units: units)
        let high = visibilityValue(highQuantity, bound: highBound, units: units)
        visibilities.append(
          RunwayVisibility(runwayID: String(runway), visibility: .variable(low, high))
        )
      } else {
        return visibilities
      }
    }
  }

  private func visibilityValue(_ value: UInt16, bound: Character?, units: Substring) -> Visibility {
    switch bound {
      case "M":
        switch units {
          case "M":
            return .lessThan(.meters(value))
          case "FT":
            return .lessThan(.feet(value))
          default: preconditionFailure("Unknown units")
        }
      case "P":
        switch units {
          case "M":
            return .greaterThan(.meters(value))
          case "FT":
            return .greaterThan(.feet(value))
          default: preconditionFailure("Unknown units")
        }
      case .none:
        switch units {
          case "M":
            return .equal(.meters(value))
          case "FT":
            return .equal(.feet(value))
          default: preconditionFailure("Unknown units")
        }
      default: preconditionFailure("Unknown bounds")
    }
  }
}
