import Foundation
import Regex

private let nocapWeatherCenterRx = Remark.NavalWeatherCenter.allCases.map { $0.rawValue }.joined(separator: "|")

struct NavalForecasterParser: RemarkParser {
    var urgency = Remark.Urgency.routine
    
    private static let regex = try! Regex(string: "\\bF(\(nocapWeatherCenterRx))(\\d+)\\b")
    
    func parse(remarks: inout String, date: DateComponents) throws -> Remark? {
        guard let result = Self.regex.firstMatch(in: remarks) else { return nil }
        
        guard let centerStr = result.captures[0],
              let center = Remark.NavalWeatherCenter(rawValue: centerStr),
              let forecasterStr = result.captures[1],
              let forecaster = UInt(forecasterStr) else { return nil }
        
        remarks.removeSubrange(result.range)
        return .navalForecaster(center: center, ID: forecaster)
    }
}
