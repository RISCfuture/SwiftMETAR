import Foundation
import SwiftMETAR

extension Condition.CeilingType {

  /// Formatter for `Condition.CeilingType`
  public struct FormatStyle: Foundation.FormatStyle, Sendable {
    public func format(_ value: Condition.CeilingType) -> String {
      switch value {
        case .cumulonimbus: String(localized: "cumulonimbus", comment: "ceiling type")
        case .toweringCumulus: String(localized: "towering cumulonimbus", comment: "ceiling type")
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Condition.CeilingType.FormatStyle {
  public static var ceiling: Self { .init() }
}
// swiftlint:enable missing_docs
