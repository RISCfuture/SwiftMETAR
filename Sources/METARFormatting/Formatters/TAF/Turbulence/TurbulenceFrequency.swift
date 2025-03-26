import BuildableMacro
import Foundation
import SwiftMETAR

public extension Turbulence.Frequency {

    /// Formatter for `Turbulence.Frequency`
    @Buildable
    struct FormatStyle: Foundation.FormatStyle, Sendable {

        public func format(_ value: Turbulence.Frequency) -> String {
            switch value {
                case .occasional: String(localized: "occasional", comment: "turbulence frequency")
                case .frequent: String(localized: "frequent", comment: "turbulence frequency")
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == Turbulence.Frequency.FormatStyle {
    static var frequency: Self { .init() }
}
// swiftlint:enable missing_docs
