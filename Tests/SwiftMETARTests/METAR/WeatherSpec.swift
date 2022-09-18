import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class WeatherSpec: QuickSpec {
    override func spec() {
        describe("weather phenomena") {
            it("parses light drizzle") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT -DZ OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let phenomena = try! METAR.from(string: string).weather!
                expect(phenomena.count).to(equal(1))
                
                expect(phenomena[0].intensity).to(equal(.light))
                expect(phenomena[0].descriptor).to(beNil())
                expect(phenomena[0].phenomena).to(equal([.drizzle]))
            }
            
            it("parses light rain and snow") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT -RASN OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let phenomena = try! METAR.from(string: string).weather!
                expect(phenomena.count).to(equal(1))
                
                expect(phenomena[0].intensity).to(equal(.light))
                expect(phenomena[0].descriptor).to(beNil())
                expect(phenomena[0].phenomena).to(equal([.rain, .snow]))
            }
            
            it("parses snow and mist") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT SN BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let phenomena = try! METAR.from(string: string).weather!
                expect(phenomena.count).to(equal(2))
                
                expect(phenomena[0].intensity).to(equal(.moderate))
                expect(phenomena[0].descriptor).to(beNil())
                expect(phenomena[0].phenomena).to(equal([.snow]))
                
                expect(phenomena[1].descriptor).to(beNil())
                expect(phenomena[1].phenomena).to(equal([.mist]))
            }
            
            it("parses light freezing rain and fog") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT -FZRA FG OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let phenomena = try! METAR.from(string: string).weather!
                expect(phenomena.count).to(equal(2))
                
                expect(phenomena[0].intensity).to(equal(.light))
                expect(phenomena[0].descriptor).to(equal(.freezing))
                expect(phenomena[0].phenomena).to(equal([.rain]))
                
                expect(phenomena[1].descriptor).to(beNil())
                expect(phenomena[1].phenomena).to(equal([.fog]))
            }
            
            it("parses moderate rainshower") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT SHRA OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let phenomena = try! METAR.from(string: string).weather!
                expect(phenomena.count).to(equal(1))
                
                expect(phenomena[0].intensity).to(equal(.moderate))
                expect(phenomena[0].descriptor).to(equal(.showering))
                expect(phenomena[0].phenomena).to(equal([.rain]))
            }
            
            it("parses blowing sand in the vicinity") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT VCBLSA OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let phenomena = try! METAR.from(string: string).weather!
                expect(phenomena.count).to(equal(1))
                
                expect(phenomena[0].intensity).to(equal(.vicinity))
                expect(phenomena[0].descriptor).to(equal(.blowing))
                expect(phenomena[0].phenomena).to(equal([.sand]))
            }
            
            it("parses light rain and snow, fog, and haze") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT -RASN FG HZ OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let phenomena = try! METAR.from(string: string).weather!
                expect(phenomena.count).to(equal(3))
                
                expect(phenomena[0].intensity).to(equal(.light))
                expect(phenomena[0].descriptor).to(beNil())
                expect(phenomena[0].phenomena).to(equal([.rain, .snow]))
                
                expect(phenomena[1].descriptor).to(beNil())
                expect(phenomena[1].phenomena).to(equal([.fog]))
                
                expect(phenomena[2].descriptor).to(beNil())
                expect(phenomena[2].phenomena).to(equal([.haze]))
            }
            
            it("parses thunderstorms") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT TS OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let phenomena = try! METAR.from(string: string).weather!
                expect(phenomena.count).to(equal(1))
                
                expect(phenomena[0].intensity).to(equal(.moderate))
                expect(phenomena[0].descriptor).to(beNil())
                expect(phenomena[0].phenomena).to(equal([.thunderstorm]))
            }
            
            it("parses thunderstorm, heavy rain") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +TSRA OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let phenomena = try! METAR.from(string: string).weather!
                expect(phenomena.count).to(equal(1))
                
                expect(phenomena[0].intensity).to(equal(.heavy))
                expect(phenomena[0].descriptor).to(equal(.thunderstorms))
                expect(phenomena[0].phenomena).to(equal([.rain]))
            }
            
            it("parses tornado, thunderstorm-associated rain and hail, and mist") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT +FC TSRAGR BR OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let phenomena = try! METAR.from(string: string).weather!
                expect(phenomena.count).to(equal(3))
                
                expect(phenomena[0].intensity).to(equal(.heavy))
                expect(phenomena[0].descriptor).to(beNil())
                expect(phenomena[0].phenomena).to(equal([.funnelCloud]))
                expect(phenomena[0].isTornado).to(beTrue())
                
                expect(phenomena[1].intensity).to(equal(.moderate))
                expect(phenomena[1].descriptor).to(equal(.thunderstorms))
                expect(phenomena[1].phenomena).to(equal([.rain, .hail]))
                
                expect(phenomena[2].intensity).to(equal(.moderate))
                expect(phenomena[2].descriptor).to(beNil())
                expect(phenomena[2].phenomena).to(equal([.mist]))
            }
            
            it("parses missing weather") {
                let string = "METAR KOKC 011955Z AUTO 22015G25KT 180V250 3/4SM R17L/2600FT M OVC010CB 18/16 A2992 RMK AO2 TSB25 TS OHD MOV E SLP132"
                let metar = try! METAR.from(string: string)
                expect(metar.weather).to(beNil())
            }
        }
    }
}
