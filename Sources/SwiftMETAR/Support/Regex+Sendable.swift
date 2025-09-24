extension Regex: @retroactive @unchecked Sendable {
  func matches(_ string: String) throws -> Bool {
    try wholeMatch(in: string) != nil
  }
}
