extension Remark {
    
    /// Precipitation observed by a human observer.
    public enum ObservedPrecipitationType: String, Codable, Equatable, RawRepresentable, CaseIterable {
        case virga = "VIRGA"
        case showers = "SH"
        case showeringRain = "SHRA"
    }
}
