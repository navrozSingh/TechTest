//
//  SearchTrainPresenterTests.swift
//  MyTravelHelperTests
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import XCTest
@testable import MyTravelHelper

class SearchTrainPresenterTests: XCTestCase {
    var presenter: SearchTrainPresenter!
    var view = SearchTrainMockView()
    var interactor = SearchTrainInteractorMock()
    
    override func setUp() {
      presenter = SearchTrainPresenter()
        presenter.view = view
        presenter.interactor = interactor
        interactor.presenter = presenter
    }

    func testfetchallStations() {
        presenter.fetchallStations()
        if !view.isSaveFetchedStatinsCalled {
            XCTFail("saveFetchedStations func not called")
        }
    }
    func testErrorMessages() {
        let error: ErrorMessages = .noInternet
        presenter.showErrorMessage(for: error)
        XCTAssertEqual(view.error, error)
    }
    func testTrainList() {
        let sourceName = "dubin"
        let destinationName = "foundhound"

        interactor.fetchTrainsFromSource(sourceCode: sourceName, destinationCode: destinationName)
        guard view.trainsList?.count == 1,
              let stationFullName = view.trainsList?[0].stationFullName ,
              let locationFullName = view.trainsList?[0].destinationDetails?.locationFullName else {
            XCTFail("invalid station")
            return
        }
        XCTAssertEqual(stationFullName, sourceName)
        XCTAssertEqual(locationFullName, destinationName)
    }
    
    func testFav() {
        let stationTrain: StationTrain = StationTrain.init(trainCode: "A123", fullName: "sourceStation", stationCode: "456", trainDate: "5/01/2021", dueIn: 2, lateBy: 3, expArrival: "16:00", expDeparture: "18:00", destinationDetails: TrainMovement.init(trainCode: "A345", locationCode: "798", locationFullName: "destinationStation", expDeparture: "20:00"))
        presenter.saveStationToFav(stationTrain)
        let favStation = presenter.getFavouriteStation()
        XCTAssertEqual(stationTrain.stationFullName, favStation?.stationFullName)
        XCTAssertEqual(stationTrain.stationCode, favStation?.stationCode)
        XCTAssertEqual(stationTrain.expArrival, favStation?.expArrival)
        XCTAssertEqual(stationTrain.destinationDetails?.locationFullName, favStation?.destinationDetails?.locationFullName)
    }

    override func tearDown() {
        presenter = nil
    }
}


class SearchTrainMockView:PresenterToViewProtocol {
    var error: ErrorMessages?
    func showErrorMessage(for Error: ErrorMessages) {
        error = Error
    }
    var isSaveFetchedStatinsCalled = false
    func saveFetchedStations(stations: [Station]?) {
        isSaveFetchedStatinsCalled = true
    }
    var trainsList:[StationTrain]?
    func updateLatestTrainList(trainsList: [StationTrain]) {
        self.trainsList = trainsList
    }
}

class SearchTrainInteractorMock:PresenterToInteractorProtocol {
    
    var presenter: InteractorToPresenterProtocol?

    func fetchallStations() {
        let station = Station(desc: "Belfast Central",
                              latitude: 54.6123,
                              longitude: -5.91744,
                              code: "BFSTC",
                              stationId: 228)
        presenter?.stationListFetched(list: [station])
    }

    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        let stationTrain: StationTrain = StationTrain.init(trainCode: "A123", fullName: sourceCode, stationCode: "456", trainDate: "5/01/2021", dueIn: 2, lateBy: 3, expArrival: "16:00", expDeparture: "18:00", destinationDetails: TrainMovement.init(trainCode: "A345", locationCode: "798", locationFullName: destinationCode, expDeparture: "20:00"))

        presenter?.fetchedTrainsList(trainsList: [stationTrain])
    }
    var favStation: StationTrain?
    func saveStationToFav(_ station: StationTrain) {
        self.favStation = station
    }
    func getFavouriteStation() -> StationTrain? {
        return favStation
    }
}
