import Foundation
import SwiftMETAR

let METAR_URL = URL(string: "https://www.aviationweather.gov/adds/dataserver_current/current/metars.cache.csv")!
let METARs = String(data: try! Data(contentsOf: METAR_URL), encoding: .ascii)!
METARs.enumerateLines { line, stop in
    guard let range  = line.rangeOfCharacter(from: CharacterSet(charactersIn: ",")) else { return }
    let string = String(line[line.startIndex..<range.lowerBound])
//    guard string != "raw_text" else { return }
    guard string.starts(with: "K") else { return }
    
    do {
        _ = try METAR.from(string: string)
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
        _ = try TAF.from(string: string)
    } catch let error as SwiftMETAR.Error {
        print(string)
        print(" -- \(error.description)")
    } catch let error {
        fatalError(error.localizedDescription)
    }
}
