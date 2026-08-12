# Change Log

## [4.0.0] - Unreleased

### Changed

- **Breaking:** weather types now serialize through `Codable` as their coded
  METAR/TAF text rather than structured JSON. Each converted type conforms to the
  new `CodedRepresentable` protocol — exposing a canonical `codedString` and an
  `init(coded:)` — and encodes/decodes as a single coded string. A `Wind` becomes
  `"03015KT"`, a `Weather` `"+TSRA"`, an `Altimeter` `"A2992"`, a `TAF.Group` its
  coded group, and a `METAR`/`TAF` its full flat coded report. This composes, so
  `Codable` can serialize a whole report or any subcomponent through one
  mechanism. JSON archives produced by 3.x will no longer decode.
- Converted types: `Wind`, `Wind.Speed`, `Visibility` (and `Visibility.Value`),
  `Weather`, `Condition`, `Altimeter`, `Windshear`, `RunwayVisibility`, `Icing`,
  `Turbulence`, `WindsAloftEntry`, `WindsAloft`, `TAF.Group.Period`, `TAF.Group`,
  `TAF`, `METAR`, and every `Remark` case (e.g. `Remark.seaLevelPressure` becomes
  `"SLP132"`, `Remark.peakWinds` becomes `"PK WND 28045/1547"`). Within a full
  `METAR`/`TAF`, remarks are still preserved verbatim via the report's remarks
  text; a standalone `Remark` now also encodes as its coded string. `WindsAloft`
  encodes as the raw bulletin text when present, regenerating a re-parseable
  fixed-width bulletin otherwise. Some coded forms are canonical rather than
  byte-identical (direction sets, missing-value sentinels, and remark date/period
  fields resolved from context re-encode to one canonical spelling).

### Added

- `CodedRepresentable` protocol providing single-value coded-string `Codable`,
  plus `codedString` and `init(coded:)` on all converted types.
- A synchronous decode path for `METAR`/`TAF`/`TAF.Group` (used by `Codable`)
  that leaves the async `from(string:)` parsers unchanged. Parser regexes are
  shared as `static let` storage (compiled once) so neither path recompiles them.

### Fixed

- The winds aloft `FOR USE` period, which is given only as times of day, was
  resolved by searching forward from the start of the valid day, so it could
  never begin before that day: `VALID 130000Z FOR USE 2100-0600Z` resolved to
  132100Z–140600Z instead of 122100Z–130600Z. The period is now anchored at or
  before the product's valid time (NWS TIN 05-54). This also corrects a `FOR
  USE` period ending at `0000` landing a day late, which stretched the 06Z
  bulletin's `FOR USE 1500-0000Z` into a 33-hour interval; the resulting
  interval can no longer be empty or inverted.

## [3.2.1] - 2026-07-15

### Fixed

- `Altimeter` encoded the inHg discriminator as `"inHq"` while decoding `"inHg"`,
  so inHg altimeters could not round-trip through `Codable`.
- `Remark.heightMeasurement` returned `nil` for a `variableSkyCondition` remark
  even though its ceiling height was documented as available; it now surfaces
  that height when the remark carries one.
- `Remark.Direction.RangeFormatStyle` collapsed a lone direction (e.g. `LTG DSNT
  NE`) to “all quadrants”; only a set containing all eight compass points now
  does so.
- `Remark.Direction.RangeFormatStyle` produced fragmented direction output (e.g.
  “north, east, and northeast” instead of “north through east”) because
  consolidation depended on `Set` iteration order; points are now sorted
  clockwise from north before merging.

## [3.2.0] - 2026-07-06

### Added

- Linux support for the core `SwiftMETAR` library and the `decode-winds-aloft`
  CLI. Conditional `FoundationNetworking`/`FoundationXML` imports and a
  `String(localized:)` shim cover the platform gaps. The `METARFormatting`
  module and the `decode-metar`/`decode-taf` CLIs remain Apple-only, as they
  rely on `Measurement.FormatStyle`, which open-source Foundation does not
  provide; all targets still build on Apple platforms.

## [3.1.0] - 2026-06-26

### Changed

- Adopted Swift's Approachable Concurrency upcoming-feature flags
  (`NonisolatedNonsendingByDefault` and `InferIsolatedConformances`),
  aligning the package's async execution semantics with modern Swift 6
  defaults. No public API signatures changed: the async `from(string:)`
  parsers and the `from(xml:)` `AsyncStream` producers behave the same
  from a caller's perspective.
- Dropped the now-redundant `@preconcurrency` qualifier from
  `import RegexBuilder` across all parser files. Sendability of the
  cached, actor-confined compiled regexes is still provided by the
  package's `Regex: @retroactive @unchecked Sendable` conformance, which
  is retained until the standard library conforms `Regex` to `Sendable`
  itself.

## [3.0.1] - 2026-05-14

### Changed

- Pinned `BuildableMacro` dependency to tagged version `1.0.0` instead of
  `main` branch, so SwiftMETAR can be consumed as a stable-versioned
  dependency.

## [3.0.0] - 2026-03-20

### Added

- XML parsing for METARs and TAFs from aviationweather.gov cache files.
  - `METAR.from(xml:)` and `TAF.from(xml:)` return `AsyncStream<Result<..., Error>>`
    for resilient batch parsing with per-entry error handling.
- Winds aloft parsing.

### Changed

- CLI tools (`decode-metar`, `decode-taf`) now support `--format xml` and
  `--output json` options.
- Log messages in CLI tools now go to stderr to keep JSON output clean.
- Updated to Swift 6.2.
- Added swift-format for code formatting.

### Fixed

- Fixed CSV parsing for updated aviationweather.gov format (quoted raw text,
  separate station_id column).
- Fixed handling of TAF periods where the end date comes before the start date
  (e.g., crossing month boundaries).

## [2.0.1] - 2025-08-20

### Fixed

- Better handling of pressure tendency remarks ("5 group").
  - Pressure change value is negated for downwards trends.
  - Localized string fixed to indicate pressure value is a change.

## [2.0.0] - 2025-01-18

This version introduces Swift 6 language support and concurrency mode.

### Added

- Swift 6 language support and concurrency mode.
  - `METAR`, `TAF`, and associated objects all now `Sendable`.
  - `parse` functions are now `async`.
- Adds `METARFormatting` library for locale-aware METAR and TAF formatting.
  - Adds DecodeMETAR and DecodeTAF CLI tools to demonstrate formatting library.
  - Adds documentation for METARFormatting.
- `Group` now includes the raw text as `text`.

### Changed

- `NSLocalizedString` usages removed in favor of xcstrings catalogs and
  `String(localized:)`
- Added `Visibility.notRecorded` case to differentiate "VSNO" from "M".
- Minimum OS versions advanced.
- Added some utility functions to `Weather` and `Remark`.
- Made `Remark.Urgency` sortable.

### Fixed

- More lenient parsing of direction ranges.
- Removed unused `Error` case.
- Fixed handling of TAF periods that cross month boundaries.
- Documentation fixes.

### Internal Changes

- Uses new `RegexBuilder` API instead of `NSRegularExpression`.
  - `METAR`, `TAF`, and `Remark` parsers are now actors.

### Removed

- Removes METARGauntlet as the functionality is now included in the new CLI
  tools.

## [1.0.0] - 2024-04-03

Initial release.
