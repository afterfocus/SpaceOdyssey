//
//  LocationInfoController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 10.02.2021.
//

import UIKit
import YandexMapsMobile

// MARK: - LocationInfoContainerController

class LocationInfoContainerController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var height: NSLayoutConstraint!
    
    // MARK: - Segue Properties
    
    var questionIndex: Int!
    var question: Question!
    
    // MARK: - View Life Cycle
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InfoEmbedSegue" {
            let infoController = segue.destination as? LocationInfoController
            infoController?.height = height
            infoController?.questionIndex = questionIndex
            infoController?.question = question
        }
    }
}


// MARK: - LocationInfoController

class LocationInfoController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var mapView: YMKMapView!
    
    @IBOutlet weak var photoImageViewHeight: NSLayoutConstraint!
    
    // MARK: - Segue Properties
    
    var questionIndex: Int!
    var question: Question!
    weak var height: NSLayoutConstraint!
    
    // MARK: - Private Properties
    
    private var map: YMKMap {
        return mapView.mapWindow.map
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 3
        view.layer.borderColor = .lightAccent
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let location = question.location
        addressLabel.text = location.address
        locationNameLabel.text = location.name
        photoImageView.image = UIImage(named: location.photoFilename)!
        
        let point = YMKPoint(latitude: location.latitude, longitude: location.longtitude)
        let placemarkView = MapPlacemarkView(index: questionIndex, isComplete: question.isComplete, isLocked: false)
        map.isNightModeEnabled = DataModel.current.isMapNightModeEnabled
        map.mapObjects.addPlacemark(with: point, view: YRTViewProvider(uiView: placemarkView))
        map.move(with: YMKCameraPosition(target: point, zoom: 14, azimuth: 0, tilt: 0))
    }
    
    override func viewDidLayoutSubviews() {
        let ratio = photoImageView.image!.size.height / photoImageView.image!.size.width
        photoImageViewHeight.constant = photoImageView.bounds.width * ratio
        height.constant = 170 + photoImageViewHeight.constant + addressLabel.bounds.height + mapView.bounds.height + locationNameLabel.bounds.height
    }
    
    // MARK: - IBActions
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

