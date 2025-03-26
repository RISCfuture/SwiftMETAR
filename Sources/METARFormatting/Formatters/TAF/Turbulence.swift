import BuildableMacro
import Foundation
import SwiftMETAR

public extension Turbulence {

    /// Formatter for `Turbulence`
    @Buildable
    struct FormatStyle: Foundation.FormatStyle, Sendable {

        /// The format to use for layer heights.
        public var heightFormat = Measurement<UnitLength>.FormatStyle(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(0)))

        public func format(_ value: Turbulence) -> String {
            if let frequency = value.frequency {
                String(localized: "\(frequency, format: .frequency) \(value.intensity, format: .intensity) \(value.location ?? .inCloud, format: .location) from \(value.baseMeasurement, format: heightFormat) to \(value.topMeasurement, format: heightFormat)", comment: "turbulence (frequency, intensity, location, base, top)")
            } else {
                String(localized: "\(value.intensity, format: .intensity) \(value.location ?? .inCloud, format: .location) from \(value.baseMeasurement, format: heightFormat) to \(value.topMeasurement, format: heightFormat)", comment: "turbulence (intensity, location, base, top)")
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == Turbulence.FormatStyle {
    static var turbulence: Self { .init() }

    static func turbulence(heightFormat: Measurement<UnitLength>.FormatStyle? = nil) -> Self {
        heightFormat.map { .init(heightFormat: $0) } ?? .init()
    }
}
// swiftlint:enable missing_docs
