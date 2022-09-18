extension Remark {
    
    /// Types of lightning.
    public enum LightningType: String, Codable, RawRepresentable, CaseIterable {
        
        /// Lightning occurring between cloud and ground.
        case cloudToGround = "CG"
        
        /// Lightning which takes place within the cloud.
        case withinCloud = "IC"
        
        /// Streaks of lightning reaching from one cloud to another.
        case cloudToCloud = "CC"
        
        /// Streaks of lightning which pass from a cloud to the air, but do not
        /// strike the ground.
        case cloudToAir = "CA"
    }
}
