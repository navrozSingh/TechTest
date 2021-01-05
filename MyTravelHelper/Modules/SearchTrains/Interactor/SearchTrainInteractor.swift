//
//  SearchTrainInteractor.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation
import XMLParsing
//import Alamofire

class SearchTrainInteractor: PresenterToInteractorProtocol {
    var _sourceStationCode = String()
    var _destinationStationCode = String()
    var presenter: InteractorToPresenterProtocol?

    func fetchallStations() {
        URLSession.shared.perform(Station.request(),
                                  decode: Stations.self) { (result) in
            switch result {
            case .failure(let error):
                let error = error as NSError
                switch error.code {
                case -1009:
                    self.presenter?.showErrorMessage(for: .noInternet)
                    break
                    //TODO: No Station found
                default: break
                }
            case .success(let station):
                self.presenter?.stationListFetched(list: station.stationsList)
            }
        }
    }
    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        guard validSourceAndDestination(sourceCode,destinationCode)
        else {
            self.presenter?.showErrorMessage(for: .InvalidSourceAndDestination)
            return
        }
        _sourceStationCode = sourceCode
        _destinationStationCode = destinationCode
        URLSession.shared.perform(StationData.request(for: sourceCode),
                                  decode: StationData.self) { (result) in
            switch result {
            case .failure(let error):
                let error = error as NSError
                switch error.code {
                case -1009:
                    self.presenter?.showErrorMessage(for: .noInternet)
                    break
                case 400...404:
                    self.presenter?.showErrorMessage(for: .NoTrainsFound)
                    break
                default: break
                }
            case .success(let stationData):
                if stationData.trainsList.count > 0 {
                    self.proceesTrainListforDestinationCheck(trainsList: stationData.trainsList)
                } else {
                    self.presenter?.showErrorMessage(for: .NoTrainsFound)
                }
            }
        }
    }
    private func proceesTrainListforDestinationCheck(trainsList: [StationTrain]) {
        var _trainsList = trainsList
        DispatchQueue.global(qos: .background).async {
            let group = DispatchGroup()
            for index  in 0...trainsList.count-1 {
                guard let code = trainsList[index].trainCode else {
                    continue
                }
                group.enter()
                let request = TrainMovementsData.request(for: code, date: self.trainDate())
                URLSession.shared.perform(request,
                                          decode: TrainMovementsData.self) { (result) in
                    switch result {
                    case .failure(let error):
                        let error = error as NSError
                        switch error.code {
                        case -1009:
                            self.presenter?.showErrorMessage(for: .noInternet)
                            break
                        default: break
                        }
                    case .success(let trainMovements):
                        if let firstStationMoment = self.destinationTrains(for: trainMovements)  {
                            _trainsList[index].destinationDetails = firstStationMoment
                        }
                    }
                    group.leave()
                }
                group.wait()
            }
            group.notify(queue: DispatchQueue.main) {
                let sourceToDestinationTrains = _trainsList.filter{$0.destinationDetails != nil}
                self.presenter?.fetchedTrainsList(trainsList: sourceToDestinationTrains)
                if sourceToDestinationTrains.count == 0 {
                    self.presenter?.showErrorMessage(for: .NoTrainAvailbilityFromSource)
                }
            }
        }
    }
    //MARK: Favourite Logic
    func saveStationToFav(_ station: StationTrain) {
        StationTrain.saveStationAsFavourite(station)
    }
    func getFavouriteStation() -> StationTrain? {
        return StationTrain.getFavouriteStation()
    }
}
//MARK: Validation & Destination Logic
extension SearchTrainInteractor {
    private func destinationTrains(for trainMovements: TrainMovementsData) -> TrainMovement? {
        let _movements = trainMovements.trainMovements
        let sourceIndex = _movements.firstIndex(where: {$0.locationCode?.caseInsensitiveCompare(self._sourceStationCode) == .orderedSame})
        let destinationIndex = _movements.firstIndex(where: {$0.locationCode?.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame})
        let desiredStationMoment = _movements.filter{$0.locationCode?.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame}
        let isDestinationAvailable = desiredStationMoment.count == 1

        if isDestinationAvailable  && sourceIndex! < destinationIndex! {
            return desiredStationMoment.first
        }
        return nil
    }
    private func trainDate() -> String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: today)
        return dateString
    }
    private func validSourceAndDestination(_ sourceCode: String, _ destinationCode: String) -> Bool {
        guard sourceCode != destinationCode,
              !sourceCode.isEmpty,
              !destinationCode.isEmpty else {
            return false
        }
        return true
    }
}
