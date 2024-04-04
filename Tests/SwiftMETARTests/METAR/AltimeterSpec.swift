import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class AltimeterSpec: QuickSpec {
    override func spec() {
        describe("altimeter") {
            it("parses an inHg altimeter setting") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let observation = try! METAR.from(string: string)
                
                expect(observation.altimeter).to(equal(.inHg(2992)))
                expect(observation.altimeter!.measurement.value).to(equal(29.92))
            }
            
            it("parses an hPa altimeter setting") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 Q1021 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let observation = try! METAR.from(string: string)
                
                expect(observation.altimeter).to(equal(.hPa(1021)))
                expect(observation.altimeter!.measurement.converted(to: .inchesOfMercury).value).to(beCloseTo(30.15, within: 0.01))
            }
        }
    }
}
