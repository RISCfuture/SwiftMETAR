import Foundation
@preconcurrency import RegexBuilder

final class SensorStatusParser: RemarkParser {
  var urgency = Remark.Urgency.caution

  private let sensorRef = Reference<Sensor?>()
  private let secondarySensorRef = Reference<SecondarySensor?>()
  private let locationRef = Reference<Substring?>()

  // swiftlint:disable force_try
  private lazy var rx = Regex {
    Anchor.wordBoundary
    ChoiceOf {
      Capture(as: sensorRef) {
        try! Sensor.rx
      } transform: {
        .init(rawValue: String($0))
      }
      Regex {
        Capture(as: secondarySensorRef) {
          try! SecondarySensor.rx
        } transform: {
          .init(rawValue: String($0))
        }
        " "
        Capture(as: locationRef) {
          OneOrMore(.word)
        } transform: {
          $0
        }
      }
    }
    Anchor.wordBoundary
  }
  // swiftlint:enable force_try

  func parse(remarks: inout String, date _: DateComponents) throws -> Remark? {
    guard let result = try rx.firstMatch(in: remarks) else { return nil }
    let sensor = result[sensorRef]
    let secondarySensor = result[secondarySensorRef]
    let location = result[locationRef]

    if let sensor {
      let type: Remark.SensorType =
        switch sensor {
          case .RVR: .RVR
          case .presentWeather: .presentWeather
          case .rain: .rain
          case .freezingRain: .freezingRain
          case .lightning: .lightning
        }

      remarks.removeSubrange(result.range)
      return .inoperativeSensor(type)
    }
    if let secondarySensor {
      guard let location else { return nil }
      let type: Remark.SensorType =
        switch secondarySensor {
          case .visibility: .secondaryVisibility(location: String(location))
          case .ceiling: .secondaryCeiling(location: String(location))
        }

      remarks.removeSubrange(result.range)
      return .inoperativeSensor(type)
    }
    return nil
  }

  private enum Sensor: String, RegexCases {
    case RVR = "RVRNO"
    case presentWeather = "PWINO"
    case rain = "PNO"
    case freezingRain = "FZRANO"
    case lightning = "TSNO"
  }

  private enum SecondarySensor: String, RegexCases {
    case visibility = "VISNO"
    case ceiling = "CHINO"
  }
}
