import Foundation
import SwiftMETAR

public extension Weather.Descriptor {
    
    /// Formatter for `Weather.Descriptor`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        
        /// The phenomenon associated with this descriptor. Not printed; only
        /// used to inflect the adjective for languages where this is necessary.
        public var phenomenon: Weather.Phenomenon
        
        public func format(_ value: Weather.Descriptor) -> String {
            switch value {
                case .shallow: String(localized: "shallow", comment: "precipitation descriptor")
                case .partial: String(localized: "partial", comment: "precipitation descriptor")
                case .patchy: String(localized: "patchy", comment: "precipitation descriptor")
                case .lowDrifting: String(localized: "low drifting", comment: "precipitation descriptor")
                case .blowing: String(localized: "blowing", comment: "precipitation descriptor")
                case .showering: String(localized: "showering", comment: "precipitation descriptor")
                case .thunderstorms: String(localized: "thunderstorm-associated", comment: "precipitation descriptor")
                case .freezing: String(localized: "freezing", comment: "precipitation descriptor")
            }
        }
        
        public enum Width: Sendable, Codable {
            case abbreviated, full
        }
    }
}

public extension FormatStyle where Self == Weather.Descriptor.FormatStyle {
    static func descriptor(phenomenon: Weather.Phenomenon) -> Self {
        .init(phenomenon: phenomenon)
    }
}
