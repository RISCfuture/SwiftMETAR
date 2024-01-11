import Foundation

func parseDirectionalVisibilities(_ parts: inout [String.SubSequence]) throws -> [DirectionalVisibility] {
    var visibilities: [DirectionalVisibility] = []
    
    while let raw = parts.first.map(String.init) {
        guard let parsed = DirectionalVisibility(rawValue: raw) else { break }
        parts.removeFirst()
        visibilities.append(parsed)
    }

    return visibilities
}
