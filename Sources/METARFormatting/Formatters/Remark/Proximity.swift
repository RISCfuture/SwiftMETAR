import Foundation
import SwiftMETAR

extension Remark.Proximity {

  /// Formatter for `Remark.Proximity`
  public struct FormatStyle: Foundation.FormatStyle, Sendable {
    public func format(_ value: Remark.Proximity) -> String {
      switch value {
        case .overhead: String(localized: "overhead", comment: "lightning proximity")
        case .vicinity: String(localized: "in the vicinity", comment: "lightning proximity")
        case .distant: String(localized: "distant", comment: "lightning proximity")
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Remark.Proximity.FormatStyle {
  public static var proximity: Self { .init() }
}
// swiftlint:enable missing_docs
