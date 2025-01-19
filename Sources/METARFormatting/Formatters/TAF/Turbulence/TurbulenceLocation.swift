import Foundation
import SwiftMETAR
import BuildableMacro

public extension Turbulence.Location {
    
    /// Formatter for `Turbulence.Location`
    @Buildable struct FormatStyle: Foundation.FormatStyle, Sendable {
        
        public func format(_ value: Turbulence.Location) -> String {
            switch value {
                case .clearAir: String(localized: "clear-air turbulence", comment: "turbulence type")
                case .inCloud: String(localized: "turbulence", comment: "turbulence type")
            }
        }
    }
}

public extension FormatStyle where Self == Turbulence.Location.FormatStyle {
    static var location: Self { .init() }
}
