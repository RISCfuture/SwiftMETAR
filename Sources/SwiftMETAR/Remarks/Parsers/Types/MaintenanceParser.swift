import Foundation
import RegexBuilder

final class MaintenanceParser: RemarkParser, @unchecked Sendable {
  private static let rx = LockedRegex(
    Regex {
      ChoiceOf {
        Regex {
          OneOrMore(.whitespace)
          "$"
          OneOrMore(.whitespace)
        }
        Regex {
          OneOrMore(.whitespace)
          "$"
          ZeroOrMore(.whitespace)
          Anchor.endOfSubject
        }
      }
    }
  )

  var urgency = Remark.Urgency.routine

  func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
    guard let result = try Self.rx.firstMatch(in: remarks) else { return nil }

    remarks.removeSubrange(result.range)
    return .maintenance
  }
}
