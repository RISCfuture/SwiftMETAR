import BuildableMacro
import Foundation
import SwiftMETAR

extension Visibility {

  /// Formatter for `Visibility`
  @Buildable
  public struct FormatStyle: Foundation.FormatStyle, Sendable {

    /// The width of the formatted string.
    public var width = Width.full

    /// The formatter to use for visibility distances.
    public var distanceFormat = Measurement<UnitLength>.FormatStyle(
      width: .abbreviated,
      usage: .asProvided,
      numberFormatStyle: .number.precision(.fractionLength(2))
    )

    public func format(_ value: Visibility) -> String {
      switch width {
        case .abbreviated:
          switch value {
            case .equal(let distance):
              distanceFormat.format(distance.measurement)
            case .lessThan(let distance):
              String(
                localized: "< \(distance.measurement, format: distanceFormat)",
                comment: "visibility"
              )
            case .greaterThan(let distance):
              String(
                localized: "> \(distance.measurement, format: distanceFormat)",
                comment: "visibility"
              )
            case .variable(let low, let high):
              String(
                localized: "\(low, format: self) – \(high, format: self)",
                comment: "visibility"
              )
            case .notRecorded:
              String(localized: "n/a", comment: "visibility")
          }

        case .full:
          switch value {
            case .equal(let distance):
              distanceFormat.format(distance.measurement)
            case .lessThan(let distance):
              String(
                localized: "less than \(distance.measurement, format: distanceFormat)",
                comment: "visibility"
              )
            case .greaterThan(let distance):
              String(
                localized: "greater than \(distance.measurement, format: distanceFormat)",
                comment: "visibility"
              )
            case .variable(let low, let high):
              String(
                localized: "variable between \(low, format: self) and \(high, format: self)",
                comment: "visibility"
              )
            case .notRecorded:
              String(localized: "not recorded", comment: "visibility")
          }
      }
    }

    /// Visibility format widths. This does not affect the format width of
    /// the `Measurement` FormatStyle (see
    /// ``Visibility/FormatStyle/distanceFormat``).
    public enum Width: Sendable, Codable, Equatable {
      /// Use abbreviations like "<" for "less than".
      case abbreviated

      /// Use full strings like "less than".
      case full
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Visibility.FormatStyle {
  public static var visibility: Self { .init() }

  public static func visibility(
    distanceFormat: Measurement<UnitLength>.FormatStyle? = nil,
    width: Visibility.FormatStyle.Width? = nil
  ) -> Self {
    zipOptionals(width, distanceFormat).map { .init(width: $0, distanceFormat: $1) }
      ?? distanceFormat.map { .init(distanceFormat: $0) } ?? width.map { .init(width: $0) }
      ?? .init()
  }
}
// swiftlint:enable missing_docs
