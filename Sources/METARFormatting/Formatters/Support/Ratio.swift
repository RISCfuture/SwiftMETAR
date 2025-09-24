import BuildableMacro
import Foundation
import NumberKit
import SwiftMETAR

extension Ratio {

  /// Formatter for `Ratio`
  @Buildable
  public struct FormatStyle: Foundation.FormatStyle, Sendable {

    /// The formatter to use for the numerator and denominator.
    public var numberFormatter = IntegerFormatStyle<Int>()

    public func format(_ value: Ratio) -> String {
      if value.denominator == 1 {
        numberFormatter.format(value.numerator)
      } else {
        String(
          localized:
            "\(value.numerator, format: numberFormatter)/\(value.denominator, format: numberFormatter)",
          comment: "ratio (numerator/denominator)"
        )
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Ratio.FormatStyle {
  public static var ratio: Self { .init() }

  public static func ratio(numberFormatter: IntegerFormatStyle<Int>? = nil) -> Self {
    numberFormatter.map { .init(numberFormatter: $0) } ?? .init()
  }
}
// swiftlint:enable missing_docs
