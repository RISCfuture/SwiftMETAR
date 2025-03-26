import Foundation
@preconcurrency import RegexBuilder

class AltimeterParser {
    private let unitRef = Reference<Substring>()
    private let valueRef = Reference<UInt16>()

    private lazy var METARAltRx = Regex {
        Anchor.startOfSubject
        Capture(as: unitRef) { CharacterClass.anyOf("AQ") }
        Capture(as: valueRef) { Repeat(.digit, count: 4) } transform: { .init($0)! }
        Anchor.endOfSubject
    }

    private lazy var TAFAltRx = Regex {
        Anchor.startOfSubject
        "QNH"
        Capture(as: valueRef) { Repeat(.digit, count: 4) } transform: { .init($0)! }
        Capture(as: unitRef) {
            ChoiceOf {
                "INS"
                "HPA"
            }
        }
    }

    func parseMETAR(_ parts: inout [String.SubSequence]) throws -> Altimeter? {
        guard !parts.isEmpty else { return nil }

        let altStr = String(parts[0])
        guard let match = try METARAltRx.wholeMatch(in: altStr) else { return nil }
        parts.removeFirst()

        let value = match[valueRef]

        switch match[unitRef] {
            case "A": return .inHg(value)
            case "Q": return .hPa(value)
            default: throw Error.invalidAltimeter(String(altStr))
        }
    }

    func parseTAF(_ parts: inout [String.SubSequence]) throws -> Altimeter? {
        guard !parts.isEmpty else { return nil }

        let altStr = String(parts[0])
        guard let match = try TAFAltRx.wholeMatch(in: altStr) else {
            return nil
        }
        parts.removeFirst()

        let value = match[valueRef]

        switch match[unitRef] {
            case "INS": return .inHg(value)
            case "HPA": return .hPa(value)
            default: throw Error.invalidAltimeter(String(altStr))
        }
    }
}
