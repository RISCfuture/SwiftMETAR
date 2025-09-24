import BuildableMacro
import Foundation
import SwiftMETAR

extension Remark.VisibilitySource {

  /// Formatter for `Remark.VisibilitySource`
  @Buildable
  public struct FormatStyle: Foundation.FormatStyle, Sendable {
    public var includeVisibility = false

    public func format(_ value: Remark.VisibilitySource) -> String {
      if includeVisibility {
        switch value {
          case .tower: String(localized: "tower visibility", comment: "visibility sourcer")
          case .surface: String(localized: "surface visibility", comment: "visibility sourcer")
        }
      } else {
        switch value {
          case .tower: String(localized: "tower", comment: "visibility source")
          case .surface: String(localized: "surface", comment: "visibility source")
        }
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Remark.VisibilitySource.FormatStyle {
  public static var source: Self { .init() }

  public static func source(includeVisibility: Bool = false) -> Self {
    .init(includeVisibility: includeVisibility)
  }
}
// swiftlint:enable missing_docs
