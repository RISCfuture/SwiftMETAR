import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class TemperatureSpec: QuickSpec {
    override func spec() {
        describe("temperature and dewpoint") {
            it("parses a positive number") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let observation = try! METAR.from(string: string)
                expect(observation.temperature).to(equal(18))
                expect(observation.dewpoint).to(equal(16))
            }
            
            it("parses a negative number") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 04/M02 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let observation = try! METAR.from(string: string)
                expect(observation.temperature).to(equal(4))
                expect(observation.dewpoint).to(equal(-2))
            }
            
            it("parses a missing dewpoint") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 02/ A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let observation = try! METAR.from(string: string)
                expect(observation.temperature).to(equal(2))
                expect(observation.dewpoint).to(beNil())
            }
            
            it("parses a missing temperature") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let observation = try! METAR.from(string: string)
                expect(observation.temperature).to(beNil())
                expect(observation.dewpoint).to(beNil())
            }
            
            it("parses a missing temperature/dewpoint") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB M A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let observation = try! METAR.from(string: string)
                expect(observation.temperature).to(beNil())
                expect(observation.dewpoint).to(beNil())
            }
        }
    }
}
