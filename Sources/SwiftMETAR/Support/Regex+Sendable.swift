// `Regex` is not yet `Sendable` in the standard library, but the parser actors cache
// compiled regexes in immutable stored properties and only ever match against them inside
// their own isolation domain, so sharing them is safe. The `@retroactive` annotation marks
// this conformance for removal once the stdlib conforms `Regex` to `Sendable` itself.
extension Regex: @retroactive @unchecked Sendable {
  func matches(_ string: String) throws -> Bool {
    try wholeMatch(in: string) != nil
  }
}
