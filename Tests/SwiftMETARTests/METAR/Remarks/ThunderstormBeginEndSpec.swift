import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class ThunderstormBeginEndSpec: QuickSpec {
    override func spec() {
        describe("thunderstorm begin/end") {
            it("parses a 'TSB0159E30' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 TSB0159E30"
                let observation = try! METAR.from(string: string)
                
                let begin = Date().this(day: 1, hour: 1, minute: 59)
                let end = Date().this(day: 1, hour: 19, minute: 30)
                expect(observation.remarks.map { $0.remark }).to(contain(.thunderstormBeginEnd(events: [
                    .init(type: .began, time: begin),
                    .init(type: .ended, time: end)
                ])))
            }
        }
    }
}
