import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class METARSpec: QuickSpec {
    override func spec() {
        describe("report type") {
            it("parses the report type") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                expect(try! METAR.from(string: string).issuance).to(equal(.routine))
            }
        }
        
        describe("station identifier") {
            it("parses the station identifier") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                expect(try! METAR.from(string: string).stationID).to(equal("KOKC"))
            }
        }
        
        describe("date and time") {
            it("parses the date") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let date = try! METAR.from(string: string).calendarDate
                
                expect(date).to(equal(.this(day: 1, hour: 19, minute: 55)))
            }
            
            it("parses the date from a reference date") {
                let referenceComponents = DateComponents(year: 2005, month: 11)
                let referenceDate = zuluCal.nextDate(after: Date(), matching: referenceComponents, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .backward)!
                
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let date = try! METAR.from(string: string, on: referenceDate).calendarDate
                
                expect(date).to(equal(referenceDate.this(day: 1, hour: 19, minute: 55)))
            }
        }
        
        describe("observer") {
            it("parses automated reports") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                expect(try! METAR.from(string: string).observer).to(equal(.automated))
            }
            
            it("parses corrected reports") {
                let string = "METAR KOKC 011955Z COR 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                expect(try! METAR.from(string: string).observer).to(equal(.corrected))
            }
            
            it("parses human observed reports") {
                let string = "METAR KOKC 011955Z 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                expect(try! METAR.from(string: string).observer).to(equal(.human))
            }
        }
        
        describe("remarks") {
            it("parses empty remarks") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC010CB 18/16 A2992"
                let observation = try! METAR.from(string: string)
                expect(observation.remarks).to(beEmpty())
            }
        }
    }
}
