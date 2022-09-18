import Foundation

/// Forecasted turbulence conditions in a military TAF.
public struct Turbulence: Codable, Equatable {
    
    /// The location associated with the turbulence.
    public var location: Location?
    
    /// The intensity of turbulence forecasted.
    public var intensity: Intensity
    
    /// The frequency of turbulence forecasted.
    public var frequency: Frequency?
    
    /// The base of the turbulence layer, in feet AGL.
    public var base: UInt
    
    /// The depth of the turbulence layer, in feet.
    public var depth: UInt
    
    /// The top of the turbulence layer, in feet AGL.
    public var top: UInt { base + depth }
    
    /// Turbulence locations
    public enum Location: Codable {
        
        /// Clear-air turbulence
        case clearAir
        
        /// Turbulence inside clouds
        case inCloud
    }
    
    /// Turbulence intensities
    public enum Intensity: Codable {
        
        /// No turbulence is forecasted.
        case none
        
        /// Slight erratic changes in altitude and/or attitude.
        case light
        
        /// Change in altitude and/or attitude, but the aircraft remains in
        /// positive control at all times.
        case moderate
        
        /// Large, abrupt changes in altitude and/or attitude. Aircraft may be
        /// momentarily out of control.
        case severe
        
        /// Aircraft is violently tossed about and practically impossible to
        /// control. May cause structural damage.
        case extreme
    }
    
    /// Turbulence frequencies
    public enum Frequency: Codable {
        
        /// Turbulence will occur less than 1/3 of the time.
        case occasional
        
        /// Turbulence will occur more than 1/3 of the time.
        case frequent
    }
}
