import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class ObservationTypeSpec: QuickSpec {
    override func spec() {
        describe("observation type") {
            it("parses a 'AO1' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO1 ACFT MSHP"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.observationType(.automated, augmented: false)))
            }
            
            it("parses a 'AO2' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 ACFT MSHP"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.observationType(.automatedWithPrecipitation, augmented: false)))
            }
            
            it("parses a 'A02' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK A02 ACFT MSHP"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.observationType(.automatedWithPrecipitation, augmented: false)))
            }
            
            it("parses a 'AO2A' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2A ACFT MSHP"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.observationType(.automatedWithPrecipitation, augmented: true)))
            }
        }
    }
}
