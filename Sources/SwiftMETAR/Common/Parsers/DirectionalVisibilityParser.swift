import Foundation

//TODO: - Refactor with less branching and, probably, with reduce function.

func parseDirectionalVisibilities(_ parts: inout [String.SubSequence]) throws -> [DirectionalVisibility] {
    var visibilities: [DirectionalVisibility] = []
    
    while let raw = parts.first.map(String.init) {
        
        guard raw != "M" else {
            parts.removeFirst()
            return visibilities
        }
                
        guard let parsed = DirectionalVisibility(rawValue: raw) else {
            return visibilities
        }
        
        visibilities.append(parsed)
        
        if parsed.rawValue == "CAVOK" {
            return visibilities
        } else {
            parts.removeFirst()
        }
    }

    return visibilities
}
