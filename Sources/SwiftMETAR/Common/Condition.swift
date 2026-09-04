public import Foundation

/// A sky condition, either a cloud layer or the presence of a clear sky.
public enum Condition: CodedRepresentable, Equatable, Sendable {

  /// Sky clear below 12,000 feet (USA) or 25,000 feet (Canada). Typically
  /// reported by automated ceilometers.
  case clear

  /// Sky clear. Typically reported by human observers.
  case skyClear

  /// No significant clouds below 5,000 feet and no TCU or CB.
  case noSignificantClouds

  /**
   Included outside US region as a replacement of
   visibility, cloud, and weather groups.

   - No clouds exist below 5,000 feet or below the highest minimum sector
   altitude, whichever is greater, and no TCU or CB are present.
   - Visibility is 10 kilometres or greater
   - No precipitation, thunderstorms, sandstorm, dust storm, shallow fog,
   or low drifting dust, sand or snow is occurring (no significant weather).
   */
  case cavok

  /**
   Cloud coverage between 1 and 2 oktas.

   - Parameter height: The cloud bases in feet AGL.
   - Parameter type: The vertical development, if any.
   */
  case few(_ height: UInt, type: CeilingType? = nil)

  /**
   Cloud coverage between 3 and 4 oktas.

   - Parameter height: The cloud bases in feet AGL.
   - Parameter type: The vertical development, if any.
   */
  case scattered(_ height: UInt, type: CeilingType? = nil)

  /**
   Cloud coverage between 5 and 7 oktas.

   - Parameter height: The cloud bases in feet AGL.
   - Parameter type: The vertical development, if any.
   */
  case broken(_ height: UInt, type: CeilingType? = nil)

  /**
   Cloud coverage of 8 oktas.

   - Parameter height: The cloud bases in feet AGL.
   - Parameter type: The vertical development, if any.
   */
  case overcast(_ height: UInt, type: CeilingType? = nil)

  /**
   Cloud coverage is obscured by low-visibility conditions; the height of the
   obscuration layer is reported instead.

   - Parameter ceiling: The top altitude of the obscuration layer, in feet
                        AGL.
   */
  case indefinite(_ ceiling: UInt)

  /// The cloud height as a `Measurement`, which can be converted to other
  /// units. Returns `nil` for conditions without cloud heights.
  public var heightMeasurement: Measurement<UnitLength>? {
    switch self {
      case .few(let height, _): .init(value: Double(height), unit: .feet)
      case .scattered(let height, _): .init(value: Double(height), unit: .feet)
      case .broken(let height, _): .init(value: Double(height), unit: .feet)
      case .overcast(let height, _): .init(value: Double(height), unit: .feet)
      case .indefinite(let height): .init(value: Double(height), unit: .feet)
      default: nil
    }
  }

  /**
   The coded representation of this sky condition, e.g. `"CLR"`, `"FEW020"`,
   `"BKN050CB"`, or `"VV002"`. Cloud heights are emitted as hundreds of feet,
   zero-padded to three digits; any vertical development is appended as its
   coded suffix (`"CB"` or `"TCU"`).
   */
  public var codedString: String {
    switch self {
      case .clear: return "CLR"
      case .skyClear: return "SKC"
      case .noSignificantClouds: return "NSC"
      case .cavok: return "CAVOK"
      case let .few(height, type): return "FEW\(Self.heightGroup(height))\(Self.suffix(type))"
      case let .scattered(height, type):
        return "SCT\(Self.heightGroup(height))\(Self.suffix(type))"
      case let .broken(height, type): return "BKN\(Self.heightGroup(height))\(Self.suffix(type))"
      case let .overcast(height, type):
        return "OVC\(Self.heightGroup(height))\(Self.suffix(type))"
      case .indefinite(let ceiling): return "VV\(Self.heightGroup(ceiling))"
    }
  }

  /**
   Parses a coded sky-condition token into a value.

   - Parameter coded: The coded string, e.g. `"BKN050CB"` or `"CLR"`.
   - Throws: ``Error/invalidConditions(_:)`` if `coded` is not a valid
             representation of a single sky condition.
   */
  public init(coded: String) throws {
    if coded == "CAVOK" {
      self = .cavok
      return
    }

    var parts = coded.split(whereSeparator: \.isWhitespace)
    let conditions = try ConditionsParser().parse(&parts)
    guard conditions.count == 1, parts.isEmpty else {
      throw Error.invalidConditions(coded)
    }
    self = conditions[0]
  }

  private static func heightGroup(_ feet: UInt) -> String {
    String(format: "%03d", feet / 100)
  }

  private static func suffix(_ type: CeilingType?) -> String {
    type?.rawValue ?? ""
  }

  /// Types of vertical development that a cloud layer can have.
  public enum CeilingType: String, Codable, RegexCases, Sendable {

    /// Layer consists of cumulonimbus clouds.
    case cumulonimbus = "CB"

    /// Layer consists of towering cumulus clouds.
    case toweringCumulus = "TCU"
  }
}
