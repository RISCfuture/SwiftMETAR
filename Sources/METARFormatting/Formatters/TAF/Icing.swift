import BuildableMacro
import Foundation
import SwiftMETAR

extension Icing {

  /// Formatter for `Icing`
  @Buildable
  public struct FormatStyle: Foundation.FormatStyle, Sendable {

    /// The formatter to use for the icing type.
    public var typeFormat = IcingType.FormatStyle(includeIcing: true)

    /// The format to use for layer heights.
    public var heightFormat = Measurement<UnitLength>.FormatStyle(
      width: .abbreviated,
      usage: .asProvided,
      numberFormatStyle: .number.precision(.fractionLength(0))
    )

    public func format(_ value: Icing) -> String {
      String(
        localized:
          "\(value.type, format: typeFormat) from \(value.baseMeasurement, format: heightFormat) to \(value.topMeasurement, format: heightFormat)",
        comment: "icing layer (type, base, top)"
      )
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Icing.FormatStyle {
  public static var icing: Self { .init() }

  public static func icing(
    typeFormat: Icing.IcingType.FormatStyle? = nil,
    heightFormat: Measurement<UnitLength>.FormatStyle? = nil
  ) -> Self {

    zipOptionals(typeFormat, heightFormat).map { .init(typeFormat: $0, heightFormat: $1) }
      ?? typeFormat.map { .init(typeFormat: $0) } ?? heightFormat.map { .init(heightFormat: $0) }
      ?? .init()
  }
}
// swiftlint:enable missing_docs
