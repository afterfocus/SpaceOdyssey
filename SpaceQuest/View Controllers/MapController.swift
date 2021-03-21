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
    
    // MARK: - Types
    
    private enum OrientationMode {
        case userDefined
        case northOriented
        case compass
    }
    
    // MARK: - IBOutlets
    
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
    
    private lazy var firstIncompleteIndex: Int? = route.firstIncompleteIndex(for: routeVariation) {
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
    private var orientationMode = OrientationMode.northOriented {
        didSet {
            let isInCompassMode = orientationMode == .compass
            orientToNorthButton.isEnabled = !isInCompassMode
            orientToNorthButton.backgroundColor = backgroundColorForButton(isEnabled: !isInCompassMode)
            orientToNorthButton.tintColor = tintColorForOrientToNorthButton(isInCompassMode: isInCompassMode)
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
        orientToNorthButton.backgroundColor = backgroundColorForButton(isEnabled: true)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.headingFilter = 3
        locationManager.startUpdatingHeading()
        
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
            buildRoute()
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
    
    // MARK: - IBActions
    
    @IBAction func zoomInButtonPressed(_ sender: UIButton) {
        mapView.zoomIn(step: 1.5)
    }
    
    @IBAction func zoomOutButtonPressed(_ sender: UIButton) {
        mapView.zoomOut(step: 1.5)
    }
    
    @IBAction func enableTrackingButtonPressed(_ sender: UIButton) {
        isTrackingEnabled = true
        moveToUserLocation(withAnimationType: .smooth,
                           zoom: mapView.currentZoom < 13 ? 13 : nil)
    }
    
    @IBAction func orientToNorthButtonPressed(_ sender: UIButton) {
        switch orientationMode {
        case .userDefined:
            orientationMode = .northOriented
            mapView.turnToNorth()
        case .northOriented:
            orientationMode = .compass
            guard let heading = locationManager.heading?.trueHeading else { return }
            mapView.moveCamera(azimuth: Float(heading), animationType: .smooth)
        case .compass:
            return
        }
    }
    
    // MARK: - Private Functions
    
    private func backgroundColorForButton(isEnabled: Bool) -> UIColor {
        if mapView.isNightModeEnabled {
            return UIColor.black.withAlphaComponent(isEnabled ? 0.8 : 0.35)
        } else {
            return UIColor.white.withAlphaComponent(isEnabled ? 1 : 0.5)
        }
    }
    
    private func tintColorForOrientToNorthButton(isInCompassMode: Bool) -> UIColor {
        if mapView.isNightModeEnabled {
            return isInCompassMode ? .systemYellow : .white
        } else {
            return isInCompassMode ? .systemBlue : .black
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.buildRoute()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    private func moveToUserLocation(withAnimationType type: YMKAnimationType, zoom: Float? = nil, duration: Float? = nil) {
        guard let coordinates = locationManager.location?.coordinate else { return }
        mapView.moveCamera(
            point: YMKPoint(coordinate: coordinates),
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
              let question = nextQuestion else {
            mapView.clearObjects()
            mapViewNeedsToReloadPlacemarks(mapView)
            return
        }
    
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
            mapView.remove(mapObject: nextQuestionPlacemark!)
            addPlacemark(question: nextQuestion!, placemarkIndex: firstIncompleteIndex!)
            _ = mapView.onMapObjectTap(with: nextQuestionPlacemark!, point: YMKPoint(location: location))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if orientationMode == .compass {
            mapView.moveCamera(azimuth: Float(newHeading.trueHeading), animationType: .linear, duration: 1)
        }
    }
}

// MARK: - MapViewDelegate

extension MapController: MapViewDelegate {

    func mapView(_ mapView: MapView, didChange cameraPosition: YMKCameraPosition, userInitiated: Bool) {
        orientToNorthButton.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * CGFloat(cameraPosition.azimuth) / 180)
        
        guard userInitiated else { return }
        isTrackingEnabled = false
        if cameraPosition.azimuth != 0 {
            orientationMode = .userDefined
        }
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
    
    func mapViewFailedToBuildRoute(_ mapView: MapView) {
        present(UIAlertController.tooFarFromLocationAlert, animated: true)
    }
    
    func mapView(_ mapView: MapView, didReceieved routingError: String) {
        present(UIAlertController.ymkErrorAlert(message: routingError), animated: true)
    }
    
    func mapViewNeedsToReloadPlacemarks(_ mapView: MapView) {
        addQuestionPlacemarks()
    }
}
