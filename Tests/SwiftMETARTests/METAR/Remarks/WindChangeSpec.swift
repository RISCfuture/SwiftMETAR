import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class WindChangeSpec: QuickSpec {
    override func spec() {
        describe("wind change") {
            it("parses a 'WND 14006KT AFT 2701' remark") {
                let string = """
                TAF KLUF
                    261200Z 2612/2718 VRB06KT 9999 SKC QNH2974INS
                    BECMG 2621/2622 24012G18KT 9999 FEW300 QNH2978INS WND VRB06KT AFT 2707
                    TX39/2621Z TN24/2612Z
                """
                let forecast = try! TAF.from(string: string)
                
                expect(forecast.groups[1].remarks.map { $0.remark }).to(contain(.windChange(wind: .variable(speed: .knots(6)), after: Date().this(day: 27, hour: 7)!)))
            }
            
            it("parses a 'WND VRB06KT AFT 2707' remark") {
                let string = """
                TAF KSKF
                    261800Z 2618/2800 19008KT 9999 SKC QNH2988INS WND 14006KT AFT 2701
                    BECMG 2711/2712 VRB03KT 9999 SCT015 QNH3001INS
                    BECMG 2714/2715 18007KT 9999 FEW030 QNH2988INS
                    TX35/2622Z TN21/2712Z
                """
                let forecast = try! TAF.from(string: string)
                
                expect(forecast.groups[0].remarks.map { $0.remark }).to(contain(.windChange(wind: .direction(140, speed: .knots(6)), after: Date().this(day: 27, hour: 1)!)))
            }
        }
    }
}
