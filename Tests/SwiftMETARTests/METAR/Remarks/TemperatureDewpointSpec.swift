import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class TemperatureDewpointSpec: AsyncSpec {
    override class func spec() {
        describe("temperature/dewpoint") {
            it("parses a 'T00261015' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 T00261015"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.temperatureDewpoint(temperature: 2.6, dewpoint: -1.5)))
            }

            it("parses a 'T0026' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 T0026"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.temperatureDewpoint(temperature: 2.6, dewpoint: nil)))
            }

            it("parses a 'T0026////' remark") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 T0026////"
                let observation = try await METAR.from(string: string)

                expect(observation.remarks.map(\.remark)).to(contain(.temperatureDewpoint(temperature: 2.6, dewpoint: nil)))
                expect(observation.remarks.map(\.remark)).notTo(contain(.unknown("////")))
            }
        }
    }
}
