import Foundation
import SwiftMETAR
import BuildableMacro

public extension RunwayVisibility {
    
    /// Formatter for `RunwayVisibility`
    @Buildable struct FormatStyle: Foundation.FormatStyle, Sendable {
        
        /// The formatter to use for visibilities.
        public var visibilityFormat = Visibility.FormatStyle()
        
        public func format(_ value: RunwayVisibility) -> String {
            String(localized: "runway \(value.runwayID) visibility \(value.visibility, format: visibilityFormat)", comment: "runway visibility")
        }
    }
}

public extension FormatStyle where Self == RunwayVisibility.FormatStyle {
    static func visibility(visibilityFormat: Visibility.FormatStyle? = nil) -> Self {
        visibilityFormat.map { .init(visibilityFormat: $0) } ?? .init()
    }
    
    static var visibility: Self { .init() }
}
