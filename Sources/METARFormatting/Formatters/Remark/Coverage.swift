import Foundation
import SwiftMETAR

public extension Remark.Coverage {

    /// Formatter for `Remark.Coverage`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: Remark.Coverage) -> String {
            switch value {
                case .few: String(localized: "few", comment: "coverage")
                case .scattered: String(localized: "scattered", comment: "coverage")
                case .broken: String(localized: "broken", comment: "coverage")
                case .overcast: String(localized: "overcast", comment: "coverage")
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == Remark.Coverage.FormatStyle {
    static var coverage: Self { .init() }
}
// swiftlint:enable missing_docs
