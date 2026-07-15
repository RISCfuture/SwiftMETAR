import Foundation
import RegexBuilder

final class LastParser: RemarkParser, @unchecked Sendable {
  private static let rx = LockedRegex(
    Regex {
      Anchor.wordBoundary
      "LAST"
      Anchor.wordBoundary
    }
  )

  var urgency = Remark.Urgency.routine

  func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
    guard let result = try Self.rx.firstMatch(in: remarks) else { return nil }

    remarks.removeSubrange(result.range)
    return .last
  }
}
