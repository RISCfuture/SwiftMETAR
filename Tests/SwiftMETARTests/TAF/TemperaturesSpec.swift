import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class TemperaturesSpec: QuickSpec {
    override func spec() {
        describe("temperatures") {
            it("parses temperatures") {
                let string = """
                TAF KFHU 251400Z
                    2514/2620 25009KT 9999 FEW300 QNH3007INS
                    BECMG 2515/2516 35009KT 9999 FEW300 QNH3007INS
                    BECMG 2519/2520 32012G18KT 9999 SKC 510005 QNH2998INS
                    BECMG 2616/2617 07009KT 9999 SKC QNH3009INS
                    BECMG 2618/2619 23010G15KT 9999 SKC 510005 QNH3007INS
                    TX33/2522Z TN16/2514Z T18/2517Z
                """
                let forecast = try! TAF.from(string: string)
                expect(forecast.temperatures).to(equal([
                    .init(type: .maximum, value: 33, time: Date().this(day: 25, hour: 22)!),
                    .init(type: .minimum, value: 16, time: Date().this(day: 25, hour: 14)!),
                    .init(type: nil, value: 18, time: Date().this(day: 25, hour: 17)!),
                ]))
            }
        }
    }
}
