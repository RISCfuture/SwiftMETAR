import Foundation
import SwiftMETAR
import BuildableMacro

public extension Visibility {
    
    /// Formatter for `Visibility`
    @Buildable struct FormatStyle: Foundation.FormatStyle, Sendable {
        
        /// The width of the formatted string.
        public var width = Width.full
        
        /// The formatter to use for visibility distances.
        public var distanceFormat = Measurement<UnitLength>.FormatStyle(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(2)))
        
        public func format(_ value: Visibility) -> String {
            switch width {
                case .abbreviated:
                    switch value {
                        case let .equal(distance):
                            distanceFormat.format(distance.measurement)
                        case let .lessThan(distance):
                            String(localized: "< \(distance.measurement, format: distanceFormat)", comment: "visibility")
                        case let .greaterThan(distance):
                            String(localized: "> \(distance.measurement, format: distanceFormat)", comment: "visibility")
                        case let .variable(low, high):
                            String(localized: "\(low, format: self) – \(high, format: self)", comment: "visibility")
                        case .notRecorded:
                            String(localized: "n/a", comment: "visibility")
                    }
                    
                case .full:
                    switch value {
                        case let .equal(distance):
                            distanceFormat.format(distance.measurement)
                        case let .lessThan(distance):
                            String(localized: "less than \(distance.measurement, format: distanceFormat)", comment: "visibility")
                        case let .greaterThan(distance):
                            String(localized: "greater than \(distance.measurement, format: distanceFormat)", comment: "visibility")
                        case let .variable(low, high):
                            String(localized: "variable between \(low, format: self) and \(high, format: self)", comment: "visibility")
                        case .notRecorded:
                            String(localized: "not recorded", comment: "visibility")
                    }
            }
        }
        
        /// Visibility format widths. This does not affect the format width of
        /// the `Measurement` FormatStyle (see
        /// ``Visibility/FormatStyle/distanceFormat``).
        public enum Width: Sendable, Codable, Equatable {
            /// Use abbreviations like "<" for "less than".
            case abbreviated
            
            /// Use full strings like "less than".
            case full
        }
    }
}

public extension FormatStyle where Self == Visibility.FormatStyle {
    static func visibility(distanceFormat: Measurement<UnitLength>.FormatStyle? = nil,
                           width: Visibility.FormatStyle.Width? = nil) -> Self {
        if let distanceFormat, let width {
            .init(width: width, distanceFormat: distanceFormat)
        } else if let distanceFormat {
            .init(distanceFormat: distanceFormat)
        } else if let width {
            .init(width: width)
        } else {
            .init()
        }
    }
    
    static var visibility: Self { .init() }
}
