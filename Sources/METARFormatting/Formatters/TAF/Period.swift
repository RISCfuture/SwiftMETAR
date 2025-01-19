import Foundation
import SwiftMETAR
import BuildableMacro

public extension TAF.Group.Period {
    
    /// Formatter for `TAF.Group.Period`
    @Buildable struct FormatStyle: Foundation.FormatStyle, Sendable {
        
        /// The formatter to use for date intervals.
        public var intervalFormat = Date.IntervalFormatStyle(date: .omitted, time: .shortened)
        
        /// The formatter to use for single dates.
        public var datetimeFormat = Date.FormatStyle(date: .abbreviated, time: .shortened)
        
        public func format(_ value: TAF.Group.Period) -> String {
            switch value {
                case let .range(interval):
                    return String(localized: "from \(interval.dateInterval.range, format: intervalFormat)", comment: "TAF period (date range)")
                    
                case let .from(components):
                    let date = Calendar.current.date(from: components)
                    
                    if let date {
                        return String(localized: "from \(date, format: datetimeFormat)", comment: "TAF period (date)")
                    } else {
                        return String(localized: "from <unknown>", comment: "TAF period (date)")
                    }
                    
                case let .temporary(interval):
                    return String(localized: "temporarily from \(interval.dateInterval.range, format: intervalFormat)", comment: "TAF period (date range)")
                    
                case let .becoming(interval):
                    return String(localized: "becoming from \(interval.dateInterval.range, format: intervalFormat)", comment: "TAF period (date range)")
                    
                case let .probability(chance, interval):
                    return String(localized: "\(chance, format: .percent) chance from \(interval.dateInterval.range, format: intervalFormat)", comment: "TAF period (date range)")
            }
        }
    }
}

public extension FormatStyle where Self == TAF.Group.Period.FormatStyle {
    static func period(intervalFormat: Date.IntervalFormatStyle? = nil,
                       datetimeFormat: Date.FormatStyle? = nil) -> Self {
        if let intervalFormat, let datetimeFormat {
            .init(intervalFormat: intervalFormat, datetimeFormat: datetimeFormat)
        } else if let intervalFormat {
            .init(intervalFormat: intervalFormat)
        } else if let datetimeFormat {
            .init(datetimeFormat: datetimeFormat)
        } else {
            .init()
        }
    }
    
    static var period: Self { .init() }
}
