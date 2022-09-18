extension Remark {
    
    /// Temperature extremes for an observation period.
    public enum Extreme: String, Codable, Equatable, RawRepresentable, CaseIterable {
        
        /// Low-temperature extreme
        case low = "2"
        
        /// High-temperature extreme
        case high = "1"
    }
}
