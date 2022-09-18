import Foundation

/// Forecasted icing conditions in a military TAF.
public struct Icing: Codable, Equatable {
    
    /// The type of icing forecasted.
    public var type: IcingType
    
    /// The base of the icing layer, in feet AGL.
    public var base: UInt
    
    /// The depth of the icing layer, in feet.
    public var depth: UInt
    
    /// The top of the icing layer, in feet AGL.
    public var top: UInt { base + depth }
    
    /// Type of icing forecasted.
    public enum IcingType: String, RawRepresentable, CaseIterable, Codable, Equatable {
        
        /// Trace icing (USAF forecasts) or no icing (WMO forecasts)
        case traceNone = "0"
        
        /// Light mixed icing
        case lightMixed = "1"
        
        /// Light rime icing in cloud
        case lightRime = "2"
        
        /// Light clear icing in precipitation
        case lightClear = "3"
        
        /// Moderate mixed icing
        case moderateMixed = "4"
        
        /// Moderate rime icing in cloud
        case moderateRime = "5"
        
        /// Moderate clear icing in precipitation
        case moderateClear = "6"
        
        /// Severe mixed icing
        case severeMixed = "7"
        
        /// Severe rime icing in cloud
        case severeRime = "8"
        
        /// Severe clear icing in precipitation
        case severeClear = "9"
    }
}
