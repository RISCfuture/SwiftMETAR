import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

// MARK: - Dates

extension DateComponents {
    static func this(month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, reference: Date? = nil) -> DateComponents? {
        let reference = reference ?? Date()
        
        let startDate: Date
        let components: DateComponents
        if let month = month {
            startDate = reference.startOf(.year)!
            components = .init(month: month, day: day, hour: hour, minute: minute, second: second)
        }
        else if let day = day {
            startDate = reference.startOf(.month)!
            components = .init(day: day, hour: hour, minute: minute, second: second)
        }
        else if let hour = hour {
            startDate = reference.startOf(.day)!
            components = .init(hour: hour, minute: minute, second: second)
        }
        else if let minute = minute {
            startDate = reference.startOf(.hour)!
            components = .init(minute: minute, second: second)
        }
        else if let second = second {
            startDate = reference.startOf(.minute)!
            components = .init(second: second)
        } else {
            preconditionFailure("Must specify at least one date component")
        }
        
        guard let date = zuluCal.nextDate(after: startDate, matching: components, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward) else { return nil }
        return zuluCal.dateComponents(in: zulu, from: date)
    }
}

extension Date {
    func this(month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> DateComponents? {
        return DateComponents.this(month: month, day: day, hour: hour, minute: minute, second: second, reference: self)
    }
}
