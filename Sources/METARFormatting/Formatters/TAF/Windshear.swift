import Foundation
import SwiftMETAR
import BuildableMacro

public extension Windshear {
    
    /// Formatter for `Windshear`
    @Buildable struct FormatStyle: Foundation.FormatStyle, Sendable {
        
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

public extension FormatStyle where Self == Windshear.FormatStyle {
    static func windshear(windFormat: Wind.FormatStyle? = nil,
                          heightFormat: Measurement<UnitLength>.FormatStyle? = nil) -> Self {
        if let windFormat, let heightFormat {
            .init(windFormat: windFormat, heightFormat: heightFormat)
        } else if let windFormat {
            .init(windFormat: windFormat)
        } else if let heightFormat {
            .init(heightFormat: heightFormat)
        } else {
            .init()
        }
    }
    
    static var windshear: Self { .init() }
}
