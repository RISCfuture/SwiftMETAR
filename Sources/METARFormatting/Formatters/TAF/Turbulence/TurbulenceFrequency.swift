import Foundation
import SwiftMETAR
import BuildableMacro

public extension Turbulence.Frequency {
    
    /// Formatter for `Turbulence.Frequency`
    @Buildable struct FormatStyle: Foundation.FormatStyle, Sendable {
        
        public func format(_ value: Turbulence.Frequency) -> String {
            switch value {
                case .occasional: String(localized: "occasional", comment: "turbulence frequency")
                case .frequent: String(localized: "frequent", comment: "turbulence frequency")
            }
        }
    }
}

public extension FormatStyle where Self == Turbulence.Frequency.FormatStyle {
    static var frequency: Self { .init() }
}
