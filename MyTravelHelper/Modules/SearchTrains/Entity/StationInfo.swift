//
//  StationInfo.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation

struct StationData: Codable {
    var trainsList: [StationTrain]

    enum CodingKeys: String, CodingKey {
        case trainsList = "objStationData"
    }
}

struct StationTrain: Codable {
   let trainCode: String?
   let stationFullName: String?
   let stationCode: String?
   let trainDate: String?
   let dueIn: Int?
   let lateBy:Int?
   let expArrival:String?
   let expDeparture:String?
   var destinationDetails:TrainMovement?

    enum CodingKeys: String, CodingKey {
        case trainCode = "Traincode"
        case stationFullName = "Stationfullname"
        case stationCode = "Stationcode"
        case trainDate = "Traindate"
        case dueIn = "Duein"
        case lateBy = "Late"
        case expArrival = "Exparrival"
        case expDeparture = "Expdepart"
        case destinationDetails = "destinationDetails"
    }
    init(trainCode: String,
         fullName: String,
         stationCode: String,
         trainDate: String,
         dueIn: Int,
         lateBy:Int,
         expArrival:String,
         expDeparture:String,
         destinationDetails: TrainMovement?) {
        self.trainCode = trainCode
        self.stationFullName = fullName
        self.stationCode = stationCode
        self.trainDate = trainDate
        self.dueIn = dueIn
        self.lateBy = lateBy
        self.expArrival = expArrival
        self.expDeparture = expDeparture
        self.destinationDetails = destinationDetails
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let trainCode = try values.decode(String.self, forKey: .trainCode)
        let stationFullName = try values.decode(String.self, forKey: .stationFullName)
        let stationCode = try values.decode(String.self, forKey: .stationCode)
        let trainDate = try values.decode(String.self, forKey: .trainDate)
        let dueIn = try values.decode(Int.self, forKey: .dueIn)
        let lateBy = try values.decode(Int.self, forKey: .lateBy)
        let expArrival = try values.decode(String.self, forKey: .expArrival)
        let expDeparture = try values.decode(String.self, forKey: .expDeparture)
        let destinationDetails = try? values.decode(TrainMovement.self, forKey: .destinationDetails)

        self.init(trainCode: trainCode,
                  fullName: stationFullName,
                  stationCode: stationCode,
                  trainDate: trainDate,
                  dueIn: dueIn,
                  lateBy: lateBy,
                  expArrival: expArrival,
                  expDeparture: expDeparture, destinationDetails: destinationDetails)
    }
}
extension StationData {
    static func request(for sourceCode: String) -> URLRequest {
        var getStationDataByCodeXML = URL.baseUrl
        getStationDataByCodeXML.addPath("/realtime/realtime.asmx/getStationDataByCodeXML")
        getStationDataByCodeXML.appendQueryItem("StationCode", value: sourceCode)
        return URLRequest(url: getStationDataByCodeXML)
    }
}
//MARK: Saving logic
extension StationTrain {
    static func saveStationAsFavourite(_ station: StationTrain) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(station), forKey:"FavStationTrain")
    }
    static func getFavouriteStation() -> StationTrain? {
        if let data = UserDefaults.standard.value(forKey:"FavStationTrain") as? Data {
            let station = try? PropertyListDecoder().decode(StationTrain.self, from: data)
            return station
        }
        return nil
    }
}
