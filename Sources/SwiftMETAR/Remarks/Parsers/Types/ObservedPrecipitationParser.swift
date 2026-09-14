import Foundation
import RegexBuilder

final class ObservedPrecipitationParser: RemarkParser, @unchecked Sendable {
  var urgency = Remark.Urgency.routine

  private let precipRef = Reference<Remark.ObservedPrecipitationType>()
  private let proximityRef = Reference<Remark.Proximity?>()
  private let directionsParser = RemarkDirectionsParser()

  private lazy var rx = LockedRegex(
    Regex {
      Anchor.wordBoundary
      Capture(as: precipRef) {
        Remark.ObservedPrecipitationType.rx
      } transform: {
        .init(rawValue: String($0))!
      }
      Optionally {
        " "
        Capture(as: proximityRef) {
          Remark.Proximity.rx
        } transform: {
          .init(rawValue: String($0))
        }
      }
      Optionally {
        " "
        directionsParser.rx
      }
      Anchor.wordBoundary
    }
  )

  func parse(remarks: inout String, date _: DateComponents) throws(Error) -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }

    let precip = result[precipRef]
    let proximity = result[proximityRef]
    let directions = directionsParser.parse(result)

    remarks.removeSubrange(result.range)
    return .observedPrecipitation(
      type: precip,
      proximity: proximity,
      directions: directions ?? Set()
    )
  }
}
