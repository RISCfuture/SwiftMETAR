import Foundation
@preconcurrency import RegexBuilder

private let nocapExtremesRegex = Remark.Extreme.allCases.map(\.rawValue).joined(separator: "|")

final class WindChangeParser: RemarkParser {
  var urgency = Remark.Urgency.routine

  private let windParser = WindParser()
  private let timeParser = DayHourParser()
  private lazy var rx = Regex {
    Anchor.wordBoundary
    "WND "
    windParser.noAnchorRx
    " AFT "
    timeParser.rx
    Anchor.wordBoundary
  }

  func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }
    let originalString = String(remarks[result.range])
    let wind = try windParser.parse(match: result, originalString: originalString)
    let after = try timeParser.parse(match: result, originalString: originalString)

    remarks.removeSubrange(result.range)
    return .windChange(wind: wind, after: after)
  }
}
