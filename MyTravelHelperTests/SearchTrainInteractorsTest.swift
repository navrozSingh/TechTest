//
//  SearchTrainInteractorsTest.swift
//  MyTravelHelperTests
//
//  Created by Navroz on 10/01/21.
//  Copyright © 2021 Sample. All rights reserved.
//

import XCTest
@testable import MyTravelHelper
class InteractorTest: XCTestCase {
    var view: ViewToPresenterProtocol?
    var Interactor: PresenterToInteractorProtocol?
    var presenter = MockPresenter()
    var network = MockNetwork()
    override func setUp() {
        Interactor = SearchTrainInteractor()
        Interactor?.networkClient = network
        Interactor?.presenter = presenter
    }
    func testFetchallStationsFailure() {
        presenter.currentError = .NoTrainsFound
        network.currentError = .NoTrainsFound
        Interactor?.fetchallStations()
    }
    func testFetchallStationsSuccess() {
        presenter.currentError = nil
        network.currentError = nil
        Interactor?.fetchallStations()
    }
    func testEmptyFetchTrainList() {
        presenter.currentError = .InvalidSourceAndDestination
        Interactor?.fetchTrainsFromSource(sourceCode: "", destinationCode: "")
    }
    func testFetchTrainList() {
        let unlockExpectation = expectation(description: "delegate is called twice")
        presenter.expectation = unlockExpectation
        Interactor?.fetchTrainsFromSource(sourceCode: "Dublin Belfast", destinationCode: "DUNMR")
        wait(for: [unlockExpectation], timeout: 60)
    }
    
    func testFavourite() {
        let station = Responses.TrainList()[0]
        Interactor?.saveStationToFav(station)
        let favStation = presenter.getFavouriteStation()
        XCTAssertEqual(station.trainCode, favStation?.trainCode)
    }


}
class MockPresenter: InteractorToPresenterProtocol {
    var expectation: XCTestExpectation?
    
    var currentError: ErrorMessages?
    func stationListFetched(list: [Station]) {
        let staticList =  Responses.AllStation().stationsList
        XCTAssertEqual(staticList.count, list.count)
    }
    
    func fetchedTrainsList(trainsList: [StationTrain]?) {
        XCTAssertEqual(trainsList!.count, 1)
        expectation?.fulfill()
    }
    
    func showErrorMessage(for Error: ErrorMessages) {
        XCTAssertEqual(currentError, Error)
    }
    
    func getFavouriteStation() -> StationTrain? {
        StationTrain.getFavouriteStation()
    }
}
class MockNetwork: Client {
    var currentError: ErrorMessages?
    func fetchallStations(resultHandler: @escaping (Result<Stations, ErrorMessages>) -> Void) {
        if let currentError = currentError {
            resultHandler(.failure(currentError))
        } else {
            resultHandler(.success(Responses.AllStation()))
        }
    }
    
    func fetchTrainsFromSource(_ sourceRequest: URLRequest, resultHandler: @escaping (Result<[StationTrain], ErrorMessages>) -> Void) {
        if let currentError = currentError {
            resultHandler(.failure(currentError))
        } else {
            resultHandler(.success(Responses.TrainList()))
        }
    }
    func proceesTrainListforDestinationCheck(_ sourceRequest: URLRequest,
                                             resultHandler: @escaping (Result<TrainMovementsData, ErrorMessages>) -> Void) {
        if let currentError = currentError {
            resultHandler(.failure(currentError))
        } else {
            resultHandler(.success(Responses.TrainMovements()))
        }
    }
}

