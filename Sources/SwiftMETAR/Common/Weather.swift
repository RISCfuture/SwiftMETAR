/**
 Weather phenomena present at the time of an observation. Weather phenomena can
 be precipitation, particulates in the air, or other visible dynamic weather
 activity.
 
 Weather phenomena are qualified by their intensity (light, moderate, heavy) and
 a descriptor, such as "freezing" or "blowing". Descriptors are only applied to
 precipitation and particulates ("freezing snow", "blowing sand"), as there is
 no such thing as a freezing tornado, and a blowing tornado goes without saying.
 
 Along with the intensities of light, moderate, and heavy, a "pseudo-intensity"
 titled `vicinity` represents weather phenomena observed outside of five miles
 from the reporting station, but still of relevance to pilots.
 
 "Thunderstorms" can be both a descriptor and a phenomenon. Thunderstorms in the
 vicinity are reported as a phenomenon, but thunderstorms overhead will be
 reported as a descriptor, in combination with the precipitation they generate,
 such as thunderstorm-associated rain or hail.
 
 Only one descriptor can be applied to each instance, but each instance can have
 multiple phenomena associated with it; for example, "showering rain and snow".
 If there are additional phenomena not associated with the showering rain and
 snow, such as a fog layer, that will be reported as a separate `Weather`
 instance.
 */

public struct Weather: Codable, Equatable {
    
    /// The intensity of the phenomena.
    public let intensity: Intensity
    
    /// Any qualifier applied to the phenomena.
    public let descriptor: Descriptor?
    
    /// The phenomena observed.
    public let phenomena: Set<Phenomenon>
    
    /// Returns true if this instance is reporting tornadic activity (funnel
    /// cloud with an intensity of heavy).
    public var isTornado: Bool {
        intensity == .heavy && phenomena.contains(.funnelCloud)
    }
    
    /// The intensity associated with a phenomenon.
    public enum Intensity: String, Codable, CaseIterable {
        case light = "-"
        case moderate = ""
        case heavy = "+"
        
        /**
         This "pseudo-intensity" is applied to phenomena that are not occuring
         within 5 miles of the reporting station, but are still of relevance.
         */
        case vicinity = "VC"
        
        /// Another "pseudo-intensity" for light phenomena in the vicinity.
        case vicinityLight = "-VC"
        
        /// Another "pseudo-intensity" for heavy phenomena in the vicinity.
        case vicinityHeavy = "+VC"
    }
    
    /// Qualifiers for precipitation phenomena. Most are not applied to
    /// phenomena that aren't a form of precipitation.
    public enum Descriptor: String, Codable, CaseIterable {
        
        /// Visibility impedance (e.g., fog) has a low ceiling.
        case shallow = "MI"
        
        /// Phenomenon is only occurring over a part of the observation area.
        case partial = "PA"
        
        /// Phenomenon does not occur continuously throughout the observation
        /// area.
        case patchy = "BC"
        
        /// Visibility impedance (e.g. fog) occurs close to the ground, pushed
        /// along by the wind.
        case lowDrifting = "DR"
        
        /// Precipitation does not originate from overhead, but is being blown
        /// in over the ground from somewhere else.
        case blowing = "BL"
        
        /// Precipitation is occuring with periodic changes in intensity.
        case showering = "SH"
        
        /// Precipitation is associated with a thunderstorm.
        case thunderstorms = "TS"
        
        /// Precipitation is freezing upon contact with a surface.
        case freezing = "FZ"
    }
    
    /// An observed weather phenomenon. These phenomena are either
    /// precipitation, particulates suspended in the air, or dynamic weather
    /// phenomena.
    public enum Phenomenon: String, Codable, CaseIterable {
        
        /// Small raindrops that are light enough to be carried by the wind.
        case drizzle = "DZ"
        
        /// Larger raindrops that fall to the ground.
        case rain = "RA"
        
        /// Frozen ice that crystalizes around a nucleating site.
        case snow = "SN"
        
        /// Very small ice particulates that do not break on impact.
        case snowGrains = "SG"
        
        /// Solid ice crystals.
        case iceCrystals = "IC"
        
        /// Rain that has frozen during its fall.
        case icePellets = "PL"
        
        /// Large ice crystals created when rain is lifted by convective
        /// activity.
        case hail = "GR"
        
        /// Snow grains and small hailstones.
        case snowPellets = "GS"
        
        /// Precipitation was detected by a sensor but its type could not be
        /// determined.
        case unknownPrecipitation = "UP"
        
        /// Visibility obscured by small raindrops too light to fall.
        case mist = "BR"
        
        /// Visibility obscured by microscropic drops forming a surface cloud.
        case fog = "FG"
        
        /// Visibility obscured by combustion byproducts.
        case smoke = "FU"
        
        /// Visibility obscured by ash from a volcanic eruption.
        case volcanicAsh = "VA"
        
        /// Visibility obscured by widespread dust lifted by the wind.
        case dust = "DU"
        
        /// Visibility obscured by sand lifted by the wind.
        case sand = "SA"
        
        /// Visibility obscured by microscopic particulates, usually pollution.
        case haze = "HZ"
        
        /// Visibility obscured by water spray from a nearby ocean or lake.
        case spray = "PY"
        
        /// Dust whirls, sand whirls, or dust devils.
        case dustWhirls = "PO"
        
        /// Squalls caused by frontal action.
        case squalls = "SQ"
        
        /// Funnel cloud, tornado, or waterspout.
        case funnelCloud = "FC"
        
        /// Powerful winds carrying large amounts of sand into the air.
        case sandstorm = "SS"
        
        /// Powerful winds carrying large amounts of dust into the air.
        case dustStorm = "DS"
        
        /// Convective activity producing thunderstorms.
        case thunderstorm = "TS"
    }
}
