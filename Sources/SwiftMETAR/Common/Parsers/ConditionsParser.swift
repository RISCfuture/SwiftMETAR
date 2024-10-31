import Foundation
@preconcurrency import RegexBuilder

class ConditionsParser {
    private enum Coverage: String, RegexCases {
        case few = "FEW"
        case scattered = "SCT"
        case broken = "BKN"
        case overcast = "OVC"
        case verticalVis = "VV"
    }

    private let coverageRef = Reference<Coverage>()
    private let heightRef = Reference<UInt>()
    private let ceilingTypeRef = Reference<Condition.CeilingType?>()
    private lazy var rx = Regex {
        Anchor.startOfSubject
        Capture(as: coverageRef) { try! Coverage.rx } transform: { .init(rawValue: String($0))! }
        Capture(as: heightRef) { Repeat(.digit, count: 3) } transform: { UInt($0)! * 100 }
        Capture(as: ceilingTypeRef) {
            Optionally(try! Condition.CeilingType.rx)
        } transform: { .init(rawValue: String($0)) }
        Anchor.endOfSubject
    }

    func parse(_ parts: inout Array<String.SubSequence>) throws -> Array<Condition> {
        if parts.isEmpty { return [] }

        var conditions = Array<Condition>()

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

            if let match = try rx.wholeMatch(in: condStr) {
                parts.removeFirst()

                let coverage = match[coverageRef],
                    height = match[heightRef],
                    type = match[ceilingTypeRef]

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
            }
            else { return conditions }
        }
    }
}
