/// The result of parsing an individual METAR or TAF entry from XML data.
///
/// Unlike `Result`, the ``failure(_:_:)`` case carries the raw METAR/TAF
/// string (when available) so callers can fall back to textual parsing.
public enum XMLParseResult<Success: Sendable>: Sendable {
  case success(Success)
  case failure(any Swift.Error, String?)

  /// Returns the success value or throws the contained error.
  public func get() throws -> Success {
    switch self {
      case .success(let value): return value
      case .failure(let error, _): throw error
    }
  }
}
