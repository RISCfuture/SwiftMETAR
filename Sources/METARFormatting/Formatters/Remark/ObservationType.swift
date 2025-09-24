import Foundation
import SwiftMETAR

extension Remark.ObservationType {
  /// Formatter for `Remark.ObservationType`
  public struct FormatStyle: Foundation.FormatStyle, Sendable {
    public func format(_ value: Remark.ObservationType) -> String {
      switch value {
        case .automated: String(localized: "automated observation station", comment: "remark")
        case .automatedWithPrecipitation:
          String(
            localized: "automated observation station with precipitation recording",
            comment: "remark"
          )
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Remark.ObservationType.FormatStyle {
  public static var observationType: Self { .init() }
}
// swiftlint:enable missing_docs
