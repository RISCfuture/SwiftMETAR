import Foundation
import RegexBuilder

final class NavalForecasterParser: RemarkParser, @unchecked Sendable {
  var urgency = Remark.Urgency.routine

  private let centerRef = Reference<Remark.NavalWeatherCenter>()
  private let forecasterRef = Reference<UInt>()

  private lazy var rx = LockedRegex(
    Regex {
      Anchor.wordBoundary
      "F"
      Capture(as: centerRef) {
        Remark.NavalWeatherCenter.rx
      } transform: {
        .init(rawValue: String($0))!
      }
      Capture(as: forecasterRef) {
        OneOrMore(.digit)
      } transform: {
        .init($0)!
      }
      Anchor.wordBoundary
    }
  )

  func parse(remarks: inout String, date _: DateComponents) throws(Error) -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }
    let center = result[centerRef]
    let forecaster = result[forecasterRef]

    remarks.removeSubrange(result.range)
    return .navalForecaster(center: center, ID: forecaster)
  }
}
