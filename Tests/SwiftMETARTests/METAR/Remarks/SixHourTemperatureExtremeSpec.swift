import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class SixHourTemperatureExtremeSpec: QuickSpec {
    override func spec() {
        describe("six-hour temperature extreme") {
            it("parses a '10142' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 10142"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.sixHourTemperatureExtreme(type: .high, temperature: 14.2)))
            }
            
            it("parses a '11021' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 11021"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.sixHourTemperatureExtreme(type: .high, temperature: -2.1)))
            }
            
            it("parses a '21001' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 21001"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.sixHourTemperatureExtreme(type: .low, temperature: -0.1)))
            }
            
            it("parses a '20012' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 20012"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.sixHourTemperatureExtreme(type: .low, temperature: 1.2)))
            }
        }
    }
}
