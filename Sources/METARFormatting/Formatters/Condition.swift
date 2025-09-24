import BuildableMacro
import Foundation
import SwiftMETAR

extension Condition {

  /// Formatter for `Condition`
  @Buildable
  public struct FormatStyle: Foundation.FormatStyle, Sendable {

    /// The formatter to use for cloud heights.
    public var heightFormatter = Measurement<UnitLength>.FormatStyle(
      width: .abbreviated,
      usage: .asProvided,
      numberFormatStyle: .number.precision(.fractionLength(0))
    )

    public func format(_ value: Condition) -> String {
      switch value {
        case .clear:
          String(localized: "clear below 12,000 ft.", comment: "sky condition")

        case .skyClear:
          String(localized: "sky clear", comment: "sky condition")

        case .noSignificantClouds:
          String(localized: "no significant clouds", comment: "sky condition")

        case .cavok:
          String(localized: "CAVOK", comment: "sky condition")

        case .few(_, let type):
          if let type {
            String(
              localized:
                "few clouds at \(value.heightMeasurement!, format: heightFormatter) (\(type, format: .ceiling))",
              comment: "sky condition"
            )
          } else {
            String(
              localized: "few clouds at \(value.heightMeasurement!, format: heightFormatter)",
              comment: "sky condition"
            )
          }

        case .scattered(_, let type):
          if let type {
            String(
              localized:
                "scattered clouds at \(value.heightMeasurement!, format: heightFormatter) (\(type, format: .ceiling))",
              comment: "sky condition"
            )
          } else {
            String(
              localized: "scattered clouds at \(value.heightMeasurement!, format: heightFormatter)",
              comment: "sky condition"
            )
          }

        case .broken(_, let type):
          if let type {
            String(
              localized:
                "broken clouds at \(value.heightMeasurement!, format: heightFormatter) (\(type, format: .ceiling))",
              comment: "sky condition"
            )
          } else {
            String(
              localized: "broken clouds at \(value.heightMeasurement!, format: heightFormatter)",
              comment: "sky condition"
            )
          }

        case .overcast(_, let type):
          if let type {
            String(
              localized:
                "overcast clouds at \(value.heightMeasurement!, format: heightFormatter) (\(type, format: .ceiling))",
              comment: "sky condition"
            )
          } else {
            String(
              localized: "overcast clouds at \(value.heightMeasurement!, format: heightFormatter)",
              comment: "sky condition"
            )
          }

        case .indefinite:
          String(
            localized:
              "indefinite ceiling; vertical visibility \(value.heightMeasurement!, format: heightFormatter)"
          )
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Condition.FormatStyle {
  public static var condition: Self { .init() }

  public static func condition(heightFormatter: Measurement<UnitLength>.FormatStyle? = nil) -> Self
  {
    heightFormatter.map { .init(heightFormatter: $0) } ?? .init()
  }
}
// swiftlint:enable missing_docs
