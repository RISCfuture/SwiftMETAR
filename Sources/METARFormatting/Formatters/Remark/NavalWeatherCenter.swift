import BuildableMacro
import Foundation
import SwiftMETAR

public extension Remark.NavalWeatherCenter {

    /// Formatter for `Remark.NavalWeatherCenter`
    @Buildable
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public var width = Width.abbreviated

        public func format(_ value: Remark.NavalWeatherCenter) -> String {
            switch width {
                case .abbreviated:
                    switch value {
                        case .sanDiego: String(localized: "FWC-SD", comment: "naval weather center")
                        case .norfolk: String(localized: "FWC-N", comment: "naval weather center")
                    }
                case .full:
                    switch value {
                        case .sanDiego: String(localized: "Fleet Naval Weather Center San Diego", comment: "naval weather center")
                        case .norfolk: String(localized: "Fleet Naval Weather Center Norfolk", comment: "naval weather center")
                    }
            }
        }

        /// Naval center name widths
        public enum Width: Sendable, Codable {

            /// Abbreviate the naval center name (FWC)
            case abbreviated

            /// Use the full name (Fleet Naval Weather Center)
            case full
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == Remark.NavalWeatherCenter.FormatStyle {
    static var navalWeatherCenter: Self { .init() }

    static func navalWeatherCenter(width: Remark.NavalWeatherCenter.FormatStyle.Width) -> Self {
        .init(width: width)
    }
}
// swiftlint:enable missing_docs
