/// A runway visibility report made by a transmissometer (or human observer).
public struct RunwayVisibility: Equatable, Sendable {

  /// The ID of the runway (e.g., "21L").
  public let runwayID: String

  /// The visibility in the approach direction along that runway.
  public let visibility: Visibility
}

extension RunwayVisibility: CodedRepresentable {

  /**
   The coded representation of this runway visual range, e.g. `"R17L/2600FT"`,
   `"R17L/800M"`, `"R01L/M600FT"` (less than), or `"R27/P6000FT"` (greater than).

   A variable range joins its two bounds with `V`, with the shared unit written
   once after the high bound, e.g. `"R01L/600V1000FT"`. Each bound may carry its
   own `M` (less than) or `P` (greater than) prefix, e.g. `"R06/M600VP1200M"`.
   */
  public var codedString: String {
    "R\(runwayID)/\(Self.coded(visibility: visibility))"
  }

  /**
   Parses a coded runway visual range group, e.g. `"R17L/2600FT"`,
   `"R17L/0800M"`, `"R01L/M0600FT"`, or a variable range like
   `"R01L/0600V1000FT"`.

   - Parameter coded: The coded RVR string, which must contain exactly one group.
   - Throws: ``Error/badFormat`` if `coded` is not a single valid RVR group.
   */
  public init(coded: String) throws {
    var parts = coded.split(whereSeparator: \.isWhitespace)
    let visibilities = try RVRParser().parse(&parts)
    guard visibilities.count == 1, parts.isEmpty else { throw Error.badFormat }
    self = visibilities[0]
  }

  private static func coded(visibility: Visibility) -> String {
    if case let .variable(low, high) = visibility,
      let lowBound = bound(low),
      let highBound = bound(high)
    {
      return
        "\(lowBound.sign)\(lowBound.digits)V\(highBound.sign)\(highBound.digits)\(highBound.unit)"
    }
    if let bound = bound(visibility) {
      return "\(bound.sign)\(bound.digits)\(bound.unit)"
    }
    return visibility.codedString
  }

  private static func bound(
    _ visibility: Visibility
  ) -> (sign: String, digits: String, unit: String)? {
    let sign: String
    let value: Visibility.Value
    switch visibility {
      case .equal(let distance): sign = ""; value = distance
      case .lessThan(let distance): sign = "M"; value = distance
      case .greaterThan(let distance): sign = "P"; value = distance
      default: return nil
    }
    switch value {
      case .feet(let feet): return (sign, "\(feet)", "FT")
      case .meters(let meters): return (sign, "\(meters)", "M")
      default: return nil
    }
  }
}
