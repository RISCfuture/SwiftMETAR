public import Foundation

/// A single winds and temperatures aloft data group, representing the wind
/// and optional temperature at a specific altitude for a station.
public enum WindsAloftEntry: CodedRepresentable, Equatable, Sendable {

  /**
   Light and variable winds (less than 5 knots), encoded as `9900` in the
   product.

   - Parameter temperature: The temperature in degrees Celsius, or `nil` if not
                            reported at this altitude. Temperatures are omitted
                            at 3,000 ft and reported at every altitude above it,
                            so a light and variable group carries a temperature
                            at all but the lowest level.
   */
  case lightAndVariable(temperature: Int8?)

  /**
   Wind with direction, speed, and optional temperature.

   - Parameter direction: The wind direction in degrees true, rounded to the
                          nearest 10 degrees (0–360).
   - Parameter speed: The wind speed.
   - Parameter temperature: The temperature in degrees Celsius, or `nil` if
                            not reported at this altitude.
   */
  case wind(direction: UInt16, speed: Wind.Speed, temperature: Int8?)

  /// The direction and speed figures that mark a group as light and variable.
  private static let lightAndVariableGroup = "9900"

  /// The wind speed expressed as a `Measurement`, which is convertible to
  /// other units. Returns `nil` for light and variable.
  public var speedMeasurement: Measurement<UnitSpeed>? {
    switch self {
      case .lightAndVariable: nil
      case .wind(_, let speed, _): speed.measurement
    }
  }

  /// The temperature expressed as a `Measurement`, which is convertible to
  /// other units. Returns `nil` when temperature is not reported at this
  /// altitude.
  public var temperatureMeasurement: Measurement<UnitTemperature>? {
    switch self {
      case let .lightAndVariable(temperature), let .wind(_, _, temperature):
        temperature.map { .init(value: Double($0), unit: .celsius) }
    }
  }

  /// The wind direction expressed as a `Measurement`, which is convertible
  /// to other units. Returns `nil` for light and variable.
  public var directionMeasurement: Measurement<UnitAngle>? {
    switch self {
      case .lightAndVariable: nil
      case .wind(let direction, _, _):
        .init(value: Double(direction), unit: .degrees)
    }
  }

  /**
   The canonical coded winds-aloft data group, e.g. `"3209+02"` for a
   320° wind at 9 knots and +2°C, or `"9900-10"` for light and variable
   at −10°C.

   Directions are emitted in tens of degrees; speeds of 100 knots or more
   add 50 to the direction figure and subtract 100 from the speed figure.
   Temperatures, when present, are always emitted in the explicit signed
   form (`±TT`), even for values that could also be coded in the six-digit
   unsigned high-altitude form.
   */
  public var codedString: String {
    switch self {
      case let .lightAndVariable(temperature):
        return Self.lightAndVariableGroup + Self.codedTemperature(temperature)
      case let .wind(direction, speed, temperature):
        let knots = UInt16(speed.measurement.converted(to: .knots).value.rounded())
        var dd = direction / 10
        var ff = knots
        if knots >= 100 {
          dd += 50
          ff -= 100
        }
        return String(format: "%02d%02d", Int(dd), Int(ff))
          + Self.codedTemperature(temperature)
    }
  }

  /**
   Parses a coded winds-aloft data group into a value.

   - Parameter coded: The coded group, e.g. `"3209+02"` or `"9900"`.
   - Throws: ``Error/invalidWindsAloftGroup(_:)`` if `coded` is not a valid
             winds-aloft data group.
   */
  public init(coded: String) throws {
    guard let entry = try WindsAloftDataGroupParser().parse(coded) else {
      throw Error.invalidWindsAloftGroup(coded)
    }
    self = entry
  }

  /// Renders a temperature in the explicit signed form (`±TT`), or the empty
  /// string when no temperature is reported.
  private static func codedTemperature(_ temperature: Int8?) -> String {
    guard let temperature else { return "" }
    return String(format: "%+03d", Int(temperature))
  }
}
