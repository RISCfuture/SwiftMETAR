import Foundation
import SwiftMETAR
import BuildableMacro

public extension Icing {
    
    /// Formatter for `Icing`
    @Buildable struct FormatStyle: Foundation.FormatStyle, Sendable {
        
        /// The formatter to use for the icing type.
        public var typeFormat = IcingType.FormatStyle(includeIcing: true)
        
        /// The format to use for layer heights.
        public var heightFormat = Measurement<UnitLength>.FormatStyle(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(0)))
        
        public func format(_ value: Icing) -> String {
            String(localized: "\(value.type, format: typeFormat) from \(value.baseMeasurement, format: heightFormat) to \(value.topMeasurement, format: heightFormat)", comment: "icing layer (type, base, top)")
        }
    }
}

public extension FormatStyle where Self == Icing.FormatStyle {
    static func icing(typeFormat: Icing.IcingType.FormatStyle? = nil,
                      heightFormat: Measurement<UnitLength>.FormatStyle? = nil) -> Self {
        if let typeFormat, let heightFormat {
            .init(typeFormat: typeFormat, heightFormat: heightFormat)
        } else if let typeFormat {
            .init(typeFormat: typeFormat)
        } else if let heightFormat {
            .init(heightFormat: heightFormat)
        } else {
            .init()
        }
    }
    
    static var icing: Self { .init() }
}
