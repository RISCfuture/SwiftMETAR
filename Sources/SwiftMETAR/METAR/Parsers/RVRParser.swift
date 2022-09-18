import Foundation
import Regex

fileprivate let visRx = Regex(#"^R([A-Z0-9]+)\/([MP]?)(\d+)(FT|M)$"#)
fileprivate let variableRx = Regex(#"^R([A-Z0-9]+)\/([MP]?)(\d+)V([MP]?)(\d+)(FT|M)$"#)

func parseRunwayVisibility(_ parts: inout Array<String.SubSequence>) throws -> Array<RunwayVisibility> {
    var visibilities = Array<RunwayVisibility>()
    
    while true {
        if parts.isEmpty { return visibilities }
        let visStr = String(parts[0])
        
        switch visibilityType(visStr) {
            case let .vis(match):
                parts.removeFirst()
                
                guard let runway = match.captures[0],
                      let bound = match.captures[1],
                      let quantityStr = match.captures[2],
                      let quantity = UInt16(quantityStr),
                      let units = match.captures[3] else { throw Error.invalidVisibility(visStr) }
                
                let value = visibilityValue(quantity, bound: bound, units: units)
                visibilities.append(RunwayVisibility(runwayID: runway, visibility: value))
                
            case let .variable(match):
                parts.removeFirst()
                
                guard let runway = match.captures[0],
                      let lowBound = match.captures[1],
                      let lowQtyStr = match.captures[2],
                      let lowQuantity = UInt16(lowQtyStr),
                      let highQtyStr = match.captures[4],
                      let highQuantity = UInt16(highQtyStr),
                      let highBound = match.captures[3],
                      let units = match.captures[5] else { throw Error.invalidVisibility(visStr) }
                
                let low = visibilityValue(lowQuantity, bound: lowBound, units: units)
                let high = visibilityValue(highQuantity, bound: highBound, units: units)
                visibilities.append(RunwayVisibility(runwayID: runway, visibility: .variable(low, high)))
                
            case .none: return visibilities
        }
    }
}

fileprivate func visibilityValue(_ value: UInt16, bound: String, units: String) -> Visibility {
    switch bound {
        case "M":
            switch units {
                case "M":
                    return .lessThan(.meters(value))
                case "FT":
                    return .lessThan(.feet(value))
                default: preconditionFailure("Unknown units")
            }
        case "P":
            switch units {
                case "M":
                    return .greaterThan(.meters(value))
                case "FT":
                    return .greaterThan(.feet(value))
                default: preconditionFailure("Unknown units")
            }
        case "":
            switch units {
                case "M":
                    return .equal(.meters(value))
                case "FT":
                    return .equal(.feet(value))
                default: preconditionFailure("Unknown units")
            }
        default: preconditionFailure("Unknown bounds")
    }
}

fileprivate enum VisibilityStringType {
    case vis(match: MatchResult)
    case variable(match: MatchResult)
    case none
}

fileprivate func visibilityType(_ string: String) -> VisibilityStringType {
    if let match = visRx.firstMatch(in: string) {
        return .vis(match: match)
    } else if let match = variableRx.firstMatch(in: string) {
        return .variable(match: match)
    } else {
        return .none
    }
}
