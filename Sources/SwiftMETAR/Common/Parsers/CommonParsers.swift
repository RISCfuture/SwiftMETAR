func parseLocationID(_ parts: inout [String.SubSequence]) throws -> String {
    guard !parts.isEmpty else { throw Error.badFormat }
    return String(parts.removeFirst())
}
