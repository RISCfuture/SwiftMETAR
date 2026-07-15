import Foundation

/**
 A type that has a canonical coded (METAR/TAF) text representation, such as
 `"03015KT"` for a ``Wind`` or `"+TSRA"` for a ``Weather``.

 Conformers gain `Codable` for free: they encode to, and decode from, a single
 string value containing their coded form. This lets the same `Codable`
 machinery serialize an entire report or any subcomponent of one.

 The mapping is not always idempotent — some values have multiple valid coded
 spellings, so ``codedString`` emits a single canonical form.
 */
public protocol CodedRepresentable: Codable {

  /// The canonical coded string for this value, e.g. `"03015KT"`.
  var codedString: String { get }

  /**
   Parses a coded string into a value of this type.

   - Parameter coded: The coded string, e.g. `"03015KT"`.
   - Throws: An ``Error`` if `coded` is not a valid representation.
   */
  init(coded: String) throws
}

extension CodedRepresentable {

  /// Decodes a value from a single string value containing its coded form.
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let coded = try container.decode(String.self)
    do {
      try self.init(coded: coded)
    } catch {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Invalid coded \(Self.self) “\(coded)”: \(error)"
      )
    }
  }

  /// Encodes this value as a single string value containing its ``codedString``.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(codedString)
  }
}
