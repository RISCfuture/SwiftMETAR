extension Remark {
    
    /// Low-level (below 6500 feet AGL) cloud types.
    public enum LowCloudType: String, Codable, RawRepresentable {
        
        /// Observer was unable to see low clouds due to obscuration.
        case obscured = "/"
        
        /// No low clouds were observed.
        case none = "0"
        
        /// Cumulus humilis/fractus of dry weather predominates.
        case cuHumFra = "1"
        
        /// There are Cumulus mediocris or congestus, all having their bases at
        /// the same level.
        case cuMedCon = "2"
        
        /// Cumulonimbus has not yet become clearly fibrous or striated
        /// (Cumulonimbus calvus).
        case cbCal = "3"
        
        /// Stratocumulus formed by spreading out of Cumulus is present
        /// (Stratocumulus cumulogenitus).
        case scCugen = "4"
        
        /// Stratocumulus non-cumulogenitus predominates.
        case scNonCugen = "5"
        
        /// Stratus nebulosus/fractus of dry weather predominates.
        case stNebFra = "6"
        
        /// Stratus fractus or Cumulus fractus of wet weather predominates.
        case stCuFra = "7"
        
        /// Simultaneous occurrence of Cumulus and Stratocumulus with bases at
        /// different levels are present.
        case cuSc = "8"
        
        /// At least a part of one Cumulonimbus present is of the species
        /// capillatus.
        case cbCap = "9"
    }
    
    /// Mid-level (6500–20,000 feet AGL) cloud types.
    public enum MiddleCloudType: String, Codable, RawRepresentable {
        
        /// Observer was unable to see middle clouds due to obscuration.
        case obscured = "/"
        
        /// No middle clouds were observed.
        case none = "0"
        
        /// The greater part of Altostratus is semi-transparent (Altostratus
        /// translucidus).
        case asTr = "1"
        
        /// The greater part of Altostratus is dense enough to hide the Sun or
        /// Moon completely or if there is Nimbostratus (Altostratus opacus).
        case asOp = "2"
        
        /// Altocumulus at a single level is predominantly translucidus.
        case acTr = "3"
        
        /// Altocumulus patches are continuously changing.
        case acChanging = "4"
        
        /// Altocumulus is progressively invading the sky.
        case ac = "5"
        
        /// Altocumulus cumulogenitus or cumulonimbogenitus is present.
        case acCugenCbgen = "6"
        
        /// * Altocumulus is coexisting with Altostratus or Nimbostratus,
        /// * Altocumulus (of the variety translucidus and/or opacus) are at two
        ///   or more levels, or
        /// * Altocumulus at a single level is predominantly opacus.
        case acAsNsOp = "7"
        
        /// Altocumulus castellanus or floccus is present.
        case acCasFlo = "8"
        
        /// Altocumulus of a chaotic sky is present.
        case acChaoticSky = "9"
    }
    
    /// High-level (above 20,000 feet AGL) cloud types.
    public enum HighCloudType: String, Codable, RawRepresentable {
        
        /// Observer was unable to see high clouds due to obscuration.
        case obscured = "/"
        
        /// No high clouds were observed.
        case none = "0"
        
        /// Cirrus fibratus and/or uncinus.
        case ciFibUnc = "1"
        
        /// The sky cover of Cirrus spissatus non-cumulonimbogenitus and Cirrus
        /// castellanus and/or floccus predominates.
        case ciSpi = "2"
        
        /// One of the Cirrus spissatus clouds originates from a Cumulonimbus.
        case ciSpiCb = "3"
        
        /// Cirrus uncinus and/or fibratus is progressively invading the sky.
        case ciUncFib = "4"
        
        /// Cirrostratus is progressively invading the sky and extends less than
        /// 45° above the horizon.
        case csLess45 = "5"
        
        /// Cirrostratus is progressively invading the sky and extends more than
        /// 45° above the horizon but is not covering the whole sky.
        case csGreater45 = "6"
        
        /// Cirrostratus is covering the whole sky.
        case cs = "7"
        
        /// Cirrostratus is not invading the sky and not entirely covering it.
        case csPartial = "8"
        
        /// Cirrocumulus is alone or with other cirriform cloud but predominates
        /// the sky.
        case cc = "9"
    }
}
