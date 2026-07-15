import RegexBuilder
import Synchronization

/// Serializes RegexBuilder → `Regex` construction process-wide. Building a `Regex`
/// from the RegexBuilder DSL touches non-thread-safe global state, so two regexes
/// must never be built at the same time. Matching an already-built `Regex` is
/// thread-safe, so this lock guards construction only — matching runs lock-free.
private let regexConstructionLock = Mutex<Void>(())

/**
 A wrapper around a lazily-built, cached `Regex`.

 The parser singletons build each regex exactly once, on first use, under
 ``regexConstructionLock``; every subsequent match reads the cached program and runs
 without contending on that lock. Because the parsers are shared and built once, the
 heavy RegexBuilder compilation happens a single time per regex for the whole process.

 Only regexes that are matched directly need wrapping. A regex that is *composed* into
 another `Regex { }` builder is reached through ``composable``, which participates in
 the composing regex's already-serialized construction.
 */
final class LockedRegex<Output>: @unchecked Sendable {
  private let build: () -> Regex<Output>
  private let cache = Mutex<Regex<Output>?>(nil)

  /// The underlying regex, for composing into another `Regex { }` builder. Composition
  /// only happens while a parent regex is being built — already inside
  /// ``regexConstructionLock`` — so this builds directly rather than re-acquiring the
  /// non-reentrant construction lock.
  var composable: Regex<Output> {
    constructAndCache()
  }

  /// The cached compiled regex, built once under the construction lock on first use.
  private var regex: Regex<Output> {
    if let cached = cache.withLock({ $0 }) { return cached }
    return regexConstructionLock.withLock { _ in constructAndCache() }
  }

  init(_ build: @autoclosure @escaping () -> Regex<Output>) {
    self.build = build
  }

  func wholeMatch(in string: Substring) throws -> Regex<Output>.Match? {
    try regex.wholeMatch(in: string)
  }

  func wholeMatch(in string: String) throws -> Regex<Output>.Match? {
    try wholeMatch(in: string[...])
  }

  func firstMatch(in string: Substring) throws -> Regex<Output>.Match? {
    try regex.firstMatch(in: string)
  }

  func firstMatch(in string: String) throws -> Regex<Output>.Match? {
    try firstMatch(in: string[...])
  }

  func matches(_ string: some StringProtocol) throws -> Bool {
    try wholeMatch(in: Substring(string)) != nil
  }

  func allMatches(in string: String) -> [Regex<Output>.Match] {
    Array(string.matches(of: regex))
  }

  private func constructAndCache() -> Regex<Output> {
    cache.withLock { slot in
      if let cached = slot { return cached }
      let regex = build()
      slot = regex
      return regex
    }
  }
}
