import Foundation
import SwiftMETAR

public extension METAR.Observer {

    /// Formatter for `METAR.Observer`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: METAR.Observer) -> String {
            switch value {
                case .human: String(localized: "human observer", comment: "METAR observer type")
                case .automated: String(localized: "automated observer", comment: "METAR observer type")
                case .corrected: String(localized: "corrected issuance", comment: "METAR observer type")
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == METAR.Observer.FormatStyle {
    static var observer: Self { .init() }
}
// swiftlint:enable missing_docs
