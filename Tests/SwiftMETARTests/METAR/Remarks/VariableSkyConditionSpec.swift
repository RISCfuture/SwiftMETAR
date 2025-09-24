import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class VariableSkyConditionSpec: AsyncSpec {
  override class func spec() {
    describe("variable sky condition") {
      it("parses a 'BKN014 V OVC' remark") {
        let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 BKN014 V OVC"
        let observation = try await METAR.from(string: string)

        expect(observation.remarks.map(\.remark)).to(
          contain(.variableSkyCondition(low: .broken, high: .overcast, height: 1400))
        )
      }

      it("parses a 'BKN V OVC' remark") {
        let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 BKN V OVC"
        let observation = try await METAR.from(string: string)

        expect(observation.remarks.map(\.remark)).to(
          contain(.variableSkyCondition(low: .broken, high: .overcast, height: nil))
        )
      }
    }
  }
}
