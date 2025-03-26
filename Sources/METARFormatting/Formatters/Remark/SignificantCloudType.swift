import Foundation
import SwiftMETAR

public extension Remark.SignificantCloudType {

    /// Formatter for `Remark.SignificantCloudType`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: Remark.SignificantCloudType) -> String {
            switch value {
                case .cb: String(localized: "cumulonimbus", comment: "cloud type")
                case .cbMam: String(localized: "cumulonimbus mammatus", comment: "cloud type")
                case .cuCon: String(localized: "cumulus congestus", comment: "cloud type")
                case .acCas: String(localized: "altocumulus castellanus", comment: "cloud type")
                case .scLen: String(localized: "stratocumulus lenticularis", comment: "cloud type")
                case .acLen: String(localized: "altocumulus lenticularis", comment: "cloud type")
                case .ccLen: String(localized: "cirrocumulus lenticularis", comment: "cloud type")
                case .rotor: String(localized: "rotor or roll cloud", comment: "cloud type")
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == Remark.SignificantCloudType.FormatStyle {
    static var cloudType: Self { .init() }
}
// swiftlint:enable missing_docs
