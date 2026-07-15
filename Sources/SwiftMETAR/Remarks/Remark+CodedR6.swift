import Foundation

extension Remark {

  static func coded(cloudTypesLow low: LowCloudType, middle: MiddleCloudType, high: HighCloudType)
    -> String
  {
    "8/\(low.rawValue)\(middle.rawValue)\(high.rawValue)"
  }

  static func coded(observationType type: ObservationType, augmented: Bool) -> String {
    "\(type.rawValue)\(augmented ? "A" : "")"
  }

  static func coded(inoperativeSensor type: SensorType) -> String {
    switch type {
      case .RVR: "RVRNO"
      case .presentWeather: "PWINO"
      case .rain: "PNO"
      case .freezingRain: "FZRANO"
      case .lightning: "TSNO"
      case let .secondaryVisibility(location): "VISNO \(location)"
      case let .secondaryCeiling(location): "CHINO \(location)"
    }
  }

  static func coded(sunshineDuration duration: UInt) -> String {
    "98\(String(format: "%03d", duration))"
  }

  static func coded(navalForecasterCenter center: NavalWeatherCenter, ID: UInt) -> String {
    "F\(center.rawValue)\(ID)"
  }
}
