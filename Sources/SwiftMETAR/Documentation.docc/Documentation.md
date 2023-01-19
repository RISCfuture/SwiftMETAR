# ``SwiftMETAR``

A Swift library that parses aviation routine weather reports (METARs) and
terminal aerodrome forecasts (TAF) into Swift data structures useful for machine
interpretation.

## Overview

SwiftMETAR is a Swift library that parses aviation routine weather reports
(METARs) and terminal aerodrome forecasts (TAF) into Swift data structures
useful for machine interpretation. These products contain weather information of
interest to pilots. METARs are textual hourly observations of current conditions
within 5 miles of an airport, and TAFs are textual point forecasts of expected
conditions within 5 miles of an airport, over a 24- to 28-hour period.

SwiftMETAR does not download METAR or TAF products from the Internet -- you'll
have to do that yourself. Once you have the text product, SwiftMETAR will parse
it into a ``METAR`` or ``TAF`` object that you can use to programmatically work
with the weather information.

The design goal of SwiftMETAR is _domain-restricted data as much as possible_.
Wherever possible, SwiftMETAR avoids representing data as open-ended types such
as strings. Instead, enums and other types with small domains are preferred. This
obviously has versatility implications -- namely, SwiftMETAR is more likely to
generate parsing errors for malformed data, especially data that is keyed in by
humans -- but it also results in a library that's more in harmony with the
design goals of the Swift language itself (type safety, compile-time checks,
etc.).

SwiftMETAR bases is parsing on Advisory Circular 00-45F, which is an American
FAA publication. Some affordance has been made beyond AC00-45F to parse
non-American variances as well (such as supporting QNH-values, visibility in
meters, etc.), but this library has not been extensively tested with non-US
products. Similarly, some affordance has been made for parsing TAFs at military
airbases, but most of those will fail to parse for now.

## Installation

SwiftMETAR is a Swift Package Manager project. To use SwiftMETAR, simply add
this project to your `Package.swift` file. Example:

``` swift
// [...]
dependencies: [
    .package(url: "https://github.com/RISCfuture/SwiftMETAR/", .branch("main")),
]
// [...]
```

## Tests

Unit testing is done using Nimble and Quick. Simply test the `SwiftMETAR` target
to run tests.

A `SwiftMETAR_Gauntlet` target is also available to do an end-to-end test with
live data. This will download METARs and TAFs from the AWC server and attempt to
parse them. Any failures will be logged with the failing string.

## Topics

### Basics

- <doc:GettingStarted>
- ``METAR``
- ``TAF``
- ``Remark``

### Supporting classes

- <doc:WeatherTypes>
- ``Error``
