//
//  SearchTrainRouter.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit
class SearchTrainRouter: PresenterToRouterProtocol {
    static func createModule() -> SearchTrainViewController {
        let view = UIStoryboard.mainstoryboard.instantiateViewController(withIdentifier: "searchTrain") as! SearchTrainViewController
        let presenter: ViewToPresenterProtocol & InteractorToPresenterProtocol = SearchTrainPresenter()
        let interactor: PresenterToInteractorProtocol = SearchTrainInteractor()
        let router:PresenterToRouterProtocol = SearchTrainRouter()
        let networkClient: Client = TrainClient()
        
        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        interactor.networkClient = networkClient

        return view
    }

    
}
