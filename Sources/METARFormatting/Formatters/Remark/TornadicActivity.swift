import Foundation
import SwiftMETAR

extension Remark.TornadicActivityType {

  /// Formatter for `Remark.TornadicActivity`
  public struct FormatStyle: Foundation.FormatStyle, Sendable {
    public func format(_ value: Remark.TornadicActivityType) -> String {
      switch value {
        case .tornado: String(localized: "tornado", comment: "tornadic phenomenon")
        case .funnelCloud: String(localized: "funnel cloud", comment: "tornadic phenomenon")
        case .waterspout: String(localized: "waterspout", comment: "tornadic phenomenon")
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Remark.TornadicActivityType.FormatStyle {
  public static var tornadicActivity: Self { .init() }
}
// swiftlint:enable missing_docs
