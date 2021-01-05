//
//  TrainMovements.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation

struct TrainMovementsData: Codable {
    var trainMovements: [TrainMovement]

    enum CodingKeys: String, CodingKey {
        case trainMovements = "objTrainMovements"
    }
}

struct TrainMovement: Codable {
    let trainCode: String?
    let locationCode: String?
    let locationFullName: String?
    let expDeparture:String?

    enum CodingKeys: String, CodingKey {
        case trainCode = "TrainCode"
        case locationCode = "LocationCode"
        case locationFullName = "LocationFullName"
        case expDeparture = "ExpectedDeparture"
    }
    init(trainCode: String, locationCode: String, locationFullName: String,expDeparture:String) {
        self.trainCode = trainCode
        self.locationCode = locationCode
        self.locationFullName = locationFullName
        self.expDeparture = expDeparture
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let trainCode = try values.decode(String.self, forKey: .trainCode)
        let locationCode = try values.decode(String.self, forKey: .locationCode)
        let locationFullName = try values.decode(String.self, forKey: .locationFullName)
        let expDeparture = try values.decode(String.self, forKey: .expDeparture)
        self.init(trainCode: trainCode,
                  locationCode: locationCode,
                  locationFullName: locationFullName,
                  expDeparture: expDeparture)
    }
}
extension TrainMovementsData {
    static func request(for code: String, date trainDate: String) -> URLRequest {
        var getTrainMovementsXML = URL.baseUrl
        getTrainMovementsXML.addPath("/realtime/realtime.asmx/getTrainMovementsXML")
        getTrainMovementsXML.appendQueryItem("TrainId", value: code)
        getTrainMovementsXML.appendQueryItem("TrainDate", value: trainDate)
        return URLRequest(url: getTrainMovementsXML)
    }
}

