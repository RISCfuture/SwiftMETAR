/// A runway visibility report made by a transmissometer (or human observer).
public struct RunwayVisibility: Codable, Equatable {
    
    /// The ID of the runway (e.g., "21L").
    public let runwayID: String
    
    /// The visibility in the approach direction along that runway.
    public let visibility: Visibility
}
