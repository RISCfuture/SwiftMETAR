import Foundation
@preconcurrency import RegexBuilder

class RVRParser {
    private let runwayRef = Reference<Substring>()
    private let signRef = Reference<Character?>()
    private let sign1Ref = Reference<Character?>()
    private let sign2Ref = Reference<Character?>()
    private let distanceRef = Reference<UInt16>()
    private let distance1Ref = Reference<UInt16>()
    private let distance2Ref = Reference<UInt16>()
    private let unitRef = Reference<Substring>()

    private lazy var runwayRx = Regex {
        "R"
        Capture(as: runwayRef) {
            OneOrMore { CharacterClass("A"..."Z", "0"..."9") }
        }
    }
    private lazy var visRx = Regex {
        Anchor.startOfSubject
        runwayRx
        "/"
        Capture(as: signRef) {
            Optionally {
                ChoiceOf {
                    "M"
                    "P"
                }
            }
        } transform: { $0.first }
        Capture(as: distanceRef) { Repeat(.digit, 1...4) } transform: { .init($0)! }
        Capture(as: unitRef) {
            ChoiceOf {
                "FT"
                "M"
            }
        }
        Anchor.endOfSubject
    }
    private lazy var variableRx = Regex {
        Anchor.startOfSubject
        runwayRx
        "/"
        Capture(as: sign1Ref) {
            Optionally {
                ChoiceOf {
                    "M"
                    "P"
                }
            }
        } transform: { $0.first }
        Capture(as: distance1Ref) { Repeat(.digit, 1...4) } transform: { .init($0)! }
        "V"
        Capture(as: sign2Ref) {
            Optionally {
                ChoiceOf {
                    "M"
                    "P"
                }
            }
        } transform: { $0.first }
        Capture(as: distance2Ref) { Repeat(.digit, 1...4) } transform: { .init($0)! }
        Capture(as: unitRef) {
            ChoiceOf {
                "FT"
                "M"
            }
        }
        Anchor.endOfSubject
    }

    func parse(_ parts: inout [String.SubSequence]) throws -> [RunwayVisibility] {
        var visibilities = [RunwayVisibility]()

        while true {
            if parts.isEmpty { return visibilities }

            if let match = try visRx.wholeMatch(in: parts[0]) {
                parts.removeFirst()

                let runway = match[runwayRef],
                    bound = match[signRef],
                    quantity = match[distanceRef],
                    units = match[unitRef]

                let value = visibilityValue(quantity, bound: bound, units: units)
                visibilities.append(RunwayVisibility(runwayID: String(runway), visibility: value))
            } else if let match = try variableRx.wholeMatch(in: parts[0]) {
                parts.removeFirst()

                let runway = match[runwayRef],
                    lowBound = match[sign1Ref],
                    lowQuantity = match[distance1Ref],
                    highBound = match[sign2Ref],
                    highQuantity = match[distance2Ref],
                    units = match[unitRef]

                let low = visibilityValue(lowQuantity, bound: lowBound, units: units)
                let high = visibilityValue(highQuantity, bound: highBound, units: units)
                visibilities.append(RunwayVisibility(runwayID: String(runway), visibility: .variable(low, high)))
            } else { return visibilities }
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
