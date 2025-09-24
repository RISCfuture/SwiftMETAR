import Foundation
@preconcurrency import RegexBuilder

final class ObservedPrecipitationParser: RemarkParser {
  var urgency = Remark.Urgency.routine

  private let precipRef = Reference<Remark.ObservedPrecipitationType>()
  private let proximityRef = Reference<Remark.Proximity?>()
  private let directionsParser = RemarkDirectionsParser()

  // swiftlint:disable force_try
  private lazy var rx = Regex {
    Anchor.wordBoundary
    Capture(as: precipRef) {
      try! Remark.ObservedPrecipitationType.rx
    } transform: {
      .init(rawValue: String($0))!
    }
    Optionally {
      " "
      Capture(as: proximityRef) {
        try! Remark.Proximity.rx
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
  // swiftlint:enable force_try

  func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
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
