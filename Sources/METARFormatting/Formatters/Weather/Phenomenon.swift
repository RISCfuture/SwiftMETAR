import Foundation
import SwiftMETAR

public extension Weather.Phenomenon {
    
    /// Formatter for `Weather.Phenomenon`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: Weather.Phenomenon) -> String {
            switch value {
                case .drizzle: String(localized: "drizzle", comment: "weather phenomenon")
                case .rain: String(localized: "rain", comment: "weather phenomenon")
                case .snow: String(localized: "snow", comment: "weather phenomenon")
                case .snowGrains: String(localized: "snow grains", comment: "weather phenomenon")
                case .iceCrystals: String(localized: "ice crystals", comment: "weather phenomenon")
                case .icePellets: String(localized: "ice pellets", comment: "weather phenomenon")
                case .hail: String(localized: "hail", comment: "weather phenomenon")
                case .snowPellets: String(localized: "snow pellets", comment: "weather phenomenon")
                case .unknownPrecipitation: String(localized: "unknown precipitation", comment: "weather phenomenon")
                case .mist: String(localized: "mist", comment: "weather phenomenon")
                case .fog: String(localized: "fog", comment: "weather phenomenon")
                case .smoke: String(localized: "smoke", comment: "weather phenomenon")
                case .volcanicAsh: String(localized: "volcanic ash", comment: "weather phenomenon")
                case .dust: String(localized: "dust", comment: "weather phenomenon")
                case .sand: String(localized: "sand", comment: "weather phenomenon")
                case .haze: String(localized: "haze", comment: "weather phenomenon")
                case .spray: String(localized: "spray", comment: "weather phenomenon")
                case .dustWhirls: String(localized: "dust whirls", comment: "weather phenomenon")
                case .squalls: String(localized: "squalls", comment: "weather phenomenon")
                case .funnelCloud: String(localized: "funnel cloud", comment: "weather phenomenon")
                case .sandstorm: String(localized: "sandstorm", comment: "weather phenomenon")
                case .dustStorm: String(localized: "dust storm", comment: "weather phenomenon")
                case .thunderstorm: String(localized: "thunderstorms", comment: "weather phenomenon")
            }
        }
    }
}

public extension FormatStyle where Self == Weather.Phenomenon.FormatStyle {
    static var phenomenon: Self { .init() }
}
