import Foundation

fileprivate let windshearRxStr = #"^WS(\d{3})\/(\d{3}\d+KTS?|MPS|KPH)$"#
fileprivate let windshearRx = try! NSRegularExpression(pattern: windshearRxStr, options: [])

func parseWindshear(_ parts: inout Array<String.SubSequence>) throws -> Windshear? {
    guard !parts.isEmpty else { return nil }
    let windshearStr = String(parts[0])
    guard let result = windshearRx.firstMatch(in: windshearStr, options: [], range: windshearStr.nsRange) else {
        return nil
    }
    parts.removeFirst()
    
    guard let height = UInt16(windshearStr.substring(with: result.range(at: 1))) else {
        throw Error.invalidWindshear(windshearStr)
    }
    
    let windStr = windshearStr.substring(with: result.range(at: 2))
    var windStrParts = [windStr]
    guard let winds = try parseWind(&windStrParts) else {
        throw Error.invalidWindshear(windshearStr)
    }
    
    return Windshear(height: height*100, wind: winds)
}
