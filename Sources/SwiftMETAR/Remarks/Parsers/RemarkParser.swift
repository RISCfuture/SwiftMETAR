import Foundation
import NumberKit
import RegexBuilder

protocol RemarkParser: Sendable {
  var urgency: Remark.Urgency { get }

  init()
  func parse(remarks: inout String, date: DateComponents) throws -> Remark?
}

extension RemarkParser {
  /// Builds and compiles this parser's regexes once, on the thread that calls it, so
  /// the shared parser set can be warmed single-threaded before concurrent decoding.
  /// Matching an empty string forces each regex to build without producing a remark.
  func warmUp() {
    var remarks = ""
    _ = try? parse(remarks: &remarks, date: DateComponents())
  }
}
