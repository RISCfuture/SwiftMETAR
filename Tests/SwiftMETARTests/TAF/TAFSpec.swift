import Foundation
import Quick
import Nimble

@testable import SwiftMETAR

class TAFSpec: QuickSpec {
    override func spec() {
        it("parses example #1") {
            let string = """
            TAF KPIR
                111140Z 1112/1212 13012KT P6SM BKN100 WS020/35035KT
                    TEMPO 1112/1114 5SM BR
                FM111500 16015G25KT P6SM SCT040 BKN250
                FM120000 14012KT P6SM BKN080 OVC150
                    PROB30 1200/1204 3SM TSRA BKN030CB
                FM120400 14008KT P6SM SCT040 OVC080
                    TEMPO 1204/1208 3SM TSRA OVC030CB
            """
            let forecast = try! TAF.from(string: string)
            
            expect(forecast.issuance).to(equal(.routine))
            expect(forecast.airportID).to(equal("KPIR"))
            expect(forecast.originCalendarDate).to(equal(.this(day: 11, hour: 11, minute: 40)))
            expect(forecast.groups.count).to(equal(7))
            
            let groups: Array<TAF.Group> = [
                .init(
                    period: .range(.init(start: .this(day: 11, hour: 12), end: .this(day: 12, hour: 12))),
                    wind: .direction(130, speed: .knots(12)),
                    visibility: .greaterThan(.statuteMiles(6)),
                    weather: [],
                    conditions: [.broken(10_000)],
                    windshear: .init(height: 2000, wind: .direction(350, speed: .knots(35)))),
                .init(
                    period: .temporary(.init(start: .this(day: 11, hour: 12), end: .this(day: 11, hour: 14))),
                    wind: nil,
                    visibility: .equal(.statuteMiles(5)),
                    weather: [.init(intensity: .moderate, descriptor: nil, phenomena: [.mist])],
                    conditions: [],
                    windshear: nil),
                .init(
                    period: .from(.this(day: 11, hour: 15, minute: 0)),
                    wind: .direction(160, speed: .knots(15), gust: .knots(25)),
                    visibility: .greaterThan(.statuteMiles(6)),
                    weather: [],
                    conditions: [.scattered(4000), .broken(25_000)],
                    windshear: nil),
                .init(
                    period: .from(.this(day: 12, hour: 0, minute: 0)),
                    wind: .direction(140, speed: .knots(12)),
                    visibility: .greaterThan(.statuteMiles(6)),
                    weather: [],
                    conditions: [.broken(8000), .overcast(15_000)],
                    windshear: nil),
                .init(
                    period: .probability(30, period: .init(start: .this(day: 12, hour: 0), end: .this(day: 12, hour: 4))),
                    wind: nil,
                    visibility: .equal(.statuteMiles(3)),
                    weather: [.init(intensity: .moderate, descriptor: .thunderstorms, phenomena: [.rain])],
                    conditions: [.broken(3000, type: .cumulonimbus)],
                    windshear: nil),
                .init(
                    period: .from(.this(day: 12, hour: 4, minute: 0)),
                    wind: .direction(140, speed: .knots(8)),
                    visibility: .greaterThan(.statuteMiles(6)),
                    weather: [],
                    conditions: [.scattered(4000), .overcast(8000)],
                    windshear: nil),
                .init(
                    period: .temporary(.init(start: .this(day: 12, hour: 4), end: .this(day: 12, hour: 8))),
                    wind: nil,
                    visibility: .equal(.statuteMiles(3)),
                    weather: [.init(intensity: .moderate, descriptor: .thunderstorms, phenomena: [.rain])],
                    conditions: [.overcast(3000, type: .cumulonimbus)],
                    windshear: nil)
            ]
            
            expect(forecast.groups).to(equal(groups))
        }
        
        it("parses example #2") {
            let string = """
            TAF AMD KEYW
                131555Z 1316/1412 VRB03KT P6SM VCTS SCT025CB BKN250
                    TEMPO 1316/1318 2SM TSRA BKN020CB
                FM131800 VRB03KT P6SM SCT025 BKN250
                    TEMPO 1320/1324 1SM TSRA OVC010CB
                FM140000 VRB03KT P6SM VCTS SCT020CB BKN120
                    TEMPO 1408/1412 BKN020CB
            """
            let forecast = try! TAF.from(string: string)
            
            expect(forecast.issuance).to(equal(.amended))
            expect(forecast.airportID).to(equal("KEYW"))
            expect(forecast.originCalendarDate).to(equal(.this(day: 13, hour: 15, minute: 55)))
            expect(forecast.groups.count).to(equal(6))
            
            let groups: Array<TAF.Group> = [
                .init(
                    period: .range(.init(start: .this(day: 13, hour: 16), end: .this(day: 14, hour: 12))),
                    wind: .variable(speed: .knots(3)),
                    visibility: .greaterThan(.statuteMiles(6)),
                    weather: [.init(intensity: .vicinity, descriptor: nil, phenomena: [.thunderstorm])],
                    conditions: [.scattered(2500, type: .cumulonimbus), .broken(25_000)],
                    windshear: nil),
                .init(
                    period: .temporary(.init(start: .this(day: 13, hour: 16), end: .this(day: 13, hour: 18))),
                    wind: nil,
                    visibility: .equal(.statuteMiles(2)),
                    weather: [.init(intensity: .moderate, descriptor: .thunderstorms, phenomena: [.rain])],
                    conditions: [.broken(2000, type: .cumulonimbus)],
                    windshear: nil),
                .init(
                    period: .from(.this(day: 13, hour: 18, minute: 0)),
                    wind: .variable(speed: .knots(3)),
                    visibility: .greaterThan(.statuteMiles(6)),
                    weather: [],
                    conditions: [.scattered(2500), .broken(25_000)],
                    windshear: nil),
                .init(
                    period: .temporary(.init(start: .this(day: 13, hour: 20), end: .this(day: 14, hour: 0))),
                    wind: nil,
                    visibility: .equal(.statuteMiles(1)),
                    weather: [.init(intensity: .moderate, descriptor: .thunderstorms, phenomena: [.rain])],
                    conditions: [.overcast(1000, type: .cumulonimbus)],
                    windshear: nil),
                .init(
                    period: .from(.this(day: 14, hour: 0, minute: 0)),
                    wind: .variable(speed: .knots(3)),
                    visibility: .greaterThan(.statuteMiles(6)),
                    weather: [.init(intensity: .vicinity, descriptor: nil, phenomena: [.thunderstorm])],
                    conditions: [.scattered(2000, type: .cumulonimbus), .broken(12_000)],
                    windshear: nil),
                .init(
                    period: .temporary(.init(start: .this(day: 14, hour: 8), end: .this(day: 14, hour: 12))),
                    wind: nil,
                    visibility: nil,
                    weather: [],
                    conditions: [.broken(2000, type: .cumulonimbus)],
                    windshear: nil)
            ]
            
            expect(forecast.groups).to(equal(groups))
        }
        
        it("parses example #3") {
            let string = """
            TAF
                KCRP 111730Z 1118/1218 19007KT P6SM SCT030
                    TEMPO 1118/1120 BKN040
                FM112000 16011KT P6SM VCTS FEW030CB SCT250
                FM120200 14006KT P6SM FEW025 SCT250
                FM120800 VRB03KT 5SM BR SCT012
                FM121500 17007KT P6SM SCT025
            RMK NXT FCST BY 00Z=
            """
            let forecast = try! TAF.from(string: string)
            
            expect(forecast.issuance).to(equal(.routine))
            expect(forecast.airportID).to(equal("KCRP"))
            expect(forecast.originCalendarDate).to(equal(.this(day: 11, hour: 17, minute: 30)))
            expect(forecast.groups.count).to(equal(6))
            expect(forecast.remarks).to(equal("NXT FCST BY 00Z="))
            
            let groups: Array<TAF.Group> = [
                .init(period: .range(.init(start: .this(day: 11, hour: 18), end: .this(day: 12, hour: 18))),
                      wind: .direction(190, speed: .knots(7)),
                      visibility: .greaterThan(.statuteMiles(6)),
                      weather: [],
                      conditions: [.scattered(3000)],
                      windshear: nil),
                .init(period: .temporary(.init(start: .this(day: 11, hour: 18), end: .this(day: 11, hour: 20))),
                      wind: nil,
                      visibility: nil,
                      weather: [],
                      conditions: [.broken(4000)],
                      windshear: nil),
                .init(period: .from(.this(day: 11, hour: 20, minute: 0)),
                      wind: .direction(160, speed: .knots(11)),
                      visibility: .greaterThan(.statuteMiles(6)),
                      weather: [.init(intensity: .vicinity, descriptor: nil, phenomena: [.thunderstorm])],
                      conditions: [.few(3000, type: .cumulonimbus), .scattered(25_000)],
                      windshear: nil),
                .init(period: .from(.this(day: 12, hour: 2, minute: 0)),
                      wind: .direction(140, speed: .knots(6)),
                      visibility: .greaterThan(.statuteMiles(6)),
                      weather: [],
                      conditions: [.few(2500), .scattered(25_000)],
                      windshear: nil),
                .init(period: .from(.this(day: 12, hour: 8, minute: 0)),
                      wind: .variable(speed: .knots(3)),
                      visibility: .equal(.statuteMiles(5)),
                      weather: [.init(intensity: .moderate, descriptor: nil, phenomena: [.mist])],
                      conditions: [.scattered(1200)],
                      windshear: nil),
                .init(period: .from(.this(day: 12, hour: 15, minute: 0)),
                      wind: .direction(170, speed: .knots(7)),
                      visibility: .greaterThan(.statuteMiles(6)),
                      weather: [],
                      conditions: [.scattered(2500)],
                      windshear: nil)
            ]
            
            expect(forecast.groups).to(equal(groups))
        }
        
        describe("during") {
            it("returns the conditions active at a time") {
                let string = """
                TAF KPIR
                    111140Z 1112/1212 13012KT P6SM BKN100 WS020/35035KT
                        TEMPO 1112/1114 5SM BR
                    FM111500 16015G25KT P6SM SCT040 BKN250
                    FM120000 14012KT P6SM BKN080 OVC150
                        PROB30 1200/1204 3SM TSRA BKN030CB
                    FM120400 14008KT P6SM SCT040 OVC080
                        TEMPO 1204/1208 3SM TSRA OVC030CB
                """
                let forecast = try! TAF.from(string: string)
                
                let components = DateComponents.this(day: 12, hour: 2)
                let date = zuluCal.date(from: components)!
                expect(forecast.during(date)).to(equal(
                    .init(period: .from(.this(day: 12, hour: 2)),
                          wind: .direction(140, speed: .knots(12)),
                          visibility: .equal(.statuteMiles(3)),
                          weather: [.init(intensity: .moderate, descriptor: .thunderstorms, phenomena: [.rain])],
                          conditions: [.broken(3000, type: .cumulonimbus)],
                          windshear: nil)
                ))
            }
            
            it("returns nil if the time is outside the forecast period") {
                let string = """
                TAF KPIR
                    111140Z 1112/1212 13012KT P6SM BKN100 WS020/35035KT
                        TEMPO 1112/1114 5SM BR
                    FM111500 16015G25KT P6SM SCT040 BKN250
                    FM120000 14012KT P6SM BKN080 OVC150
                        PROB30 1200/1204 3SM TSRA BKN030CB
                    FM120400 14008KT P6SM SCT040 OVC080
                        TEMPO 1204/1208 3SM TSRA OVC030CB
                """
                let forecast = try! TAF.from(string: string)
                
                let components = DateComponents.this(day: 10, hour: 2)
                let date = zuluCal.date(from: components)!
                
                expect(forecast.during(date)).to(beNil())
            }
        }
    }
}
