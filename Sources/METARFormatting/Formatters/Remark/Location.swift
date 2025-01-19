import Foundation
import SwiftMETAR

public extension Remark.Location {
    
    /// Formatter for `Remark.Location`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public var distanceWidth: Measurement<UnitLength>.FormatStyle.UnitWidth
        public var directionWidth: Remark.Direction.FormatStyle.Width = .full
        
        public func format(_ value: Remark.Location) -> String {
            String(localized: "\(value.distanceMeasurement, format: .measurement(width: distanceWidth)) \(value.direction, format: .direction(width: directionWidth))", comment: "distance, direction")
        }
    }
}

public extension FormatStyle where Self == Remark.Location.FormatStyle {
    static func location(distanceWidth: Measurement<UnitLength>.FormatStyle.UnitWidth,
                         directionWidth: Remark.Direction.FormatStyle.Width? = nil) -> Self {
        if let directionWidth {
            .init(distanceWidth: distanceWidth, directionWidth: directionWidth)
        } else {
            .init(distanceWidth: distanceWidth)
        }
    }
}
