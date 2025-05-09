public extension Remark {

    /// METAR observation types.
    enum ObservationType: String, Codable, Equatable, RawRepresentable, Sendable {

        /// Automated observation station.
        case automated = "AO1"

        /// Automated observation station with precipitation recording.
        case automatedWithPrecipitation = "AO2"
    }
}
