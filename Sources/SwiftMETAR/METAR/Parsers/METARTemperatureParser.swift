import Foundation
@preconcurrency import RegexBuilder

class METARTemperatureParser {
    private let tempParser = AlphaSignedIntegerParser(width: 2)
    private let dewpointParser = AlphaSignedIntegerParser(width: 2)

    private lazy var rx = Regex {
        Anchor.startOfSubject
        tempParser.rx
        "/"
        Optionally { dewpointParser.rx }
    }

    func parse(_ parts: inout Array<String.SubSequence>) throws -> (Int8?, Int8?) {
        if parts.isEmpty { return (nil, nil) }
        let tempStr = String(parts[0])

        if let match = try rx.wholeMatch(in: tempStr) {
            guard let temp = tempParser.parse(match) else { return (nil, nil) }
            let dp = dewpointParser.parse(match)

            parts.removeFirst()
            return (temp, dp)
        }

        return (nil, nil)
    }
}
