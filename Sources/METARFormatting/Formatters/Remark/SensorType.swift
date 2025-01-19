import Foundation
import SwiftMETAR

public extension Remark.SensorType {
    
    /// Formatter for `Remark.SensorType`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: Remark.SensorType) -> String {
            switch value {
                case .RVR: String(localized: "RVR sensor", comment: "sensor type")
                case .presentWeather: String(localized: "present weather sensor", comment: "sensor type")
                case .rain: String(localized: "rain sensor", comment: "sensor type")
                case .freezingRain: String(localized: "freezing rain sensor", comment: "sensor type")
                case .lightning: String(localized: "lightning sensor", comment: "sensor type")
                case let .secondaryVisibility(location):
                    String(localized: "\(location) visibility sensor", comment: "sensor type")
                case let .secondaryCeiling(location):
                    String(localized: "\(location) ceiling sensor", comment: "sensor type")
            }
        }
    }
}

public extension FormatStyle where Self == Remark.SensorType.FormatStyle {
    static var sensor: Self { .init() }
}
