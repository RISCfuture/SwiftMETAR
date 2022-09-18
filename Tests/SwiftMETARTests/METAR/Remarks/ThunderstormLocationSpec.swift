import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class ThunderstormLocationSpec: QuickSpec {
    override func spec() {
        describe("thunderstorm location") {
            it("parses a 'TS SE MOV NE' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TS SE MOV NE"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.thunderstormLocation(proximity: nil, directions: [.southeast], movingDirection: .northeast)))
            }
            
            it("parses a 'TS OHD MOV N' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TS OHD MOV N"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.thunderstormLocation(proximity: .overhead, directions: [], movingDirection: .north)))
            }
            
            it("parses a 'TS MOV N' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TS MOV N"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.thunderstormLocation(proximity: nil, directions: [], movingDirection: .north)))
            }
        }
    }
}
