import BuildableMacro
import Foundation
import SwiftMETAR

public extension Remark.PrecipitationEvent {

    /// Formatter for `Remark.PrecipitationEvent`
    @Buildable
    struct FormatStyle: Foundation.FormatStyle, Sendable {

        /// The format to use for start/stop times.
        public var dateFormat: Date.FormatStyle

        public func format(_ value: Remark.PrecipitationEvent) -> String {
            let time = Calendar.current.date(from: value.time)!

            return switch value.event {
                case .began:
                    if let descriptor = value.descriptor {
                        String(localized: "\(descriptor, format: .descriptor(phenomenon: value.phenomenon)) \(value.phenomenon, format: .phenomenon) began at \(time, format: dateFormat)", comment: "precipitation event (descriptor, phenomenon, time)")
                    } else {
                        String(localized: "\(value.phenomenon, format: .phenomenon) began at \(time, format: dateFormat)", comment: "precipitation event (phenomenon, time)")
                    }
                case .ended:
                    if let descriptor = value.descriptor {
                        String(localized: "\(descriptor, format: .descriptor(phenomenon: value.phenomenon)) \(value.phenomenon, format: .phenomenon) ended at \(time, format: dateFormat)", comment: "precipitation event (descriptor, phenomenon, time)")
                    } else {
                        String(localized: "\(value.phenomenon, format: .phenomenon) ended at \(time, format: dateFormat)", comment: "precipitation event (phenomenon, time")
                    }
            }
        }
    }
}

// swiftlint:disable missing_docs
public extension FormatStyle where Self == Remark.PrecipitationEvent.FormatStyle {
    static func event(dateFormat: Date.FormatStyle) -> Self {
        .init(dateFormat: dateFormat)
    }
}
// swiftlint:enable missing_docs
