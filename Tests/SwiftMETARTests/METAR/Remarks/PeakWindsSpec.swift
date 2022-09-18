import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class PeakWindsSpec: QuickSpec {
    override func spec() {
        describe("peak winds") {
            it("parses a 'PK WND 28045/15' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 PK WND 28045/15"
                let observation = try! METAR.from(string: string)
                
                let date = Date().this(day: 1, hour: 19, minute: 15)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.peakWinds(.direction(280, speed: .knots(45), gust: nil), time: date)))
            }
            
            it("parses a 'PK WND 28045/1215' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 PK WND 28045/1215"
                let observation = try! METAR.from(string: string)
                
                let date = Date().this(day: 1, hour: 12, minute: 15)
                
                expect(observation.remarks.map { $0.remark }).to(contain(.peakWinds(.direction(280, speed: .knots(45), gust: nil), time: date)))
            }
        }
    }
}
