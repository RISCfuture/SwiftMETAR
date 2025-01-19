import Foundation
import SwiftMETAR

public extension Remark.Proximity {
    
    /// Formatter for `Remark.Proximity`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: Remark.Proximity) -> String {
            switch value {
                case .overhead: String(localized: "overhead", comment: "lightning proximity")
                case .vicinity: String(localized: "in the vicinity", comment: "lightning proximity")
                case .distant: String(localized: "distant", comment: "lightning proximity")
            }
        }
    }
}

public extension FormatStyle where Self == Remark.Proximity.FormatStyle {
    static var proximity: Self {
        .init()
    }
}
