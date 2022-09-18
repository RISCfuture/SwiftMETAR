import Foundation
import NumericAnnex

fileprivate let fractionalString = #"^([PM])?(\d+)\/(\d+)SM$"#
fileprivate let fractionalRx = try! NSRegularExpression(pattern: fractionalString, options: [])
fileprivate let integerString = #"^([PM])?(\d+)(SM|FT|M)?$"#
fileprivate let integerRx = try! NSRegularExpression(pattern: integerString, options: [])
fileprivate let notRecordedRxStr = #"^\/{2,}(SM|FT|M)$"#
fileprivate let notRecordedRx = try! NSRegularExpression(pattern: notRecordedRxStr, options: [])

func parseVisibility(_ parts: inout Array<String.SubSequence>) throws -> Visibility? {
    guard !parts.isEmpty else { return nil }
    let vizStr = String(parts[0])
    
    if vizStr == "10SM" {
        parts.removeFirst()
        return .greaterThan(.statuteMiles(10))
    }
    if vizStr == "9999" {
        parts.removeFirst()
        return .greaterThan(.meters(9999))
    }
    
    if notRecordedRx.firstMatch(in: vizStr, options: [], range: vizStr.nsRange) != nil {
        parts.removeFirst()
        return nil
    }
    
    if let whole = UInt16(vizStr) {
        parts.removeFirst()
        if parts.isEmpty { return .equal(.meters(whole)) }
        let vizStr2 = String(parts[0])
        
        if let fractionalParts = try parseFraction(vizStr2) {
            parts.removeFirst()
            
            let value = Ratio(numerator: Int(whole), denominator: 1) + fractionalParts.value
            switch fractionalParts.rangeValue {
                case .lessThan: return .lessThan(.statuteMiles(value))
                case .equal: return .equal(.statuteMiles(value))
                case .greaterThan: return .greaterThan(.statuteMiles(value))
            }
        } else {
            return .equal(.meters(whole))
        }
    } else if let fractionalParts = try parseFraction(vizStr) {
        parts.removeFirst()
        switch fractionalParts.rangeValue {
            case .lessThan: return .lessThan(.statuteMiles(fractionalParts.value))
            case .equal: return .equal(.statuteMiles(fractionalParts.value))
            case .greaterThan: return .greaterThan(.statuteMiles(fractionalParts.value))
        }
    } else if let integerParts = try parseInteger(vizStr) {
        parts.removeFirst()
        
        switch integerParts.units {
            case "SM":
                let value = Ratio(numerator: Int(integerParts.value), denominator: 1)
                switch integerParts.rangeValue {
                    case .lessThan: return .lessThan(.statuteMiles(value))
                    case .equal: return .equal(.statuteMiles(value))
                    case .greaterThan: return .greaterThan(.statuteMiles(value))
                }
            case "M":
                switch integerParts.rangeValue {
                    case .lessThan: return .lessThan(.meters(integerParts.value))
                    case .equal: return .equal(.meters(integerParts.value))
                    case .greaterThan: return .greaterThan(.meters(integerParts.value))
                }
            case "FT":
                switch integerParts.rangeValue {
                    case .lessThan: return .lessThan(.feet(integerParts.value))
                    case .equal: return .equal(.feet(integerParts.value))
                    case .greaterThan: return .greaterThan(.feet(integerParts.value))
                }
            default: preconditionFailure("Unknown units")
        }
    } else {
        return nil
    }
}

fileprivate enum RangeValue {
    case lessThan, equal, greaterThan
}

fileprivate struct FractionResult {
    let value: Ratio
    let rangeValue: RangeValue
}

fileprivate func parseFraction(_ string: String) throws -> FractionResult? {
    var rangeValue = RangeValue.equal
    
    if let match = fractionalRx.firstMatch(in: string, options: [], range: string.nsRange) {
        if match.range(at: 1).location != NSNotFound {
            switch string.substring(with: match.range(at: 1)) {
                case "P": rangeValue = .greaterThan
                case "M": rangeValue = .lessThan
                default: preconditionFailure("Couldn't parse visibility range value")
            }
        }
        
        guard let numerator = UInt8(string.substring(with: match.range(at: 2))) else {
            throw Error.invalidVisibility(string)
        }
        guard let denominator = UInt8(string.substring(with: match.range(at: 3))) else {
            throw Error.invalidVisibility(string)
        }
        
        return FractionResult(value: Ratio(numerator: Int(numerator), denominator: Int(denominator)),
                              rangeValue: rangeValue)
    }
    
    return nil
}

fileprivate struct IntegerResult {
    let value: UInt16
    let units: String
    let rangeValue: RangeValue
}

fileprivate func parseInteger(_ string: String) throws -> IntegerResult? {
    var rangeValue = RangeValue.equal
    
    if let match = integerRx.firstMatch(in: string, options: [], range: string.nsRange) {
        if match.range(at: 1).location != NSNotFound {
            switch string.substring(with: match.range(at: 1)) {
                case "P": rangeValue = .greaterThan
                case "M": rangeValue = .lessThan
                default: preconditionFailure("Couldn't parse visibility range value")
            }
        }
        
        guard let value = UInt16(string.substring(with: match.range(at: 2))) else {
            throw Error.invalidVisibility(string)
        }
        var units = "M"
        let unitsRange = match.range(at: 3)
        if unitsRange.location != NSNotFound { units = String(string.substring(with: unitsRange)) }
        
        return IntegerResult(value: value, units: units, rangeValue: rangeValue)
    }
    
    return nil
}
