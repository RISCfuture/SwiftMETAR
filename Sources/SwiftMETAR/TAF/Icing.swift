public import Foundation

/// Forecasted icing conditions in a military TAF.
public struct Icing: Equatable, Sendable {

  /// The type of icing forecasted.
  public var type: IcingType

  /// The base of the icing layer, in feet AGL.
  public var base: UInt

  /// The depth of the icing layer, in feet.
  public var depth: UInt

  /// The top of the icing layer, in feet AGL.
  public var top: UInt { base + depth }

  /// The base as a `Measurement`, which can be converted to other units.
  public var baseMeasurement: Measurement<UnitLength> {
    .init(value: Double(base), unit: .feet)
  }

  /// The depth as a `Measurement`, which can be converted to other units.
  public var depthMeasurement: Measurement<UnitLength> {
    .init(value: Double(depth), unit: .feet)
  }

  /// The top as a `Measurement`, which can be converted to other units.
  public var topMeasurement: Measurement<UnitLength> {
    .init(value: Double(top), unit: .feet)
  }

  /// Type of icing forecasted.
  public enum IcingType: String, RawRepresentable, CaseIterable, Codable, Equatable, Sendable {

    /// Trace icing (USAF forecasts) or no icing (WMO forecasts)
    case traceNone = "0"

    /// Light mixed icing
    case lightMixed = "1"

    /// Light rime icing in cloud
    case lightRime = "2"

    /// Light clear icing in precipitation
    case lightClear = "3"

    /// Moderate mixed icing
    case moderateMixed = "4"

    /// Moderate rime icing in cloud
    case moderateRime = "5"

    /// Moderate clear icing in precipitation
    case moderateClear = "6"

    /// Severe mixed icing
    case severeMixed = "7"

    /// Severe rime icing in cloud
    case severeRime = "8"

    /// Severe clear icing in precipitation
    case severeClear = "9"
  }
}

extension Icing: CodedRepresentable {

  /**
   The canonical coded representation of this icing group, e.g. `"620304"`. The
   group is a leading `"6"`, the ``IcingType`` raw digit, the ``base`` in
   hundreds of feet zero-padded to three digits, and the ``depth`` in thousands
   of feet as a single digit.

   The mapping is lossy for values whose ``base`` is not a whole multiple of 100
   feet or whose ``depth`` is not a whole multiple of 1000 feet: the surplus
   feet are truncated by integer division and do not round-trip.
   */
  public var codedString: String {
    "6\(type.rawValue)\(String(format: "%03d", base / 100))\(depth / 1000)"
  }

  /**
   Parses a coded icing string into a value.

   - Parameter coded: The coded string, e.g. `"620304"`.
   - Throws: ``Error/invalidIcing(_:)`` if `coded` is not a valid icing
             representation.
   */
  public init(coded: String) throws {
    var parts = coded.split(whereSeparator: \.isWhitespace)
    guard let icing = try IcingParser().parse(&parts), parts.isEmpty else {
      throw Error.invalidIcing(coded)
    }
    self = icing
  }
}
