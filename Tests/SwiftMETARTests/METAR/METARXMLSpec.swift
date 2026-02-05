import Foundation
import Nimble
import Quick

@testable import SwiftMETAR

class METARXMLSpec: AsyncSpec {
  override class func spec() {
    describe("METAR XML parsing") {
      it("parses a basic METAR") {
        let xml = """
          <response><data>
          <METAR>
            <raw_text>METAR KOKC 011955Z AUTO 22015G25KT 3/4SM +TSRA BR OVC010CB 18/16 \
          A2992</raw_text>
            <metar_type>METAR</metar_type>
            <station_id>KOKC</station_id>
            <observation_time>2024-01-01T19:55:00Z</observation_time>
            <quality_control_flags>
              <auto>TRUE</auto>
            </quality_control_flags>
            <wind_dir_degrees>220</wind_dir_degrees>
            <wind_speed_kt>15</wind_speed_kt>
            <wind_gust_kt>25</wind_gust_kt>
            <visibility_statute_mi>0.75</visibility_statute_mi>
            <wx_string>+TSRA BR</wx_string>
            <sky_condition sky_cover="OVC" cloud_base_ft_agl="1000" cloud_type="CB"/>
            <temp_c>18.0</temp_c>
            <dewpoint_c>16.0</dewpoint_c>
            <altim_in_hg>29.92</altim_in_hg>
          </METAR>
          </data></response>
          """

        var metars = [METAR]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          metars.append(try result.get())
        }

        expect(metars.count).to(equal(1))
        let metar = metars[0]

        expect(metar.stationID).to(equal("KOKC"))
        expect(metar.issuance).to(equal(.routine))
        expect(metar.observer).to(equal(.automated))
        expect(metar.wind).to(equal(.direction(220, speed: .knots(15), gust: .knots(25))))
        expect(metar.visibility).to(
          equal(.equal(.statuteMilesDecimal(0.75)))
        )
        expect(metar.conditions).to(equal([.overcast(1000, type: .cumulonimbus)]))
        expect(metar.temperature).to(equal(18))
        expect(metar.dewpoint).to(equal(16))
        expect(metar.altimeter).to(equal(.inHg(2992)))
        expect(metar.runwayVisibility).to(beEmpty())
        expect(metar.remarks).to(beEmpty())
        expect(metar.remarksString).to(beNil())
      }

      it("parses a SPECI report") {
        let xml = """
          <response><data>
          <METAR>
            <raw_text>SPECI KJFK 021530Z 36010KT 10SM FEW250 25/18 A3001</raw_text>
            <metar_type>SPECI</metar_type>
            <station_id>KJFK</station_id>
            <observation_time>2024-01-02T15:30:00Z</observation_time>
            <wind_dir_degrees>360</wind_dir_degrees>
            <wind_speed_kt>10</wind_speed_kt>
            <visibility_statute_mi>10</visibility_statute_mi>
            <sky_condition sky_cover="FEW" cloud_base_ft_agl="25000"/>
            <temp_c>25.0</temp_c>
            <dewpoint_c>18.0</dewpoint_c>
            <altim_in_hg>30.01</altim_in_hg>
          </METAR>
          </data></response>
          """

        var metars = [METAR]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          metars.append(try result.get())
        }

        expect(metars.count).to(equal(1))
        let metar = metars[0]

        expect(metar.issuance).to(equal(.special))
        expect(metar.observer).to(equal(.human))
      }

      it("parses calm winds") {
        let xml = """
          <response><data>
          <METAR>
            <station_id>KDEN</station_id>
            <observation_time>2024-01-01T12:00:00Z</observation_time>
            <wind_dir_degrees>0</wind_dir_degrees>
            <wind_speed_kt>0</wind_speed_kt>
            <visibility_statute_mi>10</visibility_statute_mi>
            <sky_condition sky_cover="CLR"/>
            <temp_c>5.0</temp_c>
            <dewpoint_c>-2.0</dewpoint_c>
            <altim_in_hg>30.12</altim_in_hg>
          </METAR>
          </data></response>
          """

        var metars = [METAR]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          metars.append(try result.get())
        }

        expect(metars.count).to(equal(1))
        let metar = metars[0]

