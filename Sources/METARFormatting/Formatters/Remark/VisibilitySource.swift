import BuildableMacro
import Foundation
import SwiftMETAR

public extension Remark.VisibilitySource {

    /// Formatter for `Remark.VisibilitySource`
    @Buildable
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public var includeVisibility = false

        public func format(_ value: Remark.VisibilitySource) -> String {
            if includeVisibility {
                switch value {
                    case .tower: String(localized: "tower visibility", comment: "visibility sourcer")
                    case .surface: String(localized: "surface visibility", comment: "visibility sourcer")
                }
            } else {
                switch value {
                    case .tower: String(localized: "tower", comment: "visibility source")
                    case .surface: String(localized: "surface", comment: "visibility source")
                }
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == Remark.VisibilitySource.FormatStyle {
    static var source: Self { .init() }

    static func source(includeVisibility: Bool = false) -> Self {
        .init(includeVisibility: includeVisibility)
    }
}
// swiftlint:enable missing_docs
