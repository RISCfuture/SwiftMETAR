import Foundation

/// An abrupt change in wind direction and/or speed at a certain altitude.
public struct Windshear: Codable, Equatable {
    
    /// The height, in feet above ground, where the windshear occurs.
    public let height: UInt16
    
    /// The new wind direction and speed above `height`.
    public let wind: Wind
}
