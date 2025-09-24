import Foundation
import SwiftMETAR

extension TAF.Issuance {

  /// Formatter for `TAF.Issuance`
  public struct FormatStyle: Foundation.FormatStyle, Sendable {
    public func format(_ value: TAF.Issuance) -> String {
      switch value {
        case .routine: String(localized: "routine", comment: "TAF issuance")
        case .amended: String(localized: "amended", comment: "TAF issuance")
        case .corrected: String(localized: "corrected", comment: "TAF issuance")
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == TAF.Issuance.FormatStyle {
  public static var issuance: Self { .init() }
}
// swiftlint:enable missing_docs
