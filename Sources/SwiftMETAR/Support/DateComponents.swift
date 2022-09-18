import Foundation

extension DateComponents {
    private var mostSignificantEmptyComponent: Calendar.Component? {
        if year != nil { return .era }
        if month != nil { return .year }
        if day != nil { return .month }
        if hour != nil { return .day }
        if minute != nil { return .hour }
        if second != nil { return .minute }
        if nanosecond != nil { return .second }
        return nil
    }
    
    func merged(with other: DateComponents) -> DateComponents? {
        guard let calendar = calendar,
              let date = date,
              let timeZone = timeZone,
              let period = other.mostSignificantEmptyComponent,
              let start = date.startOf(period),
              let compDate = start.next(other) else { return nil }
        return calendar.dateComponents(in: timeZone, from: compDate)
    }
}
