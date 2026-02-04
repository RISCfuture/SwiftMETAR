import Foundation

/// A single winds and temperatures aloft data group, representing the wind
/// and optional temperature at a specific altitude for a station.
public enum WindsAloftEntry: Codable, Equatable, Sendable {

  /// Light and variable winds (less than 5 knots). Encoded as `9900` in the
  /// product.
  case lightAndVariable

  /**
   Wind with direction, speed, and optional temperature.
  
   - Parameter direction: The wind direction in degrees true, rounded to the
                          nearest 10 degrees (0–360).
   - Parameter speed: The wind speed.
   - Parameter temperature: The temperature in degrees Celsius, or `nil` if
                            not reported at this altitude.
   */
  case wind(direction: UInt16, speed: Wind.Speed, temperature: Int8?)

  /// The wind speed expressed as a `Measurement`, which is convertible to
  /// other units. Returns `nil` for light and variable.
  public var speedMeasurement: Measurement<UnitSpeed>? {
    switch self {
      case .lightAndVariable: nil
      case .wind(_, let speed, _): speed.measurement
    }
  }

  /// The temperature expressed as a `Measurement`, which is convertible to
  /// other units. Returns `nil` for light and variable or when temperature
  /// is not reported.
  public var temperatureMeasurement: Measurement<UnitTemperature>? {
    switch self {
      case .lightAndVariable: nil
      case .wind(_, _, let temperature):
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

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    switch try container.decode(String.self, forKey: .type) {
      case "lightAndVariable":
        self = .lightAndVariable
      case "wind":
        let direction = try container.decode(UInt16.self, forKey: .direction)
        let speed = try container.decode(Wind.Speed.self, forKey: .speed)
        let temperature = try container.decode(Int8?.self, forKey: .temperature)
        self = .wind(direction: direction, speed: speed, temperature: temperature)
      default:
        throw DecodingError.dataCorruptedError(
          forKey: .type,
          in: container,
          debugDescription: "Unknown enum value"
        )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
      case .lightAndVariable:
        try container.encode("lightAndVariable", forKey: .type)
      case let .wind(direction, speed, temperature):
        try container.encode("wind", forKey: .type)
        try container.encode(direction, forKey: .direction)
        try container.encode(speed, forKey: .speed)
        try container.encode(temperature, forKey: .temperature)
    }
  }

  enum CodingKeys: String, CodingKey {
    case type, direction, speed, temperature
  }
}
