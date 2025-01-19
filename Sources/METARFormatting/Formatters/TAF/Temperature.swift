import Foundation
import SwiftMETAR
import BuildableMacro

public extension TAF.Temperature {
    
    /// Formatter for `TAF.Temperature`
    @Buildable struct FormatStyle: Foundation.FormatStyle, Sendable {
        
        /// The formatter to use for temperature values.
        public var tempFormat = Measurement<UnitTemperature>.FormatStyle(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(0)))
        
        /// The format to use when printing times.
        public var dateFormat = Date.FormatStyle(date: .omitted, time: .shortened)
        
        public func format(_ value: TAF.Temperature) -> String {
            let time = Calendar.current.date(from: value.time)
            
            return switch value.type {
                case .minimum:
                    if let time {
                        String(localized: "minimum temperature \(value.measurement, format: tempFormat) at \(time, format: dateFormat)", comment: "forecast temperature")
                    } else {
                        String(localized: "minimum temperature \(value.measurement, format: tempFormat)", comment: "forecast temperature")
                    }
                    
                case .maximum:
                    if let time {
                        String(localized: "maximum temperature \(value.measurement, format: tempFormat) at \(time, format: dateFormat)", comment: "forecast temperature")
                    } else {
                        String(localized: "maximum temperature \(value.measurement, format: tempFormat)", comment: "forecast temperature")
                    }
                    
                case .none:
                    if let time {
                        String(localized: "temperature \(value.measurement, format: tempFormat) at \(time, format: dateFormat)", comment: "forecast temperature")
                    } else {
                        String(localized: "temperature \(value.measurement, format: tempFormat)", comment: "forecast temperature")
                    }
            }
        }
    }
}

public extension FormatStyle where Self == TAF.Temperature.FormatStyle {
    static func temperature(tempFormat: Measurement<UnitTemperature>.FormatStyle? = nil,
                            dateFormat: Date.FormatStyle? = nil) -> Self {
        if let tempFormat, let dateFormat {
            .init(tempFormat: tempFormat, dateFormat: dateFormat)
        } else if let tempFormat {
            .init(tempFormat: tempFormat)
        } else if let dateFormat {
            .init(dateFormat: dateFormat)
        } else {
            .init()
        }
    }
    
    static var temperature: Self { .init() }
}
