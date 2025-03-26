import Foundation
import SwiftMETAR

public extension Remark.Frequency {

    /// Formatter for `Remark.Frequency`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: Remark.Frequency) -> String {
            switch value {
                case .occasional: String(localized: "occasional", comment: "lightning frequency")
                case .frequent: String(localized: "frequent", comment: "lightning frequency")
                case .constant: String(localized: "constant", comment: "lightning frequency")
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == Remark.Frequency.FormatStyle {
    static var frequency: Self { .init() }
}
// swiftlint:enable missing_docs
