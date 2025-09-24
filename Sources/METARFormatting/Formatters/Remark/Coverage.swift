import Foundation
import SwiftMETAR

extension Remark.Coverage {

  /// Formatter for `Remark.Coverage`
  public struct FormatStyle: Foundation.FormatStyle, Sendable {
    public func format(_ value: Remark.Coverage) -> String {
      switch value {
        case .few: String(localized: "few", comment: "coverage")
        case .scattered: String(localized: "scattered", comment: "coverage")
        case .broken: String(localized: "broken", comment: "coverage")
        case .overcast: String(localized: "overcast", comment: "coverage")
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Remark.Coverage.FormatStyle {
  public static var coverage: Self { .init() }
}
// swiftlint:enable missing_docs
