extension Remark {
    
    /// Locations where visibility can be observed from.
    public enum VisibilitySource: String, Codable, Equatable, RawRepresentable, CaseIterable {
        
        /// Visibility observed from the control tower.
        case tower = "TWR"
        
        /// Visibility observed from the surface.
        case surface = "SFC"
    }
}
