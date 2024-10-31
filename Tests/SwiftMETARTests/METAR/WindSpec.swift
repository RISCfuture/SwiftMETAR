import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class WindSpec: AsyncSpec {
    override class func spec() {
        describe("winds") {
            it("parses winds < 10 knots") {
                let string = #"METAR KOKC 011955Z AUTO 05008KT 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
                let wind = try await METAR.from(string: string).wind
                expect(wind).to(equal(.direction(50, speed: .knots(8))))
            }
            
            it("parses winds < 100 knots") {
                let string = #"METAR KOKC 011955Z AUTO 15014KT 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
                let wind = try await METAR.from(string: string).wind
                expect(wind).to(equal(.direction(150, speed: .knots(14))))
            }
            
            it("parses winds ≥ 100 knots") {
                let string = #"METAR KOKC 011955Z AUTO 340112KT 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
                let wind = try await METAR.from(string: string).wind
                expect(wind).to(equal(.direction(340, speed: .knots(112))))
            }
            
            it("parses wind gusts") {
                let string = #"METAR KOKC 011955Z AUTO 27020G35KT 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
                let wind = try await METAR.from(string: string).wind
                expect(wind).to(equal(.direction(270, speed: .knots(20), gust: .knots(35))))
            }
            
            it("parses light variable winds") {
                let string = #"METAR KOKC 011955Z AUTO VRB03KT 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
                let wind = try await METAR.from(string: string).wind
                expect(wind).to(equal(.variable(speed: .knots(3))))
            }
            
            it("parses light variable winds with heading range") {
                let string = #"METAR KOKC 011955Z AUTO VRB03KT 030V150 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
                let wind = try await METAR.from(string: string).wind
                expect(wind).to(equal(.variable(speed: .knots(3), headingRange: (30, 150))))
            }
            
            it("parses strong variable winds") {
                let string = #"METAR KOKC 011955Z AUTO 21010KT 180V240 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
                let wind = try await METAR.from(string: string).wind
                expect(wind).to(equal(.directionRange(210, headingRange: (180, 240), speed: .knots(10))))
            }
            
            it("parses calm winds") {
                let string = #"METAR KOKC 011955Z AUTO 00000KT 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"#
                let wind = try await METAR.from(string: string).wind
                expect(wind).to(equal(.calm))
            }
        }
    }
}
