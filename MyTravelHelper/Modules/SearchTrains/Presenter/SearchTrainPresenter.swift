//
//  SearchTrainPresenter.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit

class SearchTrainPresenter:ViewToPresenterProtocol {
    private var stationsList:[Station] = [Station]()
    var interactor: PresenterToInteractorProtocol?
    var router: PresenterToRouterProtocol?
    var view:PresenterToViewProtocol?

    func searchTapped(source: String, destination: String) {
        let sourceStationCode = getStationCode(stationName: source)
        let destinationStationCode = getStationCode(stationName: destination)
        interactor?.fetchTrainsFromSource(sourceCode: sourceStationCode,
                                          destinationCode: destinationStationCode)
    }
    func fetchallStations() {
        interactor?.fetchallStations()
    }
    func getFavouriteStation() -> StationTrain? {
        interactor?.getFavouriteStation()
    }
    func saveStationToFav(_ station: StationTrain) {
        interactor?.saveStationToFav(station)
    }
    private func getStationCode(stationName:String)->String {
        let stationCode = stationsList.filter{$0.stationDesc == stationName}.first
        return stationCode?.stationCode?.lowercased() ?? ""
    }
}

extension SearchTrainPresenter: InteractorToPresenterProtocol {
    func showErrorMessage(for Error: ErrorMessages) {
        self.view?.showErrorMessage(for: Error)
    }
    func fetchedTrainsList(trainsList: [StationTrain]?) {
        if let _trainsList = trainsList {
            self.view?.updateLatestTrainList(trainsList: _trainsList)
        }
        //TODO: Check if this required
        /*
         else {
            self.view?.showNoTrainsFoundAlert()
        }*/
    }
    func stationListFetched(list: [Station]) {
        self.stationsList = list
        self.view?.saveFetchedStations(stations: list)
    }
}
