import Foundation
import RegexBuilder

final class WindChangeParser: RemarkParser, @unchecked Sendable {
  var urgency = Remark.Urgency.routine

  private let timeParser = DayHourParser()
  private lazy var rx = LockedRegex(
    Regex {
      Anchor.wordBoundary
      "WND "
      WindParser.noAnchorRx
      " AFT "
      timeParser.rx
      Anchor.wordBoundary
    }
  )

  func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }
    let originalString = String(remarks[result.range])
    let wind = try WindParser.parse(match: result, originalString: originalString)
    let after = try timeParser.parse(match: result, originalString: originalString)

    remarks.removeSubrange(result.range)
    return .windChange(wind: wind, after: after)
  }
}
