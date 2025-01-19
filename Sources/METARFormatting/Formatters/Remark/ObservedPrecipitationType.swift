import Foundation
import SwiftMETAR

public extension Remark.ObservedPrecipitationType {
    
    /// Formatter for `Remark.ObservedPrecipitationType`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: Remark.ObservedPrecipitationType) -> String {
            switch value {
                case .virga: String(localized: "virga", comment: "precipitation")
                case .showers: String(localized: "showers", comment: "precipitation")
                case .showeringRain: String(localized: "showering rain", comment: "precipitation")
            }
        }
    }
}

public extension FormatStyle where Self == Remark.ObservedPrecipitationType.FormatStyle {
    static var precipitation: Self { .init() }
}
