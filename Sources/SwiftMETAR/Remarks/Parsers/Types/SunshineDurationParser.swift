import Foundation
@preconcurrency import RegexBuilder

final class SunshineDurationParser: RemarkParser {
  var urgency = Remark.Urgency.routine

  private let durationRef = Reference<UInt>()
  private lazy var rx = Regex {
    Anchor.wordBoundary
    "98"
    Capture(as: durationRef) {
      Repeat(.digit, count: 3)
    } transform: {
      .init($0)!
    }
    Anchor.wordBoundary
  }

  func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }
    let duration = result[durationRef]

    remarks.removeSubrange(result.range)
    return .sunshineDuration(duration)
  }
}
