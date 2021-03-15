//
//  MapController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 11.01.2021.
//

import UIKit
import YandexMapsMobile
import CoreLocation

// MARK: MapController

final class MapController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var topGradientView: TopGradientView!
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceUnitLabel: UILabel!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var enableTrackingButton: UIButton!
    @IBOutlet weak var orientToNorthButton: UIButton!
    
    // MARK: - Segue Properties
    
    var route: Route = DataModel.routes[0]
    var routeVariation: RouteVariation = DataModel.routes[0].variations[2]
    
    // MARK: - Private Properties
    
    private var locationManager = CLLocationManager()
    private var nextQuestion: Question?
    
    private var firstIncompleteIndex: Int? {
        didSet {
            nextQuestion = firstIncompleteIndex == nil ? nil : route[routeVariation[firstIncompleteIndex!]]
        }
    }
    
    private var isTrackingEnabled = true {
        didSet {
            enableTrackingButton.isEnabled = !isTrackingEnabled
            enableTrackingButton.backgroundColor = backgroundColorForButton(isEnabled: !isTrackingEnabled)
        }
    }
    private var isNorthOriented = true {
        didSet {
            orientToNorthButton.isEnabled = !isNorthOriented
            orientToNorthButton.backgroundColor = backgroundColorForButton(isEnabled: !isNorthOriented)
        }
    }
    private var routeEndPoint: YMKPoint?
    private var nextQuestionPlacemark: YMKMapObject?
    private var isRoutingDisabled: Bool!
    private var isLocationAuthDeniedAlertShown = false
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topGradientView.color = UIColor.black.withAlphaComponent(0.35)
        topGradientView.startLocation = 0
        
        mapView.initialize()
        mapView.delegate = self
        mapView.isNightModeEnabled = DataModel.current.isMapNightModeEnabled
        mapView.moveCamera(target: YMKPoint(latitude: 53.2001, longitude: 50.15),
                           zoom: 11, azimuth: 0, tilt: 0, duration: 0)
        
        [questionLabel, distanceLabel, distanceUnitLabel].forEach {
            $0?.layer.dropShadow(opacity: 0.7, radius: 7)
        }
        
        let tintColor: UIColor = mapView.isNightModeEnabled ? .white : .black
        [zoomInButton, zoomOutButton, enableTrackingButton, orientToNorthButton].forEach {
            $0?.layer.dropShadow(opacity: 0.35, radius: 7)
            $0?.tintColor = tintColor
        }
        zoomInButton.backgroundColor = backgroundColorForButton(isEnabled: true)
        zoomOutButton.backgroundColor = backgroundColorForButton(isEnabled: true)
        enableTrackingButton.backgroundColor = backgroundColorForButton(isEnabled: false)
        orientToNorthButton.backgroundColor = backgroundColorForButton(isEnabled: false)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        
        firstIncompleteIndex = route.firstIncompleteIndex(for: routeVariation)
        addQuestionPlacemarks()
        
        if let index = firstIncompleteIndex {
            questionLabel.text = "\(index + 1). \(nextQuestion!.title)"
        } else {
            questionLabel.text = "Маршрут завершен"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3, delay: 0.2, options: []) {
            [weak self] in self?.tabBarController?.tabBar.alpha = 0
        }
        isRoutingDisabled = DataModel.current.isRoutingDisabled
        distanceLabel.text = ""
        distanceUnitLabel.text = ""
        
        let newIndex = route.firstIncompleteIndex(for: routeVariation)
        if firstIncompleteIndex != newIndex {
            firstIncompleteIndex = newIndex
            if let index = newIndex {
                questionLabel.text = "\(index + 1). \(nextQuestion!.title)"
            } else {
                questionLabel.text = "Маршрут завершен"
            }
            mapView.clearObjects()
            buildRoute()
            addQuestionPlacemarks()
            moveToUserLocation(withAnimationType: .smooth, zoom: 16, duration: 2)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.removeCallout()
        UIView.animate(withDuration: 0.3) {
            [weak self] in self?.tabBarController?.tabBar.alpha = 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLocationTracking(status: CLLocationManager.authorizationStatus())
    }
    
    // MARK: - IBActions
    
    @IBAction func zoomInButtonPressed(_ sender: UIButton) {
        mapView.zoomIn(step: 1.5, duration: 0.5)
    }
    
    @IBAction func zoomOutButtonPressed(_ sender: UIButton) {
        mapView.zoomOut(step: 1.5, duration: 0.5)
    }
    
    @IBAction func enableTrackingButtonPressed(_ sender: UIButton) {
        isTrackingEnabled = true
        moveToUserLocation(withAnimationType: .smooth,
                           zoom: mapView.map.cameraPosition.zoom < 13 ? 13 : nil,
                           duration: 1)
    }
    
    @IBAction func orientToNorthButtonPressed(_ sender: UIButton) {
        isNorthOriented = true
        mapView.turnToNorth(duration: 0.5)
    }
    
    // MARK: - Private Functions
    
    private func backgroundColorForButton(isEnabled: Bool) -> UIColor {
        if mapView.isNightModeEnabled {
            return UIColor.black.withAlphaComponent(isEnabled ? 0.8 : 0.35)
        } else {
            return UIColor.white.withAlphaComponent(isEnabled ? 1 : 0.5)
        }
    }
    
    private func startLocationTracking(status: CLAuthorizationStatus) {
        guard status == .authorizedAlways || status == .authorizedWhenInUse else {
            if !isLocationAuthDeniedAlertShown && !isRoutingDisabled {
                present(UIAlertController.locationAuthorizationDeniedAlert, animated: true)
            }
            isLocationAuthDeniedAlertShown = true
            return
        }
        if isTrackingEnabled {
            moveToUserLocation(withAnimationType: .smooth, zoom: 16, duration: 2)
        }
        if mapView.needsToBuildRoute {
            buildRoute()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    private func moveToUserLocation(withAnimationType type: YMKAnimationType,
                                    zoom: Float? = nil,
                                    duration: Float) {
        guard let coordinates = locationManager.location?.coordinate else { return }
        mapView.moveCamera(target: YMKPoint(coordinate: coordinates),
                           zoom: zoom,
                           animationType: type,
                           duration: duration)
    }
    
    private func addQuestionPlacemarks() {
        for (placemarkIndex, questionIndex) in routeVariation.questionIndexes.enumerated() {
            let question = route[questionIndex]
            addPlacemark(question: question, placemarkIndex: placemarkIndex)
        }
        if let question = nextQuestion {
            mapView.addGeoCircle(location: question.location)
        }
    }
    
    private func addPlacemark(question: Question, placemarkIndex: Int) {
        let isLocked = placemarkIndex > (firstIncompleteIndex ?? 100)
        let placemark = MapPlacemarkView(index: placemarkIndex,
                                         isComplete: question.isComplete,
                                         isLocked: isLocked,
                                         isVisited: question.location.isVisited)
        let ymkPlacemark = mapView.addPlacemark(location: question.location, placemark: placemark)
        ymkPlacemark.userData = PlacemarkData(isCallout: false,
                                              isLocked: isLocked,
                                              question: question,
                                              questionIndex: placemarkIndex)
        ymkPlacemark.zIndex = 0
        if firstIncompleteIndex == placemarkIndex {
            nextQuestionPlacemark = ymkPlacemark
        }
    }
    
    private func showCallout(for placemarkData: PlacemarkData) {
        let callout: MapCalloutView = MapCalloutView.fromNib()
        let question = placemarkData.question
        callout.configure(for: question.location,
                          isComplete: question.isComplete,
                          isLocked: placemarkData.isLocked,
                          isVisited: question.location.isVisited || isRoutingDisabled)
        let calloutMapObject = mapView.show(mapCallout: callout, at: YMKPoint(location: question.location))
        var calloutData = placemarkData
        calloutData.isCallout = true
        if question.isComplete {
            calloutData.isLocked = placemarkData.isLocked
        } else {
            calloutData.isLocked = placemarkData.isLocked || (!question.location.isVisited && !isRoutingDisabled)
        }
        calloutMapObject.userData = calloutData
        calloutMapObject.zIndex = 99
    }
    
    private func buildRoute() {
        guard let coordinates = locationManager.location?.coordinate,
              let question = nextQuestion else { return }
    
        let startPoint = YMKPoint(coordinate: coordinates)
        routeEndPoint = YMKPoint(location: question.location)
        let distance = YMKDistance(startPoint, routeEndPoint)
        
        if distance < 50000 {
            mapView.buildRoute(startPoint: startPoint, endPoint: routeEndPoint!)
        } else {
            mapView.needsToBuildRoute = false
            if !DataModel.current.isRoutingDisabled {
                present(UIAlertController.tooFarFromLocationAlert, animated: true)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension MapController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        startLocationTracking(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if isTrackingEnabled {
            moveToUserLocation(withAnimationType: .linear, duration: 1)
        }
        guard let endPoint = routeEndPoint,
              let coordinates = locationManager.location?.coordinate,
              let location = nextQuestion?.location else { return }
        let distance = YMKDistance(YMKPoint(coordinate: coordinates), endPoint)
        
        if distance > 1000 {
            distanceLabel.text = "\(String(format: "%.1f", distance / 1000))"
            distanceUnitLabel.text = "км"
        } else {
            distanceLabel.text = "\(Int(distance))"
            distanceUnitLabel.text = "м"
        }
        
        if !location.isVisited && distance < location.activationRadius {
            location.isVisited = true
            
            mapView.removeCallout()
            mapView.map.mapObjects.remove(with: nextQuestionPlacemark!)
            addPlacemark(question: nextQuestion!, placemarkIndex: firstIncompleteIndex!)
            _ = mapView.onMapObjectTap(with: nextQuestionPlacemark!, point: YMKPoint(location: location))
        }
    }
}

// MARK: - MapViewDelegate

extension MapController: MapViewDelegate {

    func mapView(_ mapView: MapView, didChange cameraPosition: YMKCameraPosition, userInitiated: Bool) {
        if userInitiated {
            isTrackingEnabled = false
            isNorthOriented = cameraPosition.azimuth == 0
        }
        orientToNorthButton.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * CGFloat(cameraPosition.azimuth) / 180)
    }
    
    func mapView(_ mapView: MapView, didSelect placemark: YMKPlacemarkMapObject) {
        guard let placemarkData = placemark.userData as? PlacemarkData else { return }
        
        if placemarkData.isCallout {
            placemarkData.isLocked ? mapView.removeCallout() : presentQuestionVC(for: placemarkData.questionIndex)
        } else {
            showCallout(for: placemarkData)
        }
    }
    
    private func presentQuestionVC(for questionIndex: Int) {
        guard let questionVC = storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController else { return }
        questionVC.route = route
        questionVC.variation = routeVariation
        questionVC.questionIndex = questionIndex
        navigationController?.pushViewController(questionVC, animated: true)
    }
    
    func mapView(_ mapView: MapView, didReceieved routingError: String) {
        present(UIAlertController.ymkErrorAlert(message: routingError), animated: true)
    }
    
    func mapViewNeedsToReloadPlacemarks(_ mapView: MapView) {
        addQuestionPlacemarks()
    }
}
