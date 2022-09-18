extension Remark {
    
    /// Rapid pressure change types.
    public enum RapidPressureChange: String, Codable, Equatable, RawRepresentable, CaseIterable {
        
        /// Pressure rising rapidly.
        case rising = "PRESRR"
        
        /// Pressure falling rapidly.
        case falling = "PRESFR"
    }
}
