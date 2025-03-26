import BuildableMacro
import Foundation
import SwiftMETAR

public extension Icing.IcingType {

    /// Formatter for `Icing.IcingType`
    @Buildable
    struct FormatStyle: Foundation.FormatStyle, Sendable {

        /// Whether to include the word "icing" in the formatted text.
        public var includeIcing = false

        public func format(_ value: Icing.IcingType) -> String {
            if includeIcing {
                switch value {
                    case .traceNone: String(localized: "trace or none", comment: "icing intensity")
                    case .lightMixed: String(localized: "light mixed", comment: "icing intensity")
                    case .lightRime: String(localized: "light rime", comment: "icing intensity")
                    case .lightClear: String(localized: "light clear", comment: "icing intensity")
                    case .moderateMixed: String(localized: "mixed", comment: "icing intensity")
                    case .moderateRime: String(localized: "rime", comment: "icing intensity")
                    case .moderateClear: String(localized: "clear", comment: "icing intensity")
                    case .severeMixed: String(localized: "severe mixed", comment: "icing intensity")
                    case .severeRime: String(localized: "severe rime", comment: "icing intensity")
                    case .severeClear: String(localized: "severe clear", comment: "icing intensity")
                }
            } else {
                switch value {
                    case .traceNone: String(localized: "trace or no icing", comment: "icing intensity")
                    case .lightMixed: String(localized: "light mixed icing", comment: "icing intensity")
                    case .lightRime: String(localized: "light rime icing", comment: "icing intensity")
                    case .lightClear: String(localized: "light clear icing", comment: "icing intensity")
                    case .moderateMixed: String(localized: "mixed icing", comment: "icing intensity")
                    case .moderateRime: String(localized: "rime icing", comment: "icing intensity")
                    case .moderateClear: String(localized: "clear icing", comment: "icing intensity")
                    case .severeMixed: String(localized: "severe mixed icing", comment: "icing intensity")
                    case .severeRime: String(localized: "severe rime icing", comment: "icing intensity")
                    case .severeClear: String(localized: "severe clear icing", comment: "icing intensity")
                }
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == Icing.IcingType.FormatStyle {
    static var type: Self { .init() }

    static func type(includeIcing: Bool = false) -> Self {
        .init(includeIcing: includeIcing)
    }
}
// swiftlint:enable missing_docs
