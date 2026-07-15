/// A parser that can build its regexes on demand, so a shared instance can be warmed
/// single-threaded before it is matched concurrently.
protocol WarmableParser: AnyObject, Sendable {
  /// Builds this parser's regexes on the calling thread.
  func warmUp()
}

extension WarmableParser {
  /// Parsers whose regexes are all `static let` need no warming: `LockedRegex` builds
  /// each one safely on first use. Only parsers with instance `lazy var` regexes (whose
  /// wrapper would otherwise be created racily on first concurrent access) override this.
  func warmUp() {}
}

/// Warms `parser` and returns it, for initializing a shared parser singleton:
/// `static let x = warmed(SomeParser())`.
func warmed<Parser: WarmableParser>(_ parser: Parser) -> Parser {
  parser.warmUp()
  return parser
}
