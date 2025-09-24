import Foundation
import SwiftMETAR

extension Remark.ObservedPrecipitationType {

  /// Formatter for `Remark.ObservedPrecipitationType`
  public struct FormatStyle: Foundation.FormatStyle, Sendable {
    public func format(_ value: Remark.ObservedPrecipitationType) -> String {
      switch value {
        case .virga: String(localized: "virga", comment: "precipitation")
        case .showers: String(localized: "showers", comment: "precipitation")
        case .showeringRain: String(localized: "showering rain", comment: "precipitation")
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Remark.ObservedPrecipitationType.FormatStyle {
  public static var precipitation: Self { .init() }
}
// swiftlint:enable missing_docs
