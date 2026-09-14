import Foundation
import RegexBuilder

final class SixHourTemperatureExtremeParser: RemarkParser, @unchecked Sendable {
  var urgency = Remark.Urgency.routine

  private let extremesRef = Reference<Remark.Extreme>()
  private let temperatureParser = NumericSignedIntegerParser(width: 3)

  private lazy var rx = LockedRegex(
    Regex {
      Anchor.wordBoundary
      Capture(as: extremesRef) {
        Remark.Extreme.rx
      } transform: {
        .init(rawValue: String($0))!
      }
      temperatureParser.rx
      Anchor.wordBoundary
    }
  )

  func parse(remarks: inout String, date _: DateComponents) throws(Error) -> Remark? {
    guard let result = try rx.firstMatch(in: remarks),
      let temperature = temperatureParser.parse(result)
    else { return nil }
    let type = result[extremesRef]

    remarks.removeSubrange(result.range)
    return .sixHourTemperatureExtreme(type: type, temperature: Float(temperature) / 10.0)
  }
}
