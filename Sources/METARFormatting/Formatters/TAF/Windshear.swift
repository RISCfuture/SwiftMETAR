import BuildableMacro
import Foundation
import SwiftMETAR

public extension Windshear {

    /// Formatter for `Windshear`
    @Buildable
    struct FormatStyle: Foundation.FormatStyle, Sendable {

        /// The formatter to use when printing wind info.
        public var windFormat = Wind.FormatStyle()

        /// The formatter to use when printing windshear heights.
        public var heightFormat = Measurement<UnitLength>.FormatStyle(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(0)))

        public func format(_ value: Windshear) -> String {
            String(localized: "wind shear \(value.wind, format: windFormat) at \(value.heightMeasurement, format: heightFormat)", comment: "windshear")
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == Windshear.FormatStyle {
    static var windshear: Self { .init() }

    static func windshear(windFormat: Wind.FormatStyle? = nil,
                          heightFormat: Measurement<UnitLength>.FormatStyle? = nil) -> Self {
        zipOptionals(windFormat, heightFormat).map { .init(windFormat: $0, heightFormat: $1) } ??
            windFormat.map { .init(windFormat: $0) } ??
            heightFormat.map { .init(heightFormat: $0) } ??
            .init()
    }
}
// swiftlint:enable missing_docs
