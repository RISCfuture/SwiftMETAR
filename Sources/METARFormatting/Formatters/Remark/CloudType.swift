import Foundation
import SwiftMETAR

public extension Remark.LowCloudType {
    
    /// Formatter for `Remark.LowCloudType`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: Remark.LowCloudType) -> String {
            switch value {
                case .obscured: String(localized: "obscured", comment: "low cloud type")
                case .none: String(localized: "none observed", comment: "low cloud type")
                case .cuHumFra: String(localized: "cumulus humilis/fractus", comment: "low cloud type")
                case .cuMedCon: String(localized: "cumulus mediocris or congestus", comment: "low cloud type")
                case .cbCal: String(localized: "cumulonimbus calvus", comment: "low cloud type")
                case .scCugen: String(localized: "stratocumulus cumulogenitus", comment: "low cloud type")
                case .scNonCugen: String(localized: "stratocumulus non-cumulogenitus", comment: "low cloud type")
                case .stNebFra: String(localized: "stratus nebulosus/fractus", comment: "low cloud type")
                case .stCuFra: String(localized: "stratus/cumulus fractus", comment: "low cloud type")
                case .cuSc: String(localized: "cumulus stratocumulus", comment: "low cloud type")
                case .cbCap: String(localized: "cumulonimbus capillatus", comment: "low cloud type")
            }
        }
    }
}

public extension Remark.MiddleCloudType {
    
    /// Formatter for `Remark.MiddleCloudType`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: Remark.MiddleCloudType) -> String {
            switch value {
                case .obscured: String(localized: "obscured", comment: "middle cloud type")
                case .none: String(localized: "none observed", comment: "middle cloud type")
                case .asTr: String(localized: "altostratus translucidus", comment: "middle cloud type")
                case .asOp: String(localized: "altostratus opacus", comment: "middle cloud type")
                case .acTr: String(localized: "altocumulus translucidus", comment: "middle cloud type")
                case .acChanging: String(localized: "changing altocumulus", comment: "middle cloud type")
                case .ac: String(localized: "altocumulus", comment: "middle cloud type")
                case .acCugenCbgen: String(localized: "altocumulus cumulogenitus/cumulonimbogenitus", comment: "middle cloud type")
                case .acAsNsOp: String(localized: "altocumulus translucidus/opacus", comment: "middle cloud type")
                case .acCasFlo: String(localized: "altocumulus castellanus/floccus", comment: "middle cloud type")
                case .acChaoticSky: String(localized: "altocumulus chaotic sky", comment: "middle cloud type")
            }
        }
    }
}


public extension Remark.HighCloudType {
    
    /// Formatter for `Remark.HighCloudType`
    struct FormatStyle: Foundation.FormatStyle, Sendable {
        public func format(_ value: Remark.HighCloudType) -> String {
            switch value {
                case .obscured: String(localized: "obscured", comment: "high cloud type")
                case .none: String(localized: "none observed", comment: "high cloud type")
                case .ciFibUnc: String(localized: "cirrus fibratus/uncinus", comment: "high cloud type")
                case .ciSpi: String(localized: "cirrus spissatus non-cumulonimbogenitus/castellanus/floccus", comment: "high cloud type")
                case .ciSpiCb: String(localized: "cirrus spissatus cumulonimbogenitus", comment: "high cloud type")
                case .ciUncFib: String(localized: "cirrus uncinus/fibratus", comment: "high cloud type")
                case .csLess45: String(localized: "cirrostratus extending <45° above the horizon", comment: "high cloud type")
                case .csGreater45: String(localized: "cirrostratus extending >45° above the horizon", comment: "high cloud type")
                case .cs: String(localized: "cirrostratus", comment: "high cloud type")
                case .csPartial: String(localized: "partial cirrostratus", comment: "high cloud type")
                case .cc: String(localized: "cirrocumulus", comment: "high cloud type")
            }
        }
    }
}

public extension FormatStyle where Self == Remark.LowCloudType.FormatStyle {
    static var lowClouds: Self { .init() }
}

public extension FormatStyle where Self == Remark.MiddleCloudType.FormatStyle {
    static var middleClouds: Self { .init() }
}

public extension FormatStyle where Self == Remark.HighCloudType.FormatStyle {
    static var highClouds: Self { .init() }
}
