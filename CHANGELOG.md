# Change Log

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