        expect(metar.wind).to(equal(.calm))
        expect(metar.conditions).to(equal([.clear]))
        expect(metar.temperature).to(equal(5))
        expect(metar.dewpoint).to(equal(-2))
      }

      it("parses corrected report") {
        let xml = """
          <response><data>
          <METAR>
            <station_id>KORD</station_id>
            <observation_time>2024-01-01T12:00:00Z</observation_time>
            <quality_control_flags>
              <corrected>TRUE</corrected>
            </quality_control_flags>
            <wind_dir_degrees>180</wind_dir_degrees>
            <wind_speed_kt>5</wind_speed_kt>
            <visibility_statute_mi>6+</visibility_statute_mi>
            <sky_condition sky_cover="SCT" cloud_base_ft_agl="5000"/>
            <temp_c>20.0</temp_c>
            <dewpoint_c>15.0</dewpoint_c>
            <altim_in_hg>29.88</altim_in_hg>
          </METAR>
          </data></response>
          """

        var metars = [METAR]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          metars.append(try result.get())
        }

        let metar = metars[0]
        expect(metar.observer).to(equal(.corrected))
        expect(metar.visibility).to(equal(.greaterThan(.statuteMilesDecimal(6))))
      }

      it("parses low visibility as less than (M1/4SM threshold)") {
        let xml = """
          <response><data>
          <METAR>
            <station_id>KLNP</station_id>
            <observation_time>2024-01-01T12:00:00Z</observation_time>
            <wind_dir_degrees>350</wind_dir_degrees>
            <wind_speed_kt>7</wind_speed_kt>
            <visibility_statute_mi>0.25</visibility_statute_mi>
            <wx_string>FZFG</wx_string>
            <sky_condition sky_cover="OVC" cloud_base_ft_agl="100"/>
            <temp_c>-5.0</temp_c>
            <dewpoint_c>-5.0</dewpoint_c>
            <altim_in_hg>30.10</altim_in_hg>
          </METAR>
          </data></response>
          """

        var metars = [METAR]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          metars.append(try result.get())
        }

        // M1/4SM is the minimum reportable visibility; XML loses the "M" prefix
        // so we assume visibility <= 1/4 SM is "less than"
        let metar = metars[0]
        expect(metar.visibility).to(equal(.lessThan(.statuteMiles(Ratio(1, 4)))))
      }

      it("parses vertical visibility") {
        let xml = """
          <response><data>
          <METAR>
            <station_id>KSFO</station_id>
            <observation_time>2024-01-01T12:00:00Z</observation_time>
            <wind_dir_degrees>0</wind_dir_degrees>
            <wind_speed_kt>3</wind_speed_kt>
            <visibility_statute_mi>0.25</visibility_statute_mi>
            <vert_vis_ft>200</vert_vis_ft>
            <temp_c>12.0</temp_c>
            <dewpoint_c>12.0</dewpoint_c>
            <altim_in_hg>30.05</altim_in_hg>
          </METAR>
          </data></response>
          """

        var metars = [METAR]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          metars.append(try result.get())
        }

        let metar = metars[0]
        expect(metar.conditions).to(equal([.indefinite(200)]))
      }

      it("parses multiple METARs") {
        let xml = """
          <response><data>
          <METAR>
            <station_id>KORD</station_id>
            <observation_time>2024-01-01T12:00:00Z</observation_time>
            <wind_dir_degrees>180</wind_dir_degrees>
            <wind_speed_kt>10</wind_speed_kt>
            <visibility_statute_mi>10</visibility_statute_mi>
            <sky_condition sky_cover="SKC"/>
            <temp_c>20.0</temp_c>
            <dewpoint_c>10.0</dewpoint_c>
            <altim_in_hg>30.00</altim_in_hg>
          </METAR>
          <METAR>
            <station_id>KJFK</station_id>
            <observation_time>2024-01-01T12:00:00Z</observation_time>
            <wind_dir_degrees>270</wind_dir_degrees>
            <wind_speed_kt>8</wind_speed_kt>
            <visibility_statute_mi>10</visibility_statute_mi>
            <sky_condition sky_cover="FEW" cloud_base_ft_agl="3000"/>
            <temp_c>22.0</temp_c>
            <dewpoint_c>14.0</dewpoint_c>
            <altim_in_hg>29.95</altim_in_hg>
          </METAR>
          </data></response>
          """

        var metars = [METAR]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          metars.append(try result.get())
        }

        expect(metars.count).to(equal(2))
        expect(metars[0].stationID).to(equal("KORD"))
        expect(metars[1].stationID).to(equal("KJFK"))
      }

      it("throws on missing station_id") {
        let xml = """
          <response><data>
          <METAR>
            <observation_time>2024-01-01T12:00:00Z</observation_time>
            <wind_dir_degrees>180</wind_dir_degrees>
            <wind_speed_kt>10</wind_speed_kt>
          </METAR>
          </data></response>
          """

        var results = [XMLParseResult<METAR>]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          results.append(result)
        }

        expect(results.count).to(equal(1))
        guard case .failure(let error, _) = results[0] else {
          fail("Expected failure")
          return
        }
        expect(error as? SwiftMETAR.Error).to(equal(.badFormat))
      }

      it("reports error on invalid observation_time") {
        let xml = """
          <response><data>
          <METAR>
            <station_id>KORD</station_id>
            <observation_time>not-a-date</observation_time>
            <wind_dir_degrees>180</wind_dir_degrees>
            <wind_speed_kt>10</wind_speed_kt>
            <visibility_statute_mi>10</visibility_statute_mi>
            <sky_condition sky_cover="SKC"/>
            <temp_c>20.0</temp_c>
            <dewpoint_c>10.0</dewpoint_c>
            <altim_in_hg>30.00</altim_in_hg>
          </METAR>
          </data></response>
          """

        var results = [XMLParseResult<METAR>]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          results.append(result)
        }

        expect(results.count).to(equal(1))
        guard case .failure(let error, _) = results[0] else {
          fail("Expected failure")
          return
        }
        expect(error as? SwiftMETAR.Error).to(equal(.invalidDate("not-a-date")))
      }

      it("reports error on invalid visibility") {
        let xml = """
          <response><data>
          <METAR>
            <station_id>KORD</station_id>
            <observation_time>2024-01-01T12:00:00Z</observation_time>
            <wind_dir_degrees>180</wind_dir_degrees>
            <wind_speed_kt>10</wind_speed_kt>
            <visibility_statute_mi>abc</visibility_statute_mi>
            <sky_condition sky_cover="SKC"/>
            <temp_c>20.0</temp_c>
            <dewpoint_c>10.0</dewpoint_c>
            <altim_in_hg>30.00</altim_in_hg>
          </METAR>
          </data></response>
          """

        var results = [XMLParseResult<METAR>]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          results.append(result)
        }

        expect(results.count).to(equal(1))
        guard case .failure(let error, _) = results[0] else {
          fail("Expected failure")
          return
        }
        expect(error as? SwiftMETAR.Error).to(equal(.invalidVisibility("abc")))
      }

      it("parses weather phenomena from wx_string") {
        let xml = """
          <response><data>
          <METAR>
            <station_id>KATL</station_id>
            <observation_time>2024-01-01T18:00:00Z</observation_time>
            <wind_dir_degrees>240</wind_dir_degrees>
            <wind_speed_kt>12</wind_speed_kt>
            <visibility_statute_mi>3</visibility_statute_mi>
            <wx_string>-RA BR</wx_string>
            <sky_condition sky_cover="BKN" cloud_base_ft_agl="1500"/>
            <sky_condition sky_cover="OVC" cloud_base_ft_agl="3000"/>
            <temp_c>15.0</temp_c>
            <dewpoint_c>14.0</dewpoint_c>
            <altim_in_hg>29.85</altim_in_hg>
          </METAR>
          </data></response>
          """

        var metars = [METAR]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          metars.append(try result.get())
        }

        let metar = metars[0]
        expect(metar.weather).toNot(beNil())
        expect(metar.weather?.count).to(equal(2))
        expect(metar.weather?[0].intensity).to(equal(.light))
        expect(metar.weather?[0].phenomena).to(equal(Set([.rain])))
        expect(metar.weather?[1].phenomena).to(equal(Set([.mist])))

        expect(metar.conditions.count).to(equal(2))
        expect(metar.conditions[0]).to(equal(.broken(1500)))
        expect(metar.conditions[1]).to(equal(.overcast(3000)))
      }

      it("parses variable winds (dir 0 with speed > 0)") {
        let xml = """
          <response><data>
          <METAR>
            <station_id>KLAX</station_id>
            <observation_time>2024-01-01T12:00:00Z</observation_time>
            <wind_dir_degrees>0</wind_dir_degrees>
            <wind_speed_kt>5</wind_speed_kt>
            <visibility_statute_mi>10</visibility_statute_mi>
            <sky_condition sky_cover="SKC"/>
            <temp_c>20.0</temp_c>
            <dewpoint_c>12.0</dewpoint_c>
            <altim_in_hg>30.10</altim_in_hg>
          </METAR>
          </data></response>
          """

        var metars = [METAR]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          metars.append(try result.get())
        }

        let metar = metars[0]
        expect(metar.wind).to(equal(.variable(speed: .knots(5))))
      }

      it("rounds temperatures correctly (half toward zero)") {
        let xml = """
          <response><data>
          <METAR>
            <station_id>KBOS</station_id>
            <observation_time>2024-01-01T12:00:00Z</observation_time>
            <wind_dir_degrees>90</wind_dir_degrees>
            <wind_speed_kt>8</wind_speed_kt>
            <visibility_statute_mi>10</visibility_statute_mi>
            <sky_condition sky_cover="FEW" cloud_base_ft_agl="10000"/>
            <temp_c>18.9</temp_c>
            <dewpoint_c>-3.4</dewpoint_c>
            <altim_in_hg>30.00</altim_in_hg>
          </METAR>
          </data></response>
          """

        var metars = [METAR]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          metars.append(try result.get())
        }

        // Normal rounding for non-.5 values
        let metar = metars[0]
        expect(metar.temperature).to(equal(19))  // 18.9 → 19
        expect(metar.dewpoint).to(equal(-3))  // -3.4 → -3
      }

      it("rounds .5 values toward zero (matching METAR format)") {
        let xml = """
          <response><data>
          <METAR>
            <station_id>KTEST</station_id>
            <observation_time>2024-01-01T12:00:00Z</observation_time>
            <wind_dir_degrees>90</wind_dir_degrees>
            <wind_speed_kt>8</wind_speed_kt>
            <visibility_statute_mi>10</visibility_statute_mi>
            <sky_condition sky_cover="CLR"/>
            <temp_c>12.5</temp_c>
            <dewpoint_c>-4.5</dewpoint_c>
            <altim_in_hg>30.00</altim_in_hg>
          </METAR>
          </data></response>
          """

        var metars = [METAR]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          metars.append(try result.get())
        }

        // METAR rounds .5 toward zero: 12.5 → 12, -4.5 → -4
        let metar = metars[0]
        expect(metar.temperature).to(equal(12))
        expect(metar.dewpoint).to(equal(-4))
      }

      it("parses the raw text") {
        let xml = """
          <response><data>
          <METAR>
            <raw_text>METAR KORD 011955Z 22010KT 10SM FEW250 20/10 A3000</raw_text>
            <station_id>KORD</station_id>
            <observation_time>2024-01-01T19:55:00Z</observation_time>
            <wind_dir_degrees>220</wind_dir_degrees>
            <wind_speed_kt>10</wind_speed_kt>
            <visibility_statute_mi>10</visibility_statute_mi>
            <sky_condition sky_cover="FEW" cloud_base_ft_agl="25000"/>
            <temp_c>20.0</temp_c>
            <dewpoint_c>10.0</dewpoint_c>
            <altim_in_hg>30.00</altim_in_hg>
          </METAR>
          </data></response>
          """

        var metars = [METAR]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          metars.append(try result.get())
        }

        expect(metars[0].text).to(equal("METAR KORD 011955Z 22010KT 10SM FEW250 20/10 A3000"))
      }

      it("parses OVX with vertical visibility from sky_condition") {
        let xml = """
          <response><data>
          <METAR>
            <station_id>KSFO</station_id>
            <observation_time>2024-01-01T12:00:00Z</observation_time>
            <wind_dir_degrees>0</wind_dir_degrees>
            <wind_speed_kt>0</wind_speed_kt>
            <visibility_statute_mi>0.25</visibility_statute_mi>
            <sky_condition sky_cover="OVX"/>
            <vert_vis_ft>100</vert_vis_ft>
            <temp_c>10.0</temp_c>
            <dewpoint_c>10.0</dewpoint_c>
            <altim_in_hg>30.00</altim_in_hg>
          </METAR>
          </data></response>
          """

        var metars = [METAR]()
        for await result in METAR.from(xml: xml.data(using: .utf8)!) {
          metars.append(try result.get())
        }

        expect(metars[0].conditions).to(equal([.indefinite(100)]))
      }
    }
  }
}
