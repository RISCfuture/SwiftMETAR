import Foundation
import Regex

fileprivate let icingRx = Regex(#"\b6(\d)(\d{3})(\d)\b"#)

func parseIcing(_ parts: inout Array<String.SubSequence>) throws -> Icing? {
    guard !parts.isEmpty else { return nil }
    let icingStr = String(parts[0])
    guard let result = icingRx.firstMatch(in: icingStr) else { return nil }
    parts.removeFirst()
    
    guard let typeStr = result.captures[0],
          let type = Icing.IcingType(rawValue: typeStr),
          let baseStr = result.captures[1],
          let base = UInt(baseStr),
          let depthStr = result.captures[2],
          let depth = UInt(depthStr) else { throw Error.invalidIcing(icingStr) }
    
    return Icing(type: type, base: base*100, depth: depth*1000)
}
