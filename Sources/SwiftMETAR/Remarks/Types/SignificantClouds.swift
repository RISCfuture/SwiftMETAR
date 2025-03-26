public extension Remark {

    /// Human-observed significant clouds.
    enum SignificantCloudType: String, Codable, Equatable, RegexCases, Sendable {

        /// Cumulonimbus
        case cb = "CB"

        /// Cumulonimbus mammatus
        case cbMam = "CBMAM"

        /// Cumulus congestus (towering cumulus)
        case cuCon = "TCU"

        /// Altocumulus castellanus
        case acCas = "ACC"

        /// Stratocumulus lenticularis (stratocumulus standing lenticular)
        case scLen = "SCSL"

        /// Altocumulus lenticularis (altocumulus standing lenticular)
        case acLen = "ACSL"

        /// Cirrocumulus lenticularis (cirrocumulus standing lenticular)
        case ccLen = "CCSL"

        /// Rotor or roll cloud
        case rotor = "ROTOR CLD"
    }
}
