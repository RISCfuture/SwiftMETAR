import Foundation
import NumericAnnex
import Quick
import Nimble

@testable import SwiftMETAR

class VisibilitySpec: QuickSpec {
    override func spec() {
        describe("visibility") {
            it("parses fractional visibilities < 1 SM") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let visibility = try! METAR.from(string: string).visibility
                expect(visibility).to(equal(.equal(.statuteMiles(3/4 as Ratio))))
            }
            
            it("parses fractional visibilities > 1 SM") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 1 1/2SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let visibility = try! METAR.from(string: string).visibility
                expect(visibility).to(equal(.equal(.statuteMiles(3/2 as Ratio))))
            }
            
            it("parses whole visibilities > 1 SM") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let visibility = try! METAR.from(string: string).visibility
                expect(visibility).to(equal(.equal(.statuteMiles(3 as Ratio))))
            }
            
            it("parses visibilities < 1/4 SM") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 M1/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let visibility = try! METAR.from(string: string).visibility
                expect(visibility).to(equal(.lessThan(.statuteMiles(1/4 as Ratio))))
            }
            
            it("parses visibilities ≥ 10 SM") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 10SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let visibility = try! METAR.from(string: string).visibility
                expect(visibility).to(equal(.greaterThan(.statuteMiles(10 as Ratio))))
            }
            
            it("parses visibilities in meters") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3000 R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let visibility = try! METAR.from(string: string).visibility
                expect(visibility).to(equal(.equal(.meters(3000))))
            }
            
            it("parses visibilities ≥ 9999 m") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 9999 R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let visibility = try! METAR.from(string: string).visibility
                expect(visibility).to(equal(.greaterThan(.meters(9999))))
            }
            
            it("parses missing visibilities") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 M R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let metar = try! METAR.from(string: string)
                expect(metar.visibility).to(beNil())
            }
        }
    }
}
