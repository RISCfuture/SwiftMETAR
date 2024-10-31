import Foundation
@preconcurrency import RegexBuilder

final class SectorVisibilityParser: RemarkParser {
    var urgency = Remark.Urgency.routine

    private let directionParser = RemarkDirectionParser()
    private let visibilityParser = FractionParser()

    private lazy var rx = Regex {
        Anchor.wordBoundary
        "VIS "
        directionParser.rx
        " "
        visibilityParser.rx
        Anchor.wordBoundary
    }
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = try rx.firstMatch(in: remarks),
              let direction = directionParser.parse(result) else { return nil }
        let distance = visibilityParser.parse(result)

        remarks.removeSubrange(result.range)
        return .sectorVisibility(direction: direction, distance: distance)
    }
}
