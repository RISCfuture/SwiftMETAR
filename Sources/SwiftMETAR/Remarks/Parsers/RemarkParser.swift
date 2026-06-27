import Foundation
import NumberKit
import RegexBuilder

protocol RemarkParser {
  var urgency: Remark.Urgency { get }

  init()
  func parse(remarks: inout String, date: DateComponents) throws -> Remark?
}
