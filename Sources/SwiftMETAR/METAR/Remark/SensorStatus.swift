extension Remark {
    
    /// Types of automated weather sesons that can become inoperative.
    public enum SensorType: Codable, Equatable {
        
        /// Runway visual range transmissometer is inoperative.
        case RVR
        
        /// Ceilometer is inoperative.
        case presentWeather
        
        /// Rain accumulation sensor is inoperative.
        case rain
        
        /// Freezing rain accumulation sensor is inoperative.
        case freezingRain
        
        /// Lightning sensor is inoperative.
        case lightning
        
        /**
         A visibility sensor at a secondary location is inoperative.
         
         - Parameter location: The sensor location (usually a runway name or
         quadrant direction).
         */
        case secondaryVisibility(location: String)
        
        /**
         A ceilometer at a secondary location is inoperative.
         
         - Parameter location: The sensor location.
         */
        case secondaryCeiling(location: String)
    }
}
