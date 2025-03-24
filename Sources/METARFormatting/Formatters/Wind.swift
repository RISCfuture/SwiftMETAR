import Foundation
import SwiftMETAR
import BuildableMacro

public extension Wind {
    
    /// Formatter for `Wind`
    @Buildable struct FormatStyle: Foundation.FormatStyle, Sendable {
        
        /// The formatter to use for wind directions (angular degrees).
        public var directionFormat = Measurement<UnitAngle>.FormatStyle(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(0)))
        
        /// The formatter to use for wind speeds (usually knots).
        public var speedFormat = Measurement<UnitSpeed>.FormatStyle(
            width: .narrow,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(0)))
        
        public func format(_ value: Wind) -> String {
            switch value {
                case .calm:
                    return String(localized: "calm", comment: "winds")
                case let .variable(speed, headingRange):
                    if let headingRange {
                        let heading1 = Measurement<UnitAngle>(value: Double(headingRange.0), unit: .degrees),
                            heading2 = Measurement<UnitAngle>(value: Double(headingRange.1), unit: .degrees)
                        return String(localized: "\(heading1, format: directionFormat)–\(heading2, format: directionFormat) at \(speed.measurement, format: speedFormat)", comment: "winds (heading–heading at speed)")
                    } else {
                        return String(localized: "variable at \(speed.measurement, format: speedFormat)", comment: "winds (variable at speed)")
                    }
                case let .direction(direction, speed, gust):
                    let directionM = Measurement<UnitAngle>(value: Double(direction), unit: .degrees)
                    if let gust {
                        return String(localized: "\(directionM, format: directionFormat) at \(speed.measurement, format: speedFormat) gusting \(gust.measurement, format: speedFormat)", comment: "winds (heading at speed gusting)")
                    } else {
                        return String(localized: "\(directionM, format: directionFormat) at \(speed.measurement, format: speedFormat)", comment: "winds (heading at speed)")
                    }
                case let .directionRange(direction, headingRange, speed, gust):
                    let directionM = Measurement<UnitAngle>(value: Double(direction), unit: .degrees),
                        heading1 = Measurement<UnitAngle>(value: Double(headingRange.0), unit: .degrees),
                        heading2 = Measurement<UnitAngle>(value: Double(headingRange.1), unit: .degrees)
                    if let gust {
                        return String(localized: "\(directionM, format: directionFormat) at \(speed.measurement, format: speedFormat) gusting \(gust.measurement, format: speedFormat) (\(heading1, format: directionFormat)–\(heading2, format: directionFormat))", comment: "winds (heading at speed gusting, variable heading–heading)")
                    } else {
                        return String(localized: "\(directionM, format: directionFormat) at \(speed.measurement, format: speedFormat) (\(heading1, format: directionFormat)–\(heading2, format: directionFormat))", comment: "winds (heading at speed, variable heading–heading)")
                    }
            }
        }
    }
}

public extension FormatStyle where Self == Wind.FormatStyle {
    static func wind(directionFormat: Measurement<UnitAngle>.FormatStyle? = nil,
                     speedFormat: Measurement<UnitSpeed>.FormatStyle? = nil) -> Self {
        zipOptionals(directionFormat, speedFormat).map { .init(directionFormat: $0, speedFormat: $1) } ??
            directionFormat.map { .init(directionFormat: $0) } ??
            speedFormat.map { .init(speedFormat: $0) } ??
            .init()
    }
    
    static var wind: Self { .init() }
}
