import Foundation
import SwiftMETAR

public extension METAR.Issuance {
    
    /// Formatter for `METAR.Issuance`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: METAR.Issuance) -> String {
            switch value {
                case .routine: String(localized: "routine", comment: "METAR issuance")
                case .special: String(localized: "special", comment: "METAR issuance")
            }
        }
    }
}

public extension FormatStyle where Self == METAR.Issuance.FormatStyle {
    static var issuance: Self { .init() }
}
