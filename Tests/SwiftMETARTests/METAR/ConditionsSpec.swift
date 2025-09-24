import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class ConditionsSpec: AsyncSpec {
  override class func spec() {
    describe("sky conditions") {
      it("parses sky clear") {
        let string =
          "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR SKC 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
        let conditions = try await METAR.from(string: string).conditions

        expect(conditions.count).to(equal(1))
        expect(conditions[0]).to(equal(.skyClear))
      }

      it("parses sky clear below 12,000") {
        let string =
          "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR CLR 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
        let conditions = try await METAR.from(string: string).conditions

        expect(conditions.count).to(equal(1))
        expect(conditions[0]).to(equal(.clear))
      }

      it("parses few at 400") {
        let string =
          "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR FEW004 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
        let conditions = try await METAR.from(string: string).conditions

        expect(conditions.count).to(equal(1))
        expect(conditions[0]).to(equal(.few(400)))
      }

      it("parses scattered towering cumulus at 2300") {
        let string =
          "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR SCT023TCU 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
        let conditions = try await METAR.from(string: string).conditions

        expect(conditions.count).to(equal(1))
        expect(conditions[0]).to(equal(.scattered(2300, type: .toweringCumulus)))
      }

      it("parses broken at 10,500") {
        let string =
          "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR BKN105 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
        let conditions = try await METAR.from(string: string).conditions

        expect(conditions.count).to(equal(1))
        expect(conditions[0]).to(equal(.broken(10_500)))
      }

      it("parses overcast at 25,000") {
        let string =
          "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR OVC250 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
        let conditions = try await METAR.from(string: string).conditions

        expect(conditions.count).to(equal(1))
        expect(conditions[0]).to(equal(.overcast(25_000)))
      }

      it("parses vertical visibility 100") {
        let string =
          "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR VV001 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
        let conditions = try await METAR.from(string: string).conditions

        expect(conditions.count).to(equal(1))
        expect(conditions[0]).to(equal(.indefinite(100)))
      }

      it("parses few at 1200, scattered at 4600") {
        let string =
          "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR FEW012 SCT046 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
        let conditions = try await METAR.from(string: string).conditions

        expect(conditions.count).to(equal(2))
        expect(conditions[0]).to(equal(.few(1200)))
        expect(conditions[1]).to(equal(.scattered(4600)))
      }

      it("parses scattered at 3300, broken at 8500") {
        let string =
          "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR SCT033 BKN085 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
        let conditions = try await METAR.from(string: string).conditions

        expect(conditions.count).to(equal(2))
        expect(conditions[0]).to(equal(.scattered(3300)))
        expect(conditions[1]).to(equal(.broken(8500)))
      }

      it("parses scattered at 1800, overcast cumulonimbus at 3200") {
        let string =
          "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR SCT018 OVC032CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
        let conditions = try await METAR.from(string: string).conditions

        expect(conditions.count).to(equal(2))
        expect(conditions[0]).to(equal(.scattered(1800)))
        expect(conditions[1]).to(equal(.overcast(3200, type: .cumulonimbus)))
      }

      it("parses scattered at 900, scattered at 2400, broken at 4800") {
        let string =
          "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA BR SCT009 SCT024 BKN048 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
        let conditions = try await METAR.from(string: string).conditions

        expect(conditions.count).to(equal(3))
        expect(conditions[0]).to(equal(.scattered(900)))
        expect(conditions[1]).to(equal(.scattered(2400)))
        expect(conditions[2]).to(equal(.broken(4800)))
      }
    }
  }
}
