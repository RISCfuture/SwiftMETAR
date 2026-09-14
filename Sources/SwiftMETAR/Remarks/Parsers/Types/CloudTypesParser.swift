import Foundation
import RegexBuilder

final class CloudTypesParser: RemarkParser, @unchecked Sendable {
  var urgency = Remark.Urgency.routine

  private let lowRef = Reference<Remark.LowCloudType>()
  private let midRef = Reference<Remark.MiddleCloudType>()
  private let highRef = Reference<Remark.HighCloudType>()

  private lazy var rx = LockedRegex(
    Regex {
      Anchor.wordBoundary
      "8/"
      Capture(as: lowRef) {
        Remark.LowCloudType.rx
      } transform: {
        .init(rawValue: String($0))!
      }
      Capture(as: midRef) {
        Remark.MiddleCloudType.rx
      } transform: {
        .init(rawValue: String($0))!
      }
      Capture(as: highRef) {
        Remark.HighCloudType.rx
      } transform: {
        .init(rawValue: String($0))!
      }
    }
  )

  func parse(remarks: inout String, date _: DateComponents) throws(Error) -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }
    let low = result[lowRef]
    let mid = result[midRef]
    let high = result[highRef]

    remarks.removeSubrange(result.range)
    return .cloudTypes(low: low, middle: mid, high: high)
  }
}
