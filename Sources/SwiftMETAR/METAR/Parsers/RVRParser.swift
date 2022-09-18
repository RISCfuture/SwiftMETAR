import Foundation

fileprivate let visRxStr = #"^R([A-Z0-9]+)\/([MP]?)(\d+)(FT|M)$"#
fileprivate let visRx = try! NSRegularExpression(pattern: visRxStr, options: [])
fileprivate let variableRxStr = #"^R([A-Z0-9]+)\/([MP]?)(\d+)V([MP]?)(\d+)(FT|M)$"#
fileprivate let variableRx = try! NSRegularExpression(pattern: variableRxStr, options: [])

func parseRunwayVisibility(_ parts: inout Array<String.SubSequence>) throws -> Array<RunwayVisibility> {
    var visibilities = Array<RunwayVisibility>()
    
    while true {
        if parts.isEmpty { return visibilities }
        let visStr = String(parts[0])
        
        switch visibilityType(visStr) {
            case let .vis(match):
                parts.removeFirst()
                let runway = String(visStr.substring(with: match.range(at: 1)))
                
                let bound = visStr.substring(with: match.range(at: 2))
                guard let quantity = UInt16(visStr.substring(with: match.range(at: 3))) else {
                    throw Error.invalidVisibility(visStr)
                }
                let units = visStr.substring(with: match.range(at: 4))
                let value = visibilityValue(quantity, bound: bound, units: units)
                
                visibilities.append(RunwayVisibility(runwayID: runway, visibility: value))
                
            case let .variable(match):
                parts.removeFirst()
                let runway = String(visStr.substring(with: match.range(at: 1)))
                
                let lowBound = visStr.substring(with: match.range(at: 2))
                guard let lowQuantity = UInt16(visStr.substring(with: match.range(at: 3))) else {
                    throw Error.invalidVisibility(visStr)
                }
                let highBound = visStr.substring(with: match.range(at: 4))
                guard let highQuantity = UInt16(visStr.substring(with: match.range(at: 5))) else {
                    throw Error.invalidVisibility(visStr)
                }
                let units = visStr.substring(with: match.range(at: 6))
                let low = visibilityValue(lowQuantity, bound: lowBound, units: units)
                let high = visibilityValue(highQuantity, bound: highBound, units: units)
                
                visibilities.append(RunwayVisibility(runwayID: runway, visibility: .variable(low, high)))
                
            case .none: return visibilities
        }
    }
}

fileprivate func visibilityValue(_ value: UInt16, bound: String.SubSequence, units: String.SubSequence) -> Visibility {
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
    case vis(match: NSTextCheckingResult)
    case variable(match: NSTextCheckingResult)
    case none
}

fileprivate func visibilityType(_ string: String) -> VisibilityStringType {
    if let match = visRx.firstMatch(in: string, options: [], range: string.nsRange) {
        return .vis(match: match)
    } else if let match = variableRx.firstMatch(in: string, options: [], range: string.nsRange) {
        return .variable(match: match)
    } else {
        return .none
    }
}
