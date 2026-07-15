import Foundation

/// Forecasted turbulence conditions in a military TAF.
public struct Turbulence: Equatable, Sendable {

  /// The location associated with the turbulence.
  public var location: Location?

  /// The intensity of turbulence forecasted.
  public var intensity: Intensity

  /// The frequency of turbulence forecasted.
  public var frequency: Frequency?

  /// The base of the turbulence layer, in feet AGL.
  public var base: UInt

  /// The depth of the turbulence layer, in feet.
  public var depth: UInt

  /// The top of the turbulence layer, in feet AGL.
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

  /// Turbulence locations
  public enum Location: Codable, Sendable {

    /// Clear-air turbulence
    case clearAir

    /// Turbulence inside clouds
    case inCloud
  }

  /// Turbulence intensities
  public enum Intensity: Codable, Sendable {

    /// No turbulence is forecasted.
    case none

    /// Slight erratic changes in altitude and/or attitude.
    case light

    /// Change in altitude and/or attitude, but the aircraft remains in
    /// positive control at all times.
    case moderate

    /// Large, abrupt changes in altitude and/or attitude. Aircraft may be
    /// momentarily out of control.
    case severe

    /// Aircraft is violently tossed about and practically impossible to
    /// control. May cause structural damage.
    case extreme
  }

  /// Turbulence frequencies
  public enum Frequency: Codable, Sendable {

    /// Turbulence will occur less than 1/3 of the time.
    case occasional

    /// Turbulence will occur more than 1/3 of the time.
    case frequent
  }
}

extension Turbulence: CodedRepresentable {

  /**
   The coded representation of this turbulence, e.g. `"520004"`. The group is
   `5`, followed by a single figure encoding ``intensity``, ``location``, and
   ``frequency``, followed by the ``base`` in hundreds of feet (zero-padded to
   three digits) and the ``depth`` in thousands of feet (a single digit).
   */
  public var codedString: String {
    "5\(typeFigure)\(String(format: "%03d", base / 100))\(depth / 1000)"
  }

  private var typeFigure: Character {
    switch intensity {
      case .none: return "0"
      case .light: return "1"
      case .extreme: return "X"
      case .moderate, .severe:
        let severe = intensity == .severe
        switch (location ?? .clearAir, frequency ?? .occasional) {
          case (.clearAir, .occasional): return severe ? "6" : "2"
          case (.clearAir, .frequent): return severe ? "7" : "3"
          case (.inCloud, .occasional): return severe ? "8" : "4"
          case (.inCloud, .frequent): return severe ? "9" : "5"
        }
    }
  }

  /**
   Parses a coded turbulence string into a value.

   - Parameter coded: The coded string, e.g. `"520004"`.
   - Throws: ``Error/invalidTurbulence(_:)`` if `coded` is not a valid turbulence
             representation.
   */
  public init(coded: String) throws {
    var parts = coded.split(whereSeparator: \.isWhitespace)
    guard let turbulence = try TurbulenceParser().parse(&parts), parts.isEmpty else {
      throw Error.invalidTurbulence(coded)
    }
    self = turbulence
  }
}
