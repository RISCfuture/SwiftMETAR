import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class SignificantCloudsSpec: QuickSpec {
    override func spec() {
        describe("significant clouds") {
                it("parses a 'CB W MOV E' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 CB W MOV E"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.significantClouds(type: .cb, directions: [.west], movingDirection: .east, distant: false, apparent: false)))
            }
            
            it("parses a 'CB DSNT W' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 CB DSNT W"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.significantClouds(type: .cb, directions: [.west], movingDirection: nil, distant: true, apparent: false)))
            }
            
            it("parses a 'TCU W' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TCU W"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.significantClouds(type: .cuCon, directions: [.west], movingDirection: nil, distant: false, apparent: false)))
            }
            
            it("parses a 'ACC NW' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 ACC NW"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.significantClouds(type: .acCas, directions: [.northwest], movingDirection: nil, distant: false, apparent: false)))
            }
            
            it("parses a 'ACSL SW-W' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 ACSL SW-W"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.significantClouds(type: .acLen, directions: [.southwest, .west], movingDirection: nil, distant: false, apparent: false)))
            }
            
            it("parses a 'APRNT ROTOR CLD NE' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 APRNT ROTOR CLD NE"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.significantClouds(type: .rotor, directions: [.northeast], movingDirection: nil, distant: false, apparent: true)))
            }
            
            it("parses a 'CCSL S' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 CCSL S"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.significantClouds(type: .ccLen, directions: [.south], movingDirection: nil, distant: false, apparent: false)))
            }
            
            it("parses a 'CB DSNT N AND NE' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 CB DSNT N AND NE"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.significantClouds(type: .cb, directions: [.north, .northeast], movingDirection: nil, distant: true, apparent: false)))
            }
        }
    }
}
