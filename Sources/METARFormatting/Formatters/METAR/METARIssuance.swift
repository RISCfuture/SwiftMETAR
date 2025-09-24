import Foundation
import SwiftMETAR

extension METAR.Issuance {

  /// Formatter for `METAR.Issuance`
  public struct FormatStyle: Foundation.FormatStyle, Sendable {
    public func format(_ value: METAR.Issuance) -> String {
      switch value {
        case .routine: String(localized: "routine", comment: "METAR issuance")
        case .special: String(localized: "special", comment: "METAR issuance")
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == METAR.Issuance.FormatStyle {
  public static var issuance: Self { .init() }
}
// swiftlint:enable missing_docs
