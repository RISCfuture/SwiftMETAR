extension Remark {
    
    /// Human-observed significant clouds.
    public enum SignificantCloudType: String, Codable, Equatable, RawRepresentable, CaseIterable {
        
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
        case rotor = "ROTORCLD"
    }
}
