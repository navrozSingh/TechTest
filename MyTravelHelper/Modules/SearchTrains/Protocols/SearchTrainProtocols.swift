//
//  SearchTrainProtocols.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit

enum ErrorMessages: Error {
    case noInternet
    case NoTrainsFound
    case NoTrainAvailbilityFromSource
    case InvalidSourceAndDestination
}

protocol ViewToPresenterProtocol: class{
    var view: PresenterToViewProtocol? {get set}
    var interactor: PresenterToInteractorProtocol? {get set}
    var router: PresenterToRouterProtocol? {get set}
    func fetchallStations()
    func searchTapped(source:String,destination:String)
    func saveStationToFav(_ station: StationTrain)
    func getFavouriteStation()->StationTrain?
}

protocol PresenterToViewProtocol: class{
    func saveFetchedStations(stations:[Station]?)
    func updateLatestTrainList(trainsList: [StationTrain])
    func showErrorMessage(for Error: ErrorMessages)
}

protocol PresenterToRouterProtocol: class {
    static func createModule()-> SearchTrainViewController
}

protocol PresenterToInteractorProtocol: class {
    var presenter:InteractorToPresenterProtocol? {get set}
    var networkClient: Client?{get set}
    func fetchallStations()
    func fetchTrainsFromSource(sourceCode:String,destinationCode:String)
    func saveStationToFav(_ station: StationTrain)
    func getFavouriteStation()->StationTrain?
}

protocol InteractorToPresenterProtocol: class {
    func stationListFetched(list:[Station])
    func fetchedTrainsList(trainsList:[StationTrain]?)
    func showErrorMessage(for Error: ErrorMessages)
    func getFavouriteStation()->StationTrain?
}
