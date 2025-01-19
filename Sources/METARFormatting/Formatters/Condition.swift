import Foundation
import SwiftMETAR
import BuildableMacro

public extension Condition {
    
    /// Formatter for `Condition`
    @Buildable struct FormatStyle: Foundation.FormatStyle, Sendable {
        
        /// The formatter to use for cloud heights.
        public var heightFormatter = Measurement<UnitLength>.FormatStyle(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(0)))
        
        public func format(_ value: Condition) -> String {
            switch value {
                case .clear:
                    String(localized: "clear below 12,000 ft.", comment: "sky condition")
                    
                case .skyClear:
                    String(localized: "sky clear", comment: "sky condition")
                    
                case .noSignificantClouds:
                    String(localized: "no significant clouds", comment: "sky condition")
                    
                case .cavok:
                    String(localized: "CAVOK", comment: "sky condition")
                    
                case let .few(_, type):
                    if let type {
                        String(localized: "few clouds at \(value.heightMeasurement!, format: heightFormatter) (\(type, format: .ceiling))", comment: "sky condition")
                    } else {
                        String(localized: "few clouds at \(value.heightMeasurement!, format: heightFormatter)", comment: "sky condition")
                    }
                    
                case let .scattered(_, type):
                    if let type {
                        String(localized: "scattered clouds at \(value.heightMeasurement!, format: heightFormatter) (\(type, format: .ceiling))", comment: "sky condition")
                    } else {
                        String(localized: "scattered clouds at \(value.heightMeasurement!, format: heightFormatter)", comment: "sky condition")
                    }
                    
                case let .broken(_, type):
                    if let type {
                        String(localized: "broken clouds at \(value.heightMeasurement!, format: heightFormatter) (\(type, format: .ceiling))", comment: "sky condition")
                    } else {
                        String(localized: "broken clouds at \(value.heightMeasurement!, format: heightFormatter)", comment: "sky condition")
                    }
                    
                case let .overcast(_, type):
                    if let type {
                        String(localized: "overcast clouds at \(value.heightMeasurement!, format: heightFormatter) (\(type, format: .ceiling))", comment: "sky condition")
                    } else {
                        String(localized: "overcast clouds at \(value.heightMeasurement!, format: heightFormatter)", comment: "sky condition")
                    }
                    
                case .indefinite:
                    String(localized: "indefinite ceiling; vertical visibility \(value.heightMeasurement!, format: heightFormatter)")
            }
        }
    }
}

public extension FormatStyle where Self == Condition.FormatStyle {
    static func condition(heightFormatter: Measurement<UnitLength>.FormatStyle? = nil) -> Self {
        if let heightFormatter {
            .init(heightFormatter: heightFormatter)
        } else {
            .init()
        }
    }
    
    static var condition: Self { .init() }
}
