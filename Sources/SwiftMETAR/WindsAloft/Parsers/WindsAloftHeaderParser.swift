import Foundation
@preconcurrency import RegexBuilder

class WindsAloftHeaderParser {

  private let dayHourMinuteParser = DayHourMinuteParser()
  private let hourMinutePeriodParser = HourMinutePeriodParser()

  // MARK: - WMO header regex: "FBUS31 KWNO 032000"

  private let productIDRef = Reference<Substring>()
  private let issuingOfficeRef = Reference<Substring>()

  private lazy var wmoRx = Regex {
    Capture(as: productIDRef) { OneOrMore(.word) }
    OneOrMore(.whitespace)
    Capture(as: issuingOfficeRef) { OneOrMore(.word) }
    OneOrMore(.whitespace)
    dayHourMinuteParser.rx
  }

  // MARK: - "DATA BASED ON 031800Z"

  private lazy var basedOnRx = Regex {
    "DATA BASED ON "
    dayHourMinuteParser.rx
  }

  // MARK: - "VALID 040000Z   FOR USE 2000-0300Z. TEMPS NEG ABV 24000"

  private lazy var validLineRx = Regex {
    "VALID "
    dayHourMinuteParser.rx
    OneOrMore(.whitespace)
    "FOR USE "
    hourMinutePeriodParser.rx
    "."
    Optionally { OneOrMore(.any) }
  }

  /// Parses the header lines of a winds aloft product and returns a
  /// ``WindsAloft.Header``, the based-on date, valid-at date, and use period.
  ///
  /// Expected header format (lines):
  /// ```
  /// 000
  /// FBUS31 KWNO 032000
  /// FD1US1
  /// DATA BASED ON 031800Z
  /// VALID 040000Z   FOR USE 2000-0300Z. TEMPS NEG ABV 24000
  /// ```
  func parse(
    _ lines: inout [String],
    referenceDate: Date?
  ) throws -> (
    header: WindsAloft.Header,
    basedOn: DateComponents,
    validAt: DateComponents,
    usePeriod: DateComponentsInterval
  ) {
    // Skip leading blank lines and the "000" line
    while let first = lines.first,
      first.trimmingCharacters(in: .whitespaces).isEmpty
        || first.trimmingCharacters(in: .whitespaces) == "000"
    {
      lines.removeFirst()
    }

    guard !lines.isEmpty else { throw Error.invalidWindsAloftHeader("") }

    // Line 1: WMO header — "FBUS31 KWNO 032000"
    let wmoLine = lines.removeFirst().trimmingCharacters(in: .whitespaces)
    guard let wmoMatch = try wmoRx.wholeMatch(in: wmoLine) else {
      throw Error.invalidWindsAloftHeader(wmoLine)
    }
    let productID = String(wmoMatch[productIDRef])
    let issuingOffice = String(wmoMatch[issuingOfficeRef])
    let issuanceDate = try dayHourMinuteParser.parse(
      match: wmoMatch,
      referenceDate: referenceDate,
      originalString: wmoLine
    )

    // Line 2: Bulletin ID — "FD1US1"
    guard !lines.isEmpty else { throw Error.invalidWindsAloftHeader(wmoLine) }
    let bulletinLine = lines.removeFirst().trimmingCharacters(in: .whitespaces)
    let bulletinID = bulletinLine

    let header = WindsAloft.Header(
      productID: productID,
      issuingOffice: issuingOffice,
      issuanceDate: issuanceDate,
      bulletinID: bulletinID
    )

    // Line 3: "DATA BASED ON 031800Z"
    guard !lines.isEmpty else { throw Error.invalidWindsAloftHeader(bulletinID) }
    let basedOnLine = lines.removeFirst().trimmingCharacters(in: .whitespaces)
    guard let basedOnMatch = try basedOnRx.wholeMatch(in: basedOnLine) else {
      throw Error.invalidWindsAloftHeader(basedOnLine)
    }
    let basedOn = try dayHourMinuteParser.parse(
      match: basedOnMatch,
      referenceDate: referenceDate,
      originalString: basedOnLine
    )

    // Line 4: "VALID 040000Z   FOR USE 2000-0300Z. TEMPS NEG ABV 24000"
    guard !lines.isEmpty else { throw Error.invalidWindsAloftHeader("missing VALID line") }
    let validLine = lines.removeFirst().trimmingCharacters(in: .whitespaces)
    guard let validMatch = try validLineRx.wholeMatch(in: validLine) else {
      throw Error.invalidWindsAloftHeader(validLine)
    }
    let validAt = try dayHourMinuteParser.parse(
      match: validMatch,
      referenceDate: referenceDate,
      originalString: validLine
    )
    let usePeriod = try hourMinutePeriodParser.parse(
      match: validMatch,
      referenceDate: validAt.date ?? referenceDate,
      originalString: validLine
    )

    return (header, basedOn, validAt, usePeriod)
  }
}
