# Usage

How to use METARFormatting to do locale-aware formatting of your SwiftMETAR types.

## Examples

`FormatStyle` implementations can be used directly as interpolations in calls to
`String(localized:)`:

```
func printWinds(metar: METAR) -> String {
  return String(localized: "Winds are \(metar.wind, format: .wind())")
}
```

If you need more customization, the class functions can generally be called with
additional parameters:

```
func printWinds(metar: METAR) -> String {
  return String(localized: "Winds are \(metar.wind, format: .wind(speedFormat: .measurement(width: .narrow))")
}
```

If you do not need the interpolation features of `String(localized:)`, you can
also use these formatters directly:

```
let formatter = Wind.FormatStyle()
formatter.format(metar.wind)
```

Most formatters also have a fluent-style interface, if you prefer:

```
func printWinds(metar: METAR) -> String {
  return String(localized: "Winds are \(metar.wind, format: .wind.speedFormat(.measurement(width: .narrow))")
}
```

Remarks also have a formatter. You can format a `Remark` to print it in plain
English:

```
ForEach(metar.remarks) { remark in
  Text(remark, format: .remark)
}
```

