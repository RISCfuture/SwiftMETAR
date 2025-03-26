import Foundation
import SwiftMETAR

public extension Remark.ObservationType {
    /// Formatter for `Remark.ObservationType`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: Remark.ObservationType) -> String {
            switch value {
                case .automated: String(localized: "automated observation station", comment: "remark")
                case .automatedWithPrecipitation: String(localized: "automated observation station with precipitation recording", comment: "remark")
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == Remark.ObservationType.FormatStyle {
    static var observationType: Self { .init() }
}
// swiftlint:enable missing_docs
