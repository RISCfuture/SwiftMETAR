import Foundation
import SwiftMETAR

extension Weather.Intensity {

  /// Formatter for `Weather.Intensity`. Does _not_ include the "in the
  /// vicinity" pseudo-intensities; you must add "in the vicinity" yourself.
  public struct FormatStyle: Foundation.FormatStyle, Sendable {
    public func format(_ value: Weather.Intensity) -> String {
      switch value {
        case .light: String(localized: "light", comment: "weather intensity")
        case .moderate: String(localized: "moderate", comment: "weather intensity")
        case .heavy: String(localized: "heavy", comment: "weather intensity")
        case .vicinity: String(localized: "moderate", comment: "weather intensity")
        case .vicinityLight: String(localized: "light", comment: "weather intensity")
        case .vicinityHeavy: String(localized: "heavy", comment: "weather intensity")
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Weather.Intensity.FormatStyle {
  public static var intensity: Self { .init() }
}
// swiftlint:enable missing_docs
