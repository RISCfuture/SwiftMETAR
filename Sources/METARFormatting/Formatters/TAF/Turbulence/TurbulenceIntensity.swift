import Foundation
import SwiftMETAR
import BuildableMacro

public extension Turbulence.Intensity {
    
    /// Formatter for `Turbulence.Intensity`
    @Buildable struct FormatStyle: Foundation.FormatStyle, Sendable {
        
        public func format(_ value: Turbulence.Intensity) -> String {
            switch value {
                case .none: String(localized: "no", comment: "turbulence intensity")
                case .light: String(localized: "light", comment: "turbulence intensity")
                case .moderate: String(localized: "moderate", comment: "turbulence intensity")
                case .severe: String(localized: "severe", comment: "turbulence intensity")
                case .extreme: String(localized: "extreme", comment: "turbulence intensity")
            }
        }
    }
}

public extension FormatStyle where Self == Turbulence.Intensity.FormatStyle {
    static var intensity: Self { .init() }
}
