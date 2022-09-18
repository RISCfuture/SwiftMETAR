import Foundation

let zulu = TimeZone(secondsFromGMT: 0)!
var zuluCal: Calendar {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = zulu
    return cal
}

extension Date {
    func startOf(_ period: Calendar.Component) -> Date? {
        let components: DateComponents
        switch period {
            case .year:
                components = zuluCal.dateComponents([.year], from: self)
            case .month:
                components = zuluCal.dateComponents([.year, .month], from: self)
            case .day:
                components = zuluCal.dateComponents([.year, .month, .day], from: self)
            case .hour:
                components = zuluCal.dateComponents([.year, .month, .day, .hour], from: self)
            case .minute:
                components = zuluCal.dateComponents([.year, .month, .day, .hour, .minute], from: self)
            case .second:
                components = zuluCal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
            default:
                preconditionFailure("Can't get start of \(period)")
        }
        
        return zuluCal.date(from: components)
    }
    
    func next(_ components: DateComponents) -> Date? {
        return zuluCal.nextDate(after: self, matching: components, matchingPolicy: .nextTime)
    }
    
    func next(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date? {
        return next(.init(year: year, month: month, day: day, hour: hour, minute: minute, second: second))
    }
}

func applyComponents(_ components: DateComponents, within component: Calendar.Component, ofDate referenceDate: Date) -> DateComponents? {
    guard let referenceStart = referenceDate.startOf(component) else {
        preconditionFailure("No start of month for \(String(describing: referenceDate))")
    }
    guard let date = referenceStart.next(components) else {
        return nil
    }
    
    return zuluCal.dateComponents(in: zulu, from: date)
}
