public extension Remark {

    /// A fleet naval weather center that issued a naval forecast.
    enum NavalWeatherCenter: String, Codable, Equatable, RegexCases, Sendable {

        /// Fleet Naval Weather Center San Diego
        case sanDiego = "S"

        /// Fleet Naval Weather Center Norfolk
        case norfolk = "N"
    }
}
