import Foundation

actor WindsAloftParser {
  static let shared = WindsAloftParser()

  private let headerParser = WindsAloftHeaderParser()
  private let dataGroupParser = WindsAloftDataGroupParser()

  private init() {}

  func parse(_ string: String, on referenceDate: Date? = nil) throws -> WindsAloft {
    var lines = string.components(separatedBy: .newlines)

    let (header, basedOn, validAt, usePeriod) =
      try headerParser.parse(&lines, referenceDate: referenceDate)

    // Skip blank lines before column header
    while let first = lines.first, first.trimmingCharacters(in: .whitespaces).isEmpty {
      lines.removeFirst()
    }

    // Parse column header line: "FT  3000    6000    9000   ..."
    guard !lines.isEmpty else {
      throw Error.invalidWindsAloftColumns("")
    }
    let columnLine = lines.removeFirst()
    let layout = try parseColumnLayout(columnLine)

    // Parse station data lines
    var stations = [WindsAloft.Station]()
    for line in lines {
      let trimmed = line.trimmingCharacters(in: .whitespaces)
      guard !trimmed.isEmpty else { continue }

      let station = try parseStationLine(line, layout: layout)
      stations.append(station)
    }

    // Determine level from altitudes: low-level products include
    // altitudes below 24000 ft
    let altitudeValues = layout.columns.map(\.altitude)
    let level: WindsAloft.Level =
      altitudeValues.contains(where: { $0 < 24000 }) ? .low : .high

    return WindsAloft(
      text: string,
      header: header,
      level: level,
      basedOn: basedOn,
      validAt: validAt,
      usePeriod: usePeriod,
      altitudes: layout.columns.map(\.altitude),
      stations: stations
    )
  }

  // MARK: - Column Layout

  private func parseColumnLayout(_ line: String) throws -> ColumnLayout {
    guard line.contains("FT") || line.contains("3000") || line.contains("6000") else {
      throw Error.invalidWindsAloftColumns(line)
    }

    var columns = [(altitude: UInt, start: Int, end: Int)]()

    // Find each altitude number, its starting position, and its end position
    let altitudePattern = /\d{4,5}/
    var searchStart = line.startIndex
    while searchStart < line.endIndex {
      let searchRange = searchStart..<line.endIndex
      guard let match = line[searchRange].firstMatch(of: altitudePattern) else { break }

      if let altitude = UInt(match.output) {
        let start = line.distance(from: line.startIndex, to: match.range.lowerBound)
        let end = line.distance(from: line.startIndex, to: match.range.upperBound)
        columns.append((altitude: altitude, start: start, end: end))
      }
      searchStart = match.range.upperBound
    }

    guard !columns.isEmpty else {
      throw Error.invalidWindsAloftColumns(line)
    }

    // Data groups are right-aligned within each column. Column boundaries
    // are defined by the END positions of consecutive altitude numbers:
    // each column extends from the previous altitude number's end to the
    // current altitude number's end. The station field is a fixed 4
    // characters (3-char ID + space).
    let stationWidth = 4

    var columnRanges = [(altitude: UInt, range: Range<Int>)]()
    for (index, col) in columns.enumerated() {
      let rangeStart: Int
      if index == 0 {
        rangeStart = stationWidth
      } else {
        rangeStart = columns[index - 1].end
      }
      let rangeEnd: Int
      if index + 1 < columns.count {
        rangeEnd = col.end
      } else {
        // Last column extends to end of line (or beyond for data lines)
        rangeEnd = max(line.count, col.end + 8)
      }
      columnRanges.append((altitude: col.altitude, range: rangeStart..<rangeEnd))
    }

    return ColumnLayout(stationRange: 0..<stationWidth, columns: columnRanges)
  }

  // MARK: - Station Lines

  private func parseStationLine(_ line: String, layout: ColumnLayout) throws -> WindsAloft.Station {
    let lineLength = line.count

    // Extract station ID from the station range
    let stationEnd = min(layout.stationRange.upperBound, lineLength)
    let startIdx = line.startIndex
    let stationID = String(line[startIdx..<line.index(startIdx, offsetBy: stationEnd)])
      .trimmingCharacters(in: .whitespaces)

    // Extract data from each column
    var entries = [WindsAloft.Station.Entry]()
    for column in layout.columns {
      let start = column.range.lowerBound
      let end = min(column.range.upperBound, lineLength)

      let groupStr: String
      if start < lineLength {
        let s = line.index(startIdx, offsetBy: start)
        let e = line.index(startIdx, offsetBy: end)
        groupStr = String(line[s..<e])
      } else {
        groupStr = ""
      }

      if let entry = try dataGroupParser.parse(groupStr) {
        entries.append(.init(altitude: column.altitude, data: entry))
      }
    }

    return WindsAloft.Station(id: stationID, entries: entries)
  }

  struct ColumnLayout {
    let stationRange: Range<Int>
    let columns: [(altitude: UInt, range: Range<Int>)]
  }
}
