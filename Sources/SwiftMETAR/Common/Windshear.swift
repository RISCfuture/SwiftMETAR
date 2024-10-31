import Foundation

/// An abrupt change in wind direction and/or speed at a certain altitude.
public struct Windshear: Codable, Equatable, Sendable {
    
    /// The height, in feet above ground, where the windshear occurs.
    public let height: UInt16
    
    /// The new wind direction and speed above ``height``.
    public let wind: Wind
    
    /// The height as a `Measurement`, which can be converted to other units.
    public var heightMeasurement: Measurement<UnitLength> {
        .init(value: Double(height), unit: .feet)
    }
}
