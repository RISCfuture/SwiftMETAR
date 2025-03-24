import Foundation

extension DateInterval {
    var range: Range<Date> { start..<end }
}

func zipOptionals<each T>(_ values: repeat (each T)?) -> (repeat each T)? {
    for case nil in repeat (each values) {
        return nil
    }
    return (repeat (each values)!)
}
