import Foundation
import SwiftMETAR

public extension Remark.LightningType {

    /// Formatter for `Remark.LightningType`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: Remark.LightningType) -> String {
            switch value {
                case .cloudToGround: String(localized: "cloud-to-ground", comment: "lightning type")
                case .withinCloud: String(localized: "intra-cloud", comment: "lightning type")
                case .cloudToCloud: String(localized: "cloud-to-cloud", comment: "lightning type")
                case .cloudToAir: String(localized: "cloud-to-air", comment: "lightning type")
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == Remark.LightningType.FormatStyle {
    static var lightning: Self { .init() }
}
// swiftlint:enable missing_docs
