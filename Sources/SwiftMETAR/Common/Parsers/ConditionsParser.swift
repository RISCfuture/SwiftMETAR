import Foundation

fileprivate let types = Condition.CeilingType.allCases
    .map { NSRegularExpression.escapedPattern(for: $0.rawValue) }
    .joined(separator: "|")
fileprivate let conditionsRxStr = "^(FEW|SCT|BKN|OVC|VV)(\\d+)(\(types))?$"
fileprivate let conditionsRx = try! NSRegularExpression(pattern: conditionsRxStr, options: [])

func parseConditions(_ parts: inout Array<String.SubSequence>) throws -> Array<Condition> {
    if parts.isEmpty { return [] }
    
    var conditions = Array<Condition>()
    
    while true {
        if parts.isEmpty { return conditions }
        let condStr = String(parts[0])
        
        if condStr == "SKC" {
            parts.removeFirst()
            return [.skyClear]
        }
        if condStr == "CLR" || condStr == "NCD" {
            parts.removeFirst()
            return [.clear]
        }
        if condStr == "NSC" {
            parts.removeFirst()
            return [.noSignificantClouds]
        }
        
        if let match = conditionsRx.firstMatch(in: condStr, options: [], range: condStr.nsRange) {
            parts.removeFirst()
            
            let coverage = condStr.substring(with: match.range(at: 1))
            
            guard let flightLevel = UInt(condStr.substring(with: match.range(at: 2))) else {
                throw Error.invalidConditions(condStr)
            }
            let height = flightLevel*100
            
            var type: Condition.CeilingType? = nil
            let typeRange = match.range(at: 3)
            if typeRange.location != NSNotFound {
                guard coverage != "VV" else { throw Error.invalidConditions(condStr) }
                let typeStr = String(condStr.substring(with: typeRange))
                type = Condition.CeilingType(rawValue: typeStr)
                guard type != nil else {
                    throw Error.invalidConditions(condStr)
                }
            }
            
            switch coverage {
                case "FEW": conditions.append(.few(height, type: type))
                case "SCT": conditions.append(.scattered(height, type: type))
                case "BKN": conditions.append(.broken(height, type: type))
                case "OVC": conditions.append(.overcast(height, type: type))
                case "VV": conditions.append(.indefinite(height))
                default: throw Error.invalidConditions(condStr)
            }
        }
        else { return conditions }
    }
}
