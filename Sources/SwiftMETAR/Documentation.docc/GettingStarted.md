# Getting Started

A basic tutorial on using SwiftMETAR to parse METAR and TAF products.

## Usage

To parse a METAR in String format, simply call
``METAR/from(string:on:lenientRemarks:)``. You will get back a struct that you
can query for weather information: 

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

Parsing TAFs is similar, using ``TAF/from(string:on:)``:

``` swift
let forecast = try TAF.from(string: myString)
for group in forecast.groups {
    switch group.period {
        case let .from(from):
            let date = Calendar.current.date(from: from)
            print("From \(date): ", terminator: "")
        // [...]
    }

    switch group.altimeter {
        case let .inHg(value):
            print("\(Float(value)/100) inHg")
        // [...]
    }
}
```

As you can see, many of the fields in a ``METAR`` (or ``TAF``) struct are enums
(or even nested enums as in the case of ``Wind``). This is more cumbersome than
working with strings but results in stronger guarantees about the format and
integrity of the data.

For more information on how to use the ``METAR`` and ``TAF`` struct, see the
documentation comments.

SwiftMETAR prefers `DateComponents` rather than `Date` objects generally, to
preserve the original data (day-hour-minute) rather than generating timestamps.
Both ``METAR`` and ``TAF`` have vars allowing you to retrieve these values as
`Date`s, but the data is stored as components.
