import Foundation

func parseWindshearConditions(_ parts: inout [String.SubSequence]) throws -> Bool {
  guard !parts.isEmpty else { return false }

  if parts[0] == "WSCONDS" {
    parts.removeFirst()
    return true
  }

  return false
}
