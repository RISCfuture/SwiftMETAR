extension Remark {
    
    /// Precipitation observed by a human observer.
    public enum ObservedPrecipitationType: String, Codable, Equatable, RegexCases, Sendable {
        case virga = "VIRGA"
        case showers = "SH"
        case showeringRain = "SHRA"
    }
}
