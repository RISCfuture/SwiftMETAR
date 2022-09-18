import Foundation
import Regex

fileprivate let windshearRx = Regex(#"^WS(\d{3})\/(\d{3}\d+KTS?|MPS|KPH)$"#)

func parseWindshear(_ parts: inout Array<String.SubSequence>) throws -> Windshear? {
    guard !parts.isEmpty else { return nil }
    let windshearStr = String(parts[0])
    guard let result = windshearRx.firstMatch(in: windshearStr) else { return nil }
    parts.removeFirst()
    
    guard let heightStr = result.captures[0],
          let height = UInt16(heightStr) else { throw Error.invalidWindshear(windshearStr) }
    
    guard let windStr = result.captures[1] else { throw Error.invalidWindshear(windshearStr) }
    var windStrParts = [windStr[...]]
    guard let winds = try parseWind(&windStrParts) else { throw Error.invalidWindshear(windshearStr) }
    
    return Windshear(height: height*100, wind: winds)
}
