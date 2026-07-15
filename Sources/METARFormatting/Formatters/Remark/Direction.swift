import BuildableMacro
import Foundation
import SwiftMETAR

extension Remark.Direction {

  /// The eight compass points in clockwise order from north.
  static let compassOrder: [Remark.Direction] = [
    .north, .northeast, .east, .southeast, .south, .southwest, .west, .northwest
  ]

  /// Position clockwise from north, or `nil` for ``all``.
  var compassIndex: Int? { Self.compassOrder.firstIndex(of: self) }
}

extension Remark.Direction {

  /// Formatter for `Remark.Direction`
  @Buildable
  public struct FormatStyle: Foundation.FormatStyle, Sendable {

    /// The width to use.
    public var width = Width.full

    public func format(_ value: Remark.Direction) -> String {
      switch width {
        case .abbreviated:
          switch value {
            case .all: String(localized: "all quadrants", comment: "direction")
            case .north: String(localized: "N", comment: "direction")
            case .northeast: String(localized: "NE", comment: "direction")
            case .east: String(localized: "E", comment: "direction")
            case .southeast: String(localized: "SE", comment: "direction")
            case .south: String(localized: "S", comment: "direction")
            case .southwest: String(localized: "SW", comment: "direction")
            case .west: String(localized: "W", comment: "direction")
            case .northwest: String(localized: "NW", comment: "direction")
          }
        case .full:
          switch value {
            case .all: String(localized: "all quadrants", comment: "direction")
            case .north: String(localized: "north", comment: "direction")
            case .northeast: String(localized: "northeast", comment: "direction")
            case .east: String(localized: "east", comment: "direction")
            case .southeast: String(localized: "southeast", comment: "direction")
            case .south: String(localized: "south", comment: "direction")
            case .southwest: String(localized: "southwest", comment: "direction")
            case .west: String(localized: "west", comment: "direction")
            case .northwest: String(localized: "northwest", comment: "direction")
          }
      }
    }

    /// Direction widths
    public enum Width: Sendable, Codable {

      /// Abbreviated directions (N, NE, E, etc.)
      case abbreviated

      /// Longer directions (north, northeast, east, etc.)
      case full
    }
  }

  /// Formatter for `Set<Remark.Direction>`. Consolidates consecutive
  /// directions into ranges (e.g., "north–east").
  @Buildable
  public struct RangeFormatStyle: Foundation.FormatStyle, Sendable {

    private static let compassPoints = Set(Remark.Direction.compassOrder)

    /// The width to use.
    public var width = Remark.Direction.FormatStyle.Width.full

    public func format(_ value: Set<Remark.Direction>) -> String {
      let summary = FormatStyle(width: width)
      if value.contains(.all) || value == Self.compassPoints {
        return summary.format(.all)
      }
      if value.isEmpty {
        return String(localized: "<unknown direction>")
      }

      let values = consolidatedRanges(from: value).map { range in
        if range.0 == range.1 {
          summary.format(range.0)
        } else {
          String(
            localized:
              "\(range.0, format: .direction(width: width)) through \(range.1, format: .direction(width: width))"
          )
        }
      }

      return ListFormatStyle.list(type: .and).format(values)
    }

    /// Groups the directions into ranges of consecutive compass points, sorted
    /// clockwise from north. A run that wraps past north (e.g. northwest through
    /// northeast) is joined into a single range.
    private func consolidatedRanges(
      from directions: Set<Remark.Direction>
    ) -> [(Remark.Direction, Remark.Direction)] {
      let sorted = directions.sorted { ($0.compassIndex ?? .max) < ($1.compassIndex ?? .max) }

      var ranges = [(Remark.Direction, Remark.Direction)]()
      for direction in sorted {
        guard let last = ranges.last,
          let previousIndex = last.1.compassIndex,
          let currentIndex = direction.compassIndex,
          currentIndex == previousIndex + 1
        else {
          ranges.append((direction, direction))
          continue
        }
        ranges[ranges.endIndex - 1].1 = direction
      }

      if ranges.count > 1, ranges.first!.0 == .north, ranges.last!.1 == .northwest {
        let wrap = ranges.removeLast()
        ranges[0].0 = wrap.0
      }

      return ranges
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Remark.Direction.FormatStyle {
  public static var direction: Self { .init() }

  public static func direction(width: Remark.Direction.FormatStyle.Width) -> Self {
    .init(width: width)
  }
}

extension FormatStyle where Self == Remark.Direction.RangeFormatStyle {
  public static var range: Self { .init() }

  public static func range(width: Remark.Direction.FormatStyle.Width) -> Self {
    .init(width: width)
  }
}
// swiftlint:enable missing_docs
