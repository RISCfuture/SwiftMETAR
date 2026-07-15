import Foundation

extension Remark {

  static func coded(seaLevelPressure pressure: Float?) -> String {
    guard let pressure else { return "SLPNO" }
    let digits = Int(((pressure - 900) * 10).rounded())
    return "SLP\(String(format: "%03d", digits))"
  }

  static func coded(pressureTendency character: PressureCharacter, change: Float) -> String {
    let magnitude = Int((abs(change) * 10).rounded())
    return "5\(character.rawValue)\(String(format: "%03d", magnitude))"
  }

  static func coded(rapidPressureChange change: RapidPressureChange) -> String {
    change.rawValue
  }

  static func coded(temperatureDewpoint temperature: Float, dewpoint: Float?) -> String {
    let dewpointCode = dewpoint.map(codedTenths) ?? "////"
    return "T\(codedTenths(temperature))\(dewpointCode)"
  }

  static func coded(sixHourTemperatureExtreme type: Extreme, temperature: Float) -> String {
    "\(type.rawValue)\(codedTenths(temperature))"
  }

  static func coded(dailyTemperatureExtremes low: Float, high: Float) -> String {
    "4\(codedTenths(high))\(codedTenths(low))"
  }

  static func coded(relativeHumidity percent: UInt) -> String {
    "RH/\(percent)"
  }

  /// Encodes a signed temperature in tenths, prefixed by a sign flag
  /// (`"1"` negative, `"0"` non-negative) and zero-padded to three digits,
  /// e.g. `-0.6` → `"1006"`.
  private static func codedTenths(_ value: Float) -> String {
    let sign = value < 0 ? "1" : "0"
    let magnitude = Int((abs(value) * 10).rounded())
    return "\(sign)\(String(format: "%03d", magnitude))"
  }
}
