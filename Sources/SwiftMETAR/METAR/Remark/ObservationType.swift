extension Remark {
    
    /// METAR observation types.
    public enum ObservationType: String, Codable, Equatable, RawRepresentable {
        
        /// Automated observation station.
        case automated = "AO1"
        
        /// Automated observation station with precipitation recording.
        case automatedWithPrecipitation = "AO2"
    }
}
