import Foundation
import RegexBuilder

final class LightningParser: RemarkParser, @unchecked Sendable {
  var urgency = Remark.Urgency.urgent

  private let directionsParser = RemarkDirectionsParser()
  private let frequencyRef = Reference<Remark.Frequency?>()
  private let typesRef = Reference<Substring?>()
  private let proximityRef = Reference<Remark.Proximity?>()

  private lazy var rx = LockedRegex(
    Regex {
      Anchor.wordBoundary
      Optionally {
        Capture(as: frequencyRef) {
          Remark.Frequency.rx
        } transform: {
          .init(rawValue: String($0))
        }
        " "
      }
      "LTG"
      Optionally {
        Capture(as: typesRef) {
          OneOrMore { Remark.LightningType.rx }
        } transform: {
          $0
        }
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

    let frequency = result[frequencyRef]
    let typesStr = result[typesRef]
    let proximity = result[proximityRef]
    let directions = directionsParser.parse(result)

    var types = Set<Remark.LightningType>()
    if let typesStr {
      if !typesStr.isEmpty {
        for typeStr in String(typesStr).partition(by: 2) {
          guard let type = Remark.LightningType(rawValue: typeStr) else { return nil }
          types.insert(type)
        }
      }
    }

    remarks.removeSubrange(result.range)
    return .lightning(
      frequency: frequency,
      types: types,
      proximity: proximity,
      directions: directions ?? Set()
    )
  }
}
