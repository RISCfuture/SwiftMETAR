import Foundation
@preconcurrency import RegexBuilder

final class PeakWindsParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let directionRef = Reference<UInt16>()
    private let speedRef = Reference<UInt16>()
    private let timeParser = HourMinuteParser()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "PK W"
        Optionally("I")
        "ND "
        Capture(as: directionRef) { Repeat(.digit, count: 3) } transform: { UInt16($0)! }
        Capture(as: speedRef) { Repeat(.digit, 2...3) } transform: { UInt16($0)! }
        "/"
        timeParser.hourOptionalRx
        Anchor.wordBoundary
    }

    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks) else { return nil }
        let direction = result[directionRef],
            speed = result[speedRef],
            wind = Wind.direction(direction, speed: .knots(speed)),
            originalString = String(remarks[result.range]),
            referenceDate = zuluCal.date(from: date),
            time = try timeParser.parse(match: result, referenceDate: referenceDate, originalString: originalString)

        remarks.removeSubrange(result.range)
        return .peakWinds(wind, time: time)
    }
}
