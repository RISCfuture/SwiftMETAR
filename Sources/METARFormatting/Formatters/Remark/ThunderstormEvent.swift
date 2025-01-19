import Foundation
import SwiftMETAR

public extension Remark.ThunderstormEvent {
    
    /// Formatter for `Remark.ThunderstormEvent`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        
        /// Whether to include the word "thunderstorms" in the output (i.e.,
        /// "thunderstorms began at..." instead of "began at...").
        public var includeThunderstorms: Bool
        
        /// The format to use when printing start/stop times.
        public var dateFormat: Date.FormatStyle
        
        public func format(_ value: Remark.ThunderstormEvent) -> String {
            let time = Calendar.current.date(from: value.time)!
            
            if includeThunderstorms {
                return switch value.type {
                    case .began:
                        String(localized: "thunderstorms began at \(time, format: dateFormat)", comment: "thunderstorm event (time)")
                    case .ended:
                        String(localized: "thunderstorms ended at \(time, format: dateFormat)", comment: "thunderstorm event (time)")
                }
            } else {
                return switch value.type {
                    case .began:
                        String(localized: "began at \(time, format: dateFormat)", comment: "thunderstorm event (time)")
                    case .ended:
                        String(localized: "ended at \(time, format: dateFormat)", comment: "thunderstorm event (time)")
                }
            }
        }
    }
}

public extension FormatStyle where Self == Remark.ThunderstormEvent.FormatStyle {
    static func event(includeThunderstorms: Bool, dateFormat: Date.FormatStyle) -> Self {
        .init(includeThunderstorms: includeThunderstorms, dateFormat: dateFormat)
    }
}
