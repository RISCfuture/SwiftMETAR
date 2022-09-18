extension Remark {
    
    /// A fleet naval weather center that issued a naval forecast.
    public enum NavalWeatherCenter: String, Codable, Equatable, RawRepresentable, CaseIterable {
        
        /// Fleet Naval Weather Center San Diego
        case sanDiego = "S"
        
        /// Fleet Naval Weather Center Norfolk
        case norfolk = "N"
    }
}
