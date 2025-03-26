public extension Remark {

    /// Precipitation observed by a human observer.
    enum ObservedPrecipitationType: String, Codable, Equatable, RegexCases, Sendable {
        case virga = "VIRGA"
        case showers = "SH"
        case showeringRain = "SHRA"
    }
}
