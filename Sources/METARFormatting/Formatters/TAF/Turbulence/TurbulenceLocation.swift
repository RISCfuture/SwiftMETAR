import BuildableMacro
import Foundation
import SwiftMETAR

extension Turbulence.Location {

  /// Formatter for `Turbulence.Location`
  @Buildable
  public struct FormatStyle: Foundation.FormatStyle, Sendable {

    public func format(_ value: Turbulence.Location) -> String {
      switch value {
        case .clearAir: String(localized: "clear-air turbulence", comment: "turbulence type")
        case .inCloud: String(localized: "turbulence", comment: "turbulence type")
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Turbulence.Location.FormatStyle {
  public static var location: Self { .init() }
}
// swiftlint:enable missing_docs
