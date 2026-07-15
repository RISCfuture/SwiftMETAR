import RegexBuilder

// `Regex` and `Reference` are not yet `Sendable` in the standard library, but parsers cache
// compiled regexes (and their capture references) in immutable `static let` storage: a compiled
// `Regex` is an immutable program, and a `Reference` is an immutable identity token used only as a
// capture key. Sharing them across isolation domains is therefore safe. The `@retroactive`
// annotations mark these conformances for removal once the stdlib conforms these types itself.
extension Regex: @retroactive @unchecked Sendable {}

extension Reference: @retroactive @unchecked Sendable {}
