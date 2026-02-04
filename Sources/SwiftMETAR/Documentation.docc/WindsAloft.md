# Winds and Temperatures Aloft

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
    if let entry = station[12000] {
        switch entry {
        case .lightAndVariable:
            print("\(station.id): light and variable at 12,000 ft")
        case let .wind(direction, speed, temperature):
            print("\(station.id): \(direction)° at \(speed) kt")
        }
    }
}
```

### Data Group Encoding

Each data group in the product uses a compact encoding:

| Format | Example | Meaning |
|--------|---------|---------|
| `9900` | `9900` | Light and variable (< 5 kt) |
| `DDff` | `3214` | 320° at 14 kt, no temperature |
| `DDff±TT` | `3209+02` | 320° at 9 kt, +2°C |
| `DDffTT` | `295947` | Above 24,000 ft: 290° at 59 kt, −47°C |
| DD ≥ 51 | `7308` | High wind: (73−50)×10 = 230°, 08+100 = 108 kt |

## Topics

### Parsing

- ``WindsAloft/from(string:on:)``

### Data Types

- ``WindsAloft/Header``
- ``WindsAloft/Level-swift.enum``
- ``WindsAloft/Station``
- ``WindsAloft/Station/Entry``
- ``WindsAloftEntry``
