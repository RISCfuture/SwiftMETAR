public import Foundation

/// An abrupt change in wind direction and/or speed at a certain altitude.
public struct Windshear: CodedRepresentable, Equatable, Sendable {

  /// The height, in feet above ground, where the windshear occurs.
  public let height: UInt16

  /// The new wind direction and speed above ``height``.
  public let wind: Wind

  /// The height as a `Measurement`, which can be converted to other units.
  public var heightMeasurement: Measurement<UnitLength> {
    .init(value: Double(height), unit: .feet)
  }

  /**
   The coded representation of this windshear, e.g. `"WS020/24025KT"`. The
   height is emitted in hundreds of feet, zero-padded to three digits, followed
   by the wind's ``Wind/codedString``.
   */
  public var codedString: String {
    "WS\(String(format: "%03d", height / 100))/\(wind.codedString)"
  }

  /**
   Parses a coded windshear string into a value.

   - Parameter coded: The coded string, e.g. `"WS020/24025KT"`.
   - Throws: ``Error/invalidWindshear(_:)`` if `coded` is not a valid windshear
             representation.
   */
  public init(coded: String) throws {
    var parts = coded.split(whereSeparator: \.isWhitespace)
    guard let windshear = try WindshearParser().parse(&parts), parts.isEmpty else {
      throw Error.invalidWindshear(coded)
    }
    self = windshear
  }

  init(height: UInt16, wind: Wind) {
    self.height = height
    self.wind = wind
  }
}
