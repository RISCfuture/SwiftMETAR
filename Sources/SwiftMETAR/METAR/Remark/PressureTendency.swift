extension Remark {
    
    /// A pressure trend.
    public enum PressureCharacter: String, Codable, Equatable, RawRepresentable, CaseIterable {
        
        /// Increasing, then decreasing
        case inflectedDown = "0"
        
        /// Increasing, then then steady, or increasing then increasing more
        /// slowly
        case deceleratingUp = "1"
        
        /// Increasing steadily or unsteadily
        case steadyUp = "2"
        
        /// Decreasing or steady, then increasing; or increasing, then
        /// increasing more rapidly
        case acceleratingUp = "3"
        
        /// Steady
        case zero = "4"
        
        /// Decreasing, then increasing
        case inflectedUp = "5"
        
        /// Decreasing then steady; or decreasing then decreasing more slowly
        case deceleratingDown = "6"
        
        /// Decreasing steadily or unsteadily
        case steadyDown = "7"
        
        /// Steady or increasing, then decreasing; or decreasing then decreasing
        /// more rapidly
        case acceleratingDown = "8"
    }
}
