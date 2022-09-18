import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class MaintenanceSpec: QuickSpec {
    override func spec() {
        describe("maintenance required") {
            it("parses a '$' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 ACFT MSHP $"
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.maintenance))
            }
            
            it("parses a '$ ' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 ACFT MSHP $ "
                let observation = try! METAR.from(string: string)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.maintenance))
            }
        }
    }
}
