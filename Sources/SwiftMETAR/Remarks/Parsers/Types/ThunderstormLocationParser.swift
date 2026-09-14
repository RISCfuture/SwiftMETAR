import Foundation
import RegexBuilder

final class ThunderstormLocationParser: RemarkParser, @unchecked Sendable {
  var urgency = Remark.Urgency.urgent

  private let proximityRef = Reference<Remark.Proximity?>()
  private let directionsParser = RemarkDirectionsParser()
  private let movingDirectionParser = RemarkDirectionParser()

  private lazy var rx = LockedRegex(
    Regex {
      Anchor.wordBoundary
      "TS"
      Optionally {
        " "
        Capture(as: proximityRef) {
          Remark.Proximity.rx
        } transform: {
          .init(rawValue: String($0))
        }
      }
      Optionally {
        CharacterClass.anyOf(" -")
        directionsParser.rx
      }
      Optionally {
        " MOV"
        Optionally("G")
        " "
        movingDirectionParser.rx
      }
      Anchor.wordBoundary
    }
  )

  func parse(remarks: inout String, date _: DateComponents) throws(Error) -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }
    let proximity = result[proximityRef]
    let directions = directionsParser.parse(result)
    let movingDirection = movingDirectionParser.parse(result)

    remarks.removeSubrange(result.range)
    return .thunderstormLocation(
      proximity: proximity,
      directions: directions ?? Set(),
      movingDirection: movingDirection
    )
  }
}
