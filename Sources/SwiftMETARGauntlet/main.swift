import Foundation
import SwiftMETAR

fileprivate func checkRemarks(_ remarks: Array<RemarkEntry>, string: String) {
    for remark in remarks {
        if case let .unknown(remarkStr) = remark.remark {
            print(string)
            print("-- Unknown remark: \(remarkStr)")
        }
    }
}

let METAR_URL = URL(string: "https://www.aviationweather.gov/adds/dataserver_current/current/metars.cache.csv")!
let METARs = String(data: try! Data(contentsOf: METAR_URL), encoding: .ascii)!
METARs.enumerateLines { line, stop in
    guard let range  = line.rangeOfCharacter(from: CharacterSet(charactersIn: ",")) else { return }
    let string = String(line[line.startIndex..<range.lowerBound])
//    guard string != "raw_text" else { return }
    guard string.starts(with: "K") else { return }
    
    do {
        let metar = try METAR.from(string: string)
        checkRemarks(metar.remarks, string: string)
    } catch (let error) {
        print(string)
        print(" -- \(error.localizedDescription)")
    }
}

let TAF_URL = URL(string: "https://www.aviationweather.gov/adds/dataserver_current/current/tafs.cache.csv")!
let TAFs = String(data: try! Data(contentsOf: TAF_URL), encoding: .ascii)!
TAFs.enumerateLines { line, stop in
    guard let range  = line.rangeOfCharacter(from: CharacterSet(charactersIn: ",")) else { return }
    let string = String(line[line.startIndex..<range.lowerBound])
//    guard string != "raw_text" else { return }
    guard string.starts(with: "TAF K") else { return }
    
    do {
        let taf = try TAF.from(string: string, lenientRemarks: true)
        checkRemarks(taf.remarks, string: string)
    } catch let error {
        print(string)
        print(" -- \(error.localizedDescription)")
//        fatalError(error.localizedDescription)
    }
}
