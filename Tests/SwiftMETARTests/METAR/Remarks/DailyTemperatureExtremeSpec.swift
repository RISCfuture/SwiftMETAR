import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class DailyTemperatureExtremeSpec: QuickSpec {
    override func spec() {
        describe("daily temperature extreme") {
            it("parses a '401001015' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 401001015"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.dailyTemperatureExtremes(low: -1.5, high: 10)))
            }
            
            it("parses a '401120084' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 401120084"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.dailyTemperatureExtremes(low: 8.4, high: 11.2)))
            }
        }
    }
}
