import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class PrecipitationBeginEndSpec: QuickSpec {
    override func spec() {
        describe("precipitation begin/end") {
            it("parses a 'RAB05E30SNB20E55' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 RAB05E30SNB20E55"
                let observation = try! METAR.from(string: string)
                
                let rainBegin = Date().this(day: 1, hour: 19, minute: 5)!
                let rainEnd = Date().this(day: 1, hour: 19, minute: 30)!
                let snowBegin = Date().this(day: 1, hour: 19, minute: 20)!
                let snowEnd = Date().this(day: 1, hour: 19, minute: 55)!
                
                expect(observation.remarks.map { $0.remark }).to(contain(.precipitationBeginEnd(events: [
                    .init(event: .began, type: .rain, descriptor: nil, time: rainBegin),
                    .init(event: .ended, type: .rain, descriptor: nil, time: rainEnd),
                    .init(event: .began, type: .snow, descriptor: nil, time: snowBegin),
                    .init(event: .ended, type: .snow, descriptor: nil, time: snowEnd)
                ])))
            }
            
            it("parses a 'SHRAB05E30SHSNB20E55' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 SHRAB05E30SHSNB20E55"
                let observation = try! METAR.from(string: string)
                
                let rainBegin = Date().this(day: 1, hour: 19, minute:  5)!
                let rainEnd = Date().this(day: 1, hour: 19, minute: 30)!
                let snowBegin = Date().this(day: 1, hour: 19, minute: 20)!
                let snowEnd = Date().this(day: 1, hour: 19, minute: 55)!
                
                expect(observation.remarks.map { $0.remark }).to(contain(.precipitationBeginEnd(events: [
                    .init(event: .began, type: .rain, descriptor: .showering, time: rainBegin),
                    .init(event: .ended, type: .rain, descriptor: .showering, time: rainEnd),
                    .init(event: .began, type: .snow, descriptor: .showering, time: snowBegin),
                    .init(event: .ended, type: .snow, descriptor: .showering, time: snowEnd)
                ])))
            }
            
            it("parses a 'RAB0456E09B26' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 RAB0456E09B26"
                let observation = try! METAR.from(string: string)
                
                let rainBegin1 = Date().this(day: 1, hour: 4, minute: 56)!
                let rainEnd = Date().this(day: 1, hour: 19, minute: 9)!
                let rainBegin2 = Date().this(day: 1, hour: 19, minute: 26)!
                
                expect(observation.remarks.map { $0.remark }).to(contain(.precipitationBeginEnd(events: [
                    .init(event: .began, type: .rain, descriptor: nil, time: rainBegin1),
                    .init(event: .ended, type: .rain, descriptor: nil, time: rainEnd),
                    .init(event: .began, type: .rain, descriptor: nil, time: rainBegin2)
                ])))
            }
        }
    }
}
