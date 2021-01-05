//
//  Stations.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation

struct Stations: Codable {
    var stationsList: [Station]

    enum CodingKeys: String, CodingKey {
        case stationsList = "objStation"
    }
}

struct Station: Codable {
    let stationDesc: String?
    let stationLatitude: Double?
    let stationLongitude: Double?
    let stationCode: String?
    let stationId: Int?

    enum CodingKeys: String, CodingKey {
        case stationDesc = "StationDesc"
        case stationLatitude = "StationLatitude"
        case stationLongitude = "StationLongitude"
        case stationCode = "StationCode"
        case stationId = "StationId"
    }
    init(desc: String, latitude: Double, longitude: Double, code: String, stationId: Int) {
        self.stationDesc = desc
        self.stationLatitude = latitude
        self.stationLongitude = longitude
        self.stationCode = code
        self.stationId = stationId
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let stationDesc = try values.decode(String.self, forKey: .stationDesc)
        let stationLatitude = try values.decode(Double.self, forKey: .stationLatitude)
        let stationLongitude = try values.decode(Double.self, forKey: .stationLongitude)
        let stationCode = try values.decode(String.self, forKey: .stationCode)
        let stationId = try values.decode(Int.self, forKey: .stationId)
        self.init(desc: stationDesc, latitude: stationLatitude, longitude: stationLongitude, code: stationCode, stationId: stationId)

    }
}
extension Station {
    static func request() -> URLRequest {
        var allStation = URL.baseUrl
        allStation.addPath("/realtime/realtime.asmx/getAllStationsXML")
        return URLRequest(url: allStation)
    }
}
