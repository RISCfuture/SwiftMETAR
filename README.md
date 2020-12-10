# SwiftMETAR: A METAR and TAF parser for Swift

SwiftMETAR is a Swift library that parses aviation routine weather reports (METARs) and
terminal aerodrome forecasts (TAF) into Swift data structures useful for machine
interpretation. These products contain weather information of interest to pilots. METARs are
textual hourly observations of current conditions within 5 miles of an airport, and TAFs are
textual point forecasts of expected conditions within 5 miles of an airport, over a 24- to
28-hour period.

SwiftMETAR does not download METAR or TAF products from the Internet -- you'll have to
do that yourself. Once you have the text product, SwiftNASR will parse it into a `METAR` or
`TAF` object that you can use to programmatically work with the weather information.

The design goal of SwiftMETAR is _domain-restricted data as much as possible_. Wherever
possible, SwiftMETAR avoids representing data as open-ended types such as strings.
Instead, enums and other types with small domains are preferred. This obviously has
versatility implications -- namely, SwiftMETAR is more likely to generate parsing errors for
malformed data, especially data that is keyed in by humans -- but it also results in a library
that's more in harmony with the design goals of the Swift language itself (type safety,
compile-time checks, etc.).

SwiftMETAR bases is parsing on Advisory Circular 00-45F, which is an American FAA
publication. Some affordance has been made beyond AC00-45F to parse non-American
variances as well (such as supporting QNH-values, visibility in meters, etc.), but this library
has not been extensively tested with non-US products. Similarly, some affordance has been
made for parsing TAFs at military airbases, but most of those will fail to parse for now.

## Installation

SwiftMETAR is a Swift Package Manager project. To use SwiftMETAR, simply add this
project to your `Package.swift` file. Example:

``` swift
// [...]
dependencies: [
    .package(url: "https://github.com/RISCfuture/SwiftMETAR/", .branch("master")),
]
// [...]
```

## Usage

To parse a METAR in String format, simply call `METAR.from`. You will get back a struct
that you can query for weather information: 

``` swift
let observation = try METAR.from(string: myString)
if let winds = observation.winds {
    switch winds {
        case let .direction(heading, speed, gust):
            switch speed {
                case let .knots(value):
                    print("Winds are \(heading) at \(speed) knots")
                // [...]
            }
        // [...]
    }
}

```

As you can see, many of the fields in a `METAR` (or `TAF`) struct are enums (or even nested
enums as in the case of `Wind`). This is more cumbersome than working with strings but
results in stronger guarantees about the format and integrity of the data.

For more information on how to use the `METAR` and `TAF` struct, see the documentation
comments.

SwiftMETAR prefers `DateComponents` rather than `Date` objects generally, to preserve the
original data (day-hour-minute) rather than generating timestamps. Both `METAR` and `TAF`
have vars allowing you to retrieve these values as `Date`s, but the data is stored as
components.

## Tests

Unit testing is done using Nimble and Quick. Simply test the `SwiftMETAR` target to run
tests.

A `SwiftMETAR_Gauntlet` target is also available to do an end-to-end test with live data.
This will download METARs and TAFs from the AWC server and attempt to parse them. Any
failures will be logged with the failing string.
