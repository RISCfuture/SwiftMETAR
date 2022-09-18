import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class ObservedPrecipitationSpec: QuickSpec {
    override func spec() {
        describe("observed precipitation") {
            it("parses a 'VIRGA SW' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIRGA SW"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.observedPrecipitation(type: .virga, proximity: nil, directions: [.southwest])))
            }
            
            it("parses a 'SH N THRU NE' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 SH N THRU NE"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.observedPrecipitation(type: .showers, proximity: nil, directions: [.north, .northeast])))
            }
            
            it("parses a 'SHRA DSNT SW' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 SHRA DSNT SW"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.observedPrecipitation(type: .showeringRain, proximity: .distant, directions: [.southwest])))
            }
            
            it("parses a 'VIRGA OHD' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 VIRGA OHD"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.observedPrecipitation(type: .virga, proximity: .overhead, directions: [])))
            }
        }
    }
}
