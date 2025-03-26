import Foundation
import SwiftMETAR

public extension TAF.Issuance {

    /// Formatter for `TAF.Issuance`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: TAF.Issuance) -> String {
            switch value {
                case .routine: String(localized: "routine", comment: "TAF issuance")
                case .amended: String(localized: "amended", comment: "TAF issuance")
                case .corrected: String(localized: "corrected", comment: "TAF issuance")
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == TAF.Issuance.FormatStyle {
    static var issuance: Self { .init() }
}
// swiftlint:enable missing_docs
