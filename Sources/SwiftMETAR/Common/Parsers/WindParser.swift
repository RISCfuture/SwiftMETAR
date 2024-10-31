import Foundation
@preconcurrency import RegexBuilder

class WindParser {
    enum DirectionString {
        case variable
        case heading(_ value: UInt16)
    }

    let directionRef = Reference<DirectionString>()
    let direction1Ref = Reference<UInt16?>()
    let direction2Ref = Reference<UInt16?>()
    let speedRef = Reference<UInt16>()
    let gustRef = Reference<UInt16?>()
    let unitRef = Reference<Substring>()

    lazy var noAnchorRx = Regex {
        Capture(as: directionRef) {
            ChoiceOf {
                Repeat(.digit, count: 3)
                "VRB"
            }
        } transform: { value in
            switch value {
                case "VRB": return .variable
                default: return .heading(UInt16(value)!)
            }
        }
        Capture(as: speedRef) { Repeat(.digit, 2...3) } transform: { UInt16($0)! }
        Optionally {
            "G"
            Capture(as: gustRef) { Repeat(.digit, 2...3) } transform: { UInt16($0) }
        }
        Capture(as: unitRef) {
            ChoiceOf {
                "KTS"
                "KT"
                "MPS"
                "KPH"
            }
        }
    }
    private lazy var rx = Regex {
        Anchor.startOfSubject
        noAnchorRx
        Anchor.endOfSubject
    }
    private lazy var variableRx = Regex {
        Anchor.startOfSubject
        Capture(as: direction1Ref) { Repeat(.digit, count: 3) } transform: { UInt16($0) }
        "V"
        Capture(as: direction2Ref) { Repeat(.digit, count: 3) } transform: { UInt16($0) }
        Anchor.endOfSubject
    }

    func parse(_ parts: inout Array<String.SubSequence>) throws -> Wind? {
        guard !parts.isEmpty else { return nil }
        let dirAndSpeed = String(parts[0])

        if dirAndSpeed == "00000KT" {
            parts.removeFirst()
            return .calm
        }

        guard let match = try rx.wholeMatch(in: dirAndSpeed) else { return nil }
        parts.removeFirst()

        let speedValue = match[speedRef]
        let speed: Wind.Speed = switch match[unitRef] {
            case "KT", "KTS": .knots(speedValue)
            case "KPH": .kph(speedValue)
            case "MPS": .mps(speedValue)
            default: throw Error.invalidWinds(dirAndSpeed)
        }

        switch match[directionRef] {
            case .variable:
                guard let rangeSeq = parts.first else {
                    return .variable(speed: speed)
                }
                let range = try parseDirectionRange(&parts, rangeSeq: rangeSeq)
                return .variable(speed: speed, headingRange: range)
            case let .heading(heading):
                let gustValue = match[gustRef]
                var gust: Wind.Speed? = nil
                if let gustValue {
                    gust = switch match[unitRef] {
                        case "KT", "KTS": .knots(gustValue)
                        case "KPH": .kph(gustValue)
                        case "MPS": .mps(gustValue)
                        default: throw Error.invalidWinds(dirAndSpeed)
                    }
                }

                guard let rangeSeq = parts.first else {
                    return .direction(heading, speed: speed, gust: gust)
                }

                if let range = try parseDirectionRange(&parts, rangeSeq: rangeSeq) {
                    return .directionRange(heading, headingRange: range, speed: speed, gust: gust)
                } else {
                    return .direction(heading, speed: speed, gust: gust)
                }
        }
    }

    func parse<T>(match: Regex<T>.Match, originalString: String) throws -> Wind {
        let speedValue = match[speedRef]
        let speed: Wind.Speed = switch match[unitRef] {
            case "KT", "KTS": .knots(speedValue)
            case "KPH": .kph(speedValue)
            case "MPS": .mps(speedValue)
            default: throw Error.invalidWinds(originalString)
        }

        switch match[directionRef] {
            case .variable:
                return .variable(speed: speed)
            case let .heading(heading):
                let gustValue = match[gustRef]
                var gust: Wind.Speed? = nil
                if let gustValue {
                    gust = switch match[unitRef] {
                        case "KT", "KTS": .knots(gustValue)
                        case "KPH": .kph(gustValue)
                        case "MPS": .mps(gustValue)
                        default: throw Error.invalidWinds(originalString)
                    }
                }

                return .direction(heading, speed: speed, gust: gust)
        }
    }

    fileprivate func parseDirectionRange(_ parts: inout Array<String.SubSequence>, rangeSeq: String.SubSequence) throws -> (UInt16, UInt16)? {
        let rangeStr = String(rangeSeq)

        guard let variableMatch = try variableRx.wholeMatch(in: rangeStr),
              let dir1 = variableMatch[direction1Ref],
              let dir2 = variableMatch[direction2Ref] else { return nil }

        parts.removeFirst()
        return (dir1, dir2)
    }
}
