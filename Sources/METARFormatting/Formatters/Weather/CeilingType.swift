import Foundation
import SwiftMETAR

public extension Condition.CeilingType {

    /// Formatter for `Condition.CeilingType`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: Condition.CeilingType) -> String {
            switch value {
                case .cumulonimbus: String(localized: "cumulonimbus", comment: "ceiling type")
                case .toweringCumulus: String(localized: "towering cumulonimbus", comment: "ceiling type")
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == Condition.CeilingType.FormatStyle {
    static var ceiling: Self { .init() }
}
// swiftlint:enable missing_docs
