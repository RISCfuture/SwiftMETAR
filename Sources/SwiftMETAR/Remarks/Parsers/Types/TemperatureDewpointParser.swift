import Foundation
@preconcurrency import RegexBuilder

final class TemperatureDewpointParser: RemarkParser {
  private static let indeterminate = "////"

  var urgency = Remark.Urgency.routine

  private let temperatureParser = NumericSignedIntegerParser(width: 3)
  private let dewpointParser = NumericSignedIntegerParser(width: 3)
  private let dewpointRef = Reference<Substring>()
  private lazy var rx = Regex {
    Anchor.wordBoundary
    "T"
    temperatureParser.rx
    Capture(as: dewpointRef) {
      Optionally {
        ChoiceOf {
          Regex {
            dewpointParser.rx
            Anchor.wordBoundary
          }
          Self.indeterminate
        }
      }
    }
  }

  func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
    guard let result = try rx.firstMatch(in: remarks),
      let temperature = temperatureParser.parse(result)
    else { return nil }
    let dewpointStr = result[dewpointRef]
    let dewpoint = dewpointStr == Self.indeterminate ? nil : dewpointParser.parse(result)

    remarks.removeSubrange(result.range)
    return .temperatureDewpoint(
      temperature: Float(temperature) / 10.0,
      dewpoint: dewpoint != nil ? Float(dewpoint!) / 10.0 : nil
    )
  }
}
