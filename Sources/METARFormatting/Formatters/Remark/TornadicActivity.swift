import Foundation
import SwiftMETAR

public extension Remark.TornadicActivityType {

    /// Formatter for `Remark.TornadicActivity`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: Remark.TornadicActivityType) -> String {
            switch value {
                case .tornado: String(localized: "tornado", comment: "tornadic phenomenon")
                case .funnelCloud: String(localized: "funnel cloud", comment: "tornadic phenomenon")
                case .waterspout: String(localized: "waterspout", comment: "tornadic phenomenon")
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == Remark.TornadicActivityType.FormatStyle {
    static var tornadicActivity: Self { .init() }
}
// swiftlint:enable missing_docs
