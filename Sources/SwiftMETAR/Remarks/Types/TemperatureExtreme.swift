public extension Remark {

    /// Temperature extremes for an observation period.
    enum Extreme: String, Codable, Equatable, RegexCases, Sendable {

        /// Low-temperature extreme
        case low = "2"

        /// High-temperature extreme
        case high = "1"
    }
}
