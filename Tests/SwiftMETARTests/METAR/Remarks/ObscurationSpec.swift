import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class ObscurationSpec: AsyncSpec {
  override class func spec() {
    describe("obscuration") {
      it("parses a 'FG SCT000' remark") {
        let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 FG SCT000"
        let observation = try await METAR.from(string: string)

        expect(observation.remarks.map(\.remark)).to(
          contain(.obscuration(type: .fog, amount: .scattered, height: 0))
        )
      }

      it("parses a 'FU BKN020' remark") {
        let string = "METAR KOKC 011955Z AUTO 22015G25KT 3/4SM CLR 18/16 A2992 RMK AO2 FU BKN020"
        let observation = try await METAR.from(string: string)

        expect(observation.remarks.map(\.remark)).to(
          contain(.obscuration(type: .smoke, amount: .broken, height: 2000))
        )
      }
    }
  }
}
