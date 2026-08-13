# ``SwiftMETAR/WindsAloft``

@Metadata {
    @DisplayName("Winds and Temperatures Aloft")
}

Parse NWS Winds and Temperatures Aloft (FB/FD) products into structured data.

## Overview

Winds and Temperatures Aloft forecasts (formerly known as FD products) provide
wind direction, speed, and temperature at standard pressure altitudes for
reporting stations across the US. They are issued as fixed-width tabular
documents for both low-level (3,000–39,000 ft) and high-level (45,000–53,000 ft)
altitude ranges.

SwiftMETAR parses these products into ``WindsAloft`` structs that you can query
programmatically:

```swift
let product = try await WindsAloft.from(string: rawText)
for station in product.stations {
    guard let entry = station[12000] else { continue }
    switch entry {
    case .lightAndVariable:
        print("\(station.id): light and variable at 12,000 ft")
    case let .wind(direction, speed, _):
        print("\(station.id): \(direction)° at \(speed) kt")
    }
    if let temperature = entry.temperatureMeasurement {
        print("  temperature: \(temperature)")
    }
}
```

### Data Group Encoding

Each data group in the product uses a compact encoding:

| Format | Example | Meaning |
|--------|---------|---------|
| `9900` | `9900` | Light and variable (< 5 kt), no temperature |
| `9900±TT` | `9900-10` | Light and variable, −10°C |
| `DDff` | `3214` | 320° at 14 kt, no temperature |
| `DDff±TT` | `3209+02` | 320° at 9 kt, +2°C |
| `DDffTT` | `295947` | Above 24,000 ft: 290° at 59 kt, −47°C |
| DD 51–86 | `7308` | High wind: (73−50)×10 = 230°, 08+100 = 108 kt |

Temperatures are omitted at 3,000 ft and reported at every altitude above it,
so `9900` appears bare only in the lowest column. Direction figures outside
00–36 and the 51–86 high-wind range (other than the `99` of a light and
variable group) are rejected as invalid.

## Topics

### Parsing

- ``WindsAloft/from(string:on:)``

### Data Types

- ``WindsAloft/Header``
- ``WindsAloft/Level-swift.enum``
- ``WindsAloft/Station``
- ``WindsAloft/Station/Entry``
- ``WindsAloftEntry``
