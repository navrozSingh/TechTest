//
//  Client.swift
//  MyTravelHelper
//
//  Created by Navroz Singh on 08/01/21.
//  Copyright © 2021 Sample. All rights reserved.
//

import UIKit
protocol Client {
    func fetchallStations(resultHandler: @escaping (Result<Stations, ErrorMessages>) -> Void)
    func fetchTrainsFromSource(_ sourceRequest: URLRequest,
                               resultHandler: @escaping (Result<[StationTrain], ErrorMessages>) -> Void)
    func proceesTrainListforDestinationCheck(_ sourceRequest: URLRequest,
                                             resultHandler: @escaping (Result<TrainMovementsData, ErrorMessages>) -> Void) 
}
class TrainClient: Client {
    func fetchallStations(resultHandler: @escaping (Result<Stations, ErrorMessages>) -> Void) {

        URLSession.shared.perform(Station.request(),
                                  decode: Stations.self) { (result) in
            switch result {
            case .success(let stations):
                resultHandler(.success(stations))
            case .failure(_):
                //MARK: Fix me Cover all Cases
                resultHandler(.failure(.noInternet))
            }
        }
    }
    func fetchTrainsFromSource(_ sourceRequest: URLRequest,
                               resultHandler: @escaping (Result<[StationTrain], ErrorMessages>) -> Void) {
        URLSession.shared.perform(sourceRequest, decode: StationData.self) { (result) in
            switch result {
            case .failure(let error):
                let error = error as NSError
                switch error.code {
                case -1009:
                    resultHandler(.failure(.noInternet))
                    break
                case 400...404:
                    resultHandler(.failure(.NoTrainsFound))
                    break
                default: break
                }
            case .success(let stationData):
                if stationData.trainsList.count > 0 {
                    resultHandler(.success(stationData.trainsList))
                } else {
                    resultHandler(.failure(.NoTrainsFound))
                }
            }
        }
    }
    func proceesTrainListforDestinationCheck(_ sourceRequest: URLRequest,
                                             resultHandler: @escaping (Result<TrainMovementsData, ErrorMessages>) -> Void) {
        URLSession.shared.perform(sourceRequest,
                                  decode: TrainMovementsData.self) { (result) in
            switch result {
            //MARK: Fix me Cover all Cases
            case .failure(_):
                resultHandler(.failure(.noInternet))
                break
            case .success(let trainMovements):
                resultHandler(.success(trainMovements))
            }
        }
    }
}
