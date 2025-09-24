import Foundation
import SwiftMETAR

extension Remark.Location {

  /// Formatter for `Remark.Location`
  public struct FormatStyle: Foundation.FormatStyle, Sendable {
    public var distanceWidth: Measurement<UnitLength>.FormatStyle.UnitWidth
    public var directionWidth: Remark.Direction.FormatStyle.Width = .full

    public func format(_ value: Remark.Location) -> String {
      String(
        localized:
          "\(value.distanceMeasurement, format: .measurement(width: distanceWidth)) \(value.direction, format: .direction(width: directionWidth))",
        comment: "distance, direction"
      )
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Remark.Location.FormatStyle {
  public static func location(
    distanceWidth: Measurement<UnitLength>.FormatStyle.UnitWidth,
    directionWidth: Remark.Direction.FormatStyle.Width? = nil
  ) -> Self {
    directionWidth.map { .init(distanceWidth: distanceWidth, directionWidth: $0) }
      ?? .init(distanceWidth: distanceWidth)
  }
}
// swiftlint:enable missing_docs
