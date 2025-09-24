import BuildableMacro
import Foundation
import SwiftMETAR

extension TAF.Group.Period {

  /// Formatter for `TAF.Group.Period`
  @Buildable
  public struct FormatStyle: Foundation.FormatStyle, Sendable {

    /// The formatter to use for date intervals.
    public var intervalFormat = Date.IntervalFormatStyle(date: .omitted, time: .shortened)

    /// The formatter to use for single dates.
    public var datetimeFormat = Date.FormatStyle(date: .abbreviated, time: .shortened)

    public func format(_ value: TAF.Group.Period) -> String {
      switch value {
        case .range(let interval):
          return String(
            localized: "from \(interval.dateInterval.range, format: intervalFormat)",
            comment: "TAF period (date range)"
          )

        case .from(let components):
          let date = Calendar.current.date(from: components)

          if let date {
            return String(
              localized: "from \(date, format: datetimeFormat)",
              comment: "TAF period (date)"
            )
          }
          return String(localized: "from <unknown>", comment: "TAF period (date)")

        case .temporary(let interval):
          return String(
            localized: "temporarily from \(interval.dateInterval.range, format: intervalFormat)",
            comment: "TAF period (date range)"
          )

        case .becoming(let interval):
          return String(
            localized: "becoming from \(interval.dateInterval.range, format: intervalFormat)",
            comment: "TAF period (date range)"
          )

        case .probability(let chance, let interval):
          return String(
            localized:
              "\(chance, format: .percent) chance from \(interval.dateInterval.range, format: intervalFormat)",
            comment: "TAF period (date range)"
          )
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == TAF.Group.Period.FormatStyle {
  public static var period: Self { .init() }

  public static func period(
    intervalFormat: Date.IntervalFormatStyle? = nil,
    datetimeFormat: Date.FormatStyle? = nil
  ) -> Self {
    zipOptionals(intervalFormat, datetimeFormat).map {
      .init(intervalFormat: $0, datetimeFormat: $1)
    } ?? intervalFormat.map { .init(intervalFormat: $0) } ?? datetimeFormat.map {
      .init(datetimeFormat: $0)
    } ?? .init()
  }
}
// swiftlint:enable missing_docs
