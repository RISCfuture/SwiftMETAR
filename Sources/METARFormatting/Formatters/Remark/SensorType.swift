import Foundation
import SwiftMETAR

extension Remark.SensorType {

  /// Formatter for `Remark.SensorType`
  public struct FormatStyle: Foundation.FormatStyle, Sendable {
    public func format(_ value: Remark.SensorType) -> String {
      switch value {
        case .RVR: String(localized: "RVR sensor", comment: "sensor type")
        case .presentWeather: String(localized: "present weather sensor", comment: "sensor type")
        case .rain: String(localized: "rain sensor", comment: "sensor type")
        case .freezingRain: String(localized: "freezing rain sensor", comment: "sensor type")
        case .lightning: String(localized: "lightning sensor", comment: "sensor type")
        case .secondaryVisibility(let location):
          String(localized: "\(location) visibility sensor", comment: "sensor type")
        case .secondaryCeiling(let location):
          String(localized: "\(location) ceiling sensor", comment: "sensor type")
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Remark.SensorType.FormatStyle {
  public static var sensor: Self { .init() }
}
// swiftlint:enable missing_docs
