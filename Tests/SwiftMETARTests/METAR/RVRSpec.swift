import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class RVRSpec: AsyncSpec {
    override class func spec() {
        describe("runway visibility") {
            it("parses visibilities in feet") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let visibilities = try await METAR.from(string: string).runwayVisibility
                
                expect(visibilities.count).to(equal(1))
                expect(visibilities[0].runwayID).to(equal("17L"))
                expect(visibilities[0].visibility).to(equal(.equal(.feet(2600))))
                
            }
            
            it("parses visibilities in meters") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/0800M +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let visibilities = try await METAR.from(string: string).runwayVisibility
                
                expect(visibilities.count).to(equal(1))
                expect(visibilities[0].runwayID).to(equal("17L"))
                expect(visibilities[0].visibility).to(equal(.equal(.meters(800))))
            }
            
            it("parses visibility ranges") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R01L/0600V1000FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let visibilities = try await METAR.from(string: string).runwayVisibility
                
                expect(visibilities.count).to(equal(1))
                expect(visibilities[0].runwayID).to(equal("01L"))
                expect(visibilities[0].visibility)
                    .to(equal(.variable(.equal(.feet(600)), .equal(.feet(1000)))))
            }
            
            it("parses less-than visibilities") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R01L/M0600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let visibilities = try await METAR.from(string: string).runwayVisibility
                
                expect(visibilities.count).to(equal(1))
                expect(visibilities[0].runwayID).to(equal("01L"))
                expect(visibilities[0].visibility).to(equal(.lessThan(.feet(600))))
            }
            
            it("parses greater-than visibilities") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R27/P6000FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let visibilities = try await METAR.from(string: string).runwayVisibility
                
                expect(visibilities.count).to(equal(1))
                expect(visibilities[0].runwayID).to(equal("27"))
                expect(visibilities[0].visibility).to(equal(.greaterThan(.feet(6000))))
            }
        }
    }
}
