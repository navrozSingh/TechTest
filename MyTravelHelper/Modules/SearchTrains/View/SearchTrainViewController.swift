//
//  SearchTrainViewController.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit
import SwiftSpinner
import DropDown

class SearchTrainViewController: UIViewController {
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var sourceTxtField: UITextField!
    @IBOutlet weak var trainsListTable: UITableView!

    var stationsList:[Station] = [Station]()
    var trains:[StationTrain] = [StationTrain]()
    var presenter:ViewToPresenterProtocol?
    var dropDown = DropDown()
    var transitPoints:(source:String,destination:String) = ("","")
    var favStations: StationTrain?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trainsListTable.isHidden = true
        setupFavButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        if stationsList.count == 0 {
            SwiftSpinner.useContainerView(view)
            SwiftSpinner.show("Please wait loading station list ....")
            presenter?.fetchallStations()
        }
    }
    @IBAction func searchTrainsTapped(_ sender: Any) {
        view.endEditing(true)
        showProgressIndicator(view: self.view)
        presenter?.searchTapped(source: transitPoints.source,
                                destination: transitPoints.destination)
    }
}
extension SearchTrainViewController {
    private func setupFavButton() {
        navigationItem.rightBarButtonItem = nil
        guard let favStations = presenter?.getFavouriteStation() else {
            return
        }
        self.favStations = favStations
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favourite Stations",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(setFavStations))
    }
    @objc func setFavStations() {
        transitPoints.source = favStations?.stationFullName ?? ""
        transitPoints.destination = favStations?.destinationDetails?.locationFullName ?? ""
        self.sourceTxtField.text = transitPoints.source
        self.destinationTextField.text = transitPoints.destination
    }
}

extension SearchTrainViewController:PresenterToViewProtocol {
    func showErrorMessage(for Error: ErrorMessages) {
        DispatchQueue.main.async {
            switch Error {
            case .noInternet:
                self.showNoInterNetAvailabilityMessage()
                break
            case .NoTrainsFound:
                self.showNoTrainsFoundAlert()
                break
            case .NoTrainAvailbilityFromSource:
                self.showNoTrainAvailbilityFromSource()
                break
            case .InvalidSourceAndDestination:
                self.showInvalidSourceOrDestinationAlert()
                break
            }
        }
    }
    
    func showNoInterNetAvailabilityMessage() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "No Internet", message: "Please Check you internet connection and try again", actionTitle: "Okay")
    }
    func showInvalidSourceAndDestination() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "Invalid Source/destination", message: "Please select valid Source and destination", actionTitle: "Okay")
    }
    func showNoTrainAvailbilityFromSource() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "No Trains", message: "Sorry No trains arriving source station in another 90 mins", actionTitle: "Okay")
    }

    func updateLatestTrainList(trainsList: [StationTrain]) {
        DispatchQueue.main.async {
            hideProgressIndicator(view: self.view)
            self.trains = trainsList
            self.trainsListTable.isHidden = false
            self.trainsListTable.reloadData()
        }
    }

    func showNoTrainsFoundAlert() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        trainsListTable.isHidden = true
        showAlert(title: "No Trains", message: "Sorry No trains Found from source to destination in another 90 mins", actionTitle: "Okay")
    }

    func showAlert(title:String,message:String,actionTitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func showInvalidSourceOrDestinationAlert() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "Invalid Source/Destination", message: "Invalid Source or Destination Station names Please Check", actionTitle: "Okay")
    }

    func saveFetchedStations(stations: [Station]?) {
        DispatchQueue.main.async {
            if let _stations = stations {
              self.stationsList = _stations
            }
            SwiftSpinner.hide()
        }
    }
}

extension SearchTrainViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dropDown = DropDown()
        dropDown.anchorView = textField
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.dataSource = stationsList.compactMap{$0.stationDesc}
        dropDown.selectionAction = { (index: Int, item: String) in
            if textField == self.sourceTxtField {
                self.transitPoints.source = item
            }else {
                self.transitPoints.destination = item
            }
            textField.text = item
        }
        dropDown.show()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dropDown.hide()
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let inputedText = textField.text {
            var desiredSearchText = inputedText
            if string != "\n" && !string.isEmpty{
                desiredSearchText = desiredSearchText + string
            }else {
                desiredSearchText = String(desiredSearchText.dropLast())
            }

            //dropDown.dataSource = stationsList
            dropDown.show()
            dropDown.reloadAllComponents()
        }
        return true
    }
}

extension SearchTrainViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trains.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "train",
                                                       for: indexPath) as? TrainInfoCell
        else {
            fatalError("cell misconfiguration")
        }
        cell.train = trains[indexPath.row]
        cell.favStationTrain = { station in
            self.presenter?.saveStationToFav(station)
            self.setupFavButton()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}


