import RegexBuilder
import Synchronization

/// A type whose cases are recognized in coded weather products by their raw values.
protocol RegexCases: RawRepresentable, CaseIterable {

  /// A regex matching any one of this type's raw values, tried in declaration order.
  static var rx: Regex<Substring> { get }
}

/// Holds one compiled alternation per conforming type, so each case set is built once per
/// process instead of on every access.
///
/// Like ``LockedRegex/composable``, this builds without taking the process-wide regex
/// construction lock: a case alternation is only ever reached while a parent `Regex { }` is
/// being built, so that non-reentrant lock is already held.
private let caseAlternations = Mutex<[ObjectIdentifier: Regex<Substring>]>([:])

extension RegexCases where RawValue == String {
  static var rx: Regex<Substring> {
    caseAlternations.withLock { cache in
      let key = ObjectIdentifier(Self.self)
      if let cached = cache[key] { return cached }
      let alternation = regexAlternation(of: allCases.map(\.rawValue))
      cache[key] = alternation
      return alternation
    }
  }
}
