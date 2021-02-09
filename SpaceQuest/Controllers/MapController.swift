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

class MapController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var mapView: YMKMapView!
    @IBOutlet weak var topGradientView: TopGradientView!
    @IBOutlet weak var enableTrackingButton: UIButton!
    @IBOutlet weak var orientToNorthButton: UIButton!
    
    // MARK: - Segue Properties
    
    var route: Route = DataProvider.routes[0]
    var routeVariation: RouteVariation = DataProvider.routes[0].variations[2]
    
    // MARK: - Private Properties
    
    private var locationManager = CLLocationManager()
    private var drivingSession: YMKDrivingSession?
    private var map: YMKMap {
        return mapView.mapWindow.map
    }
    private var isTrackingEnabled: Bool! {
        didSet {
            enableTrackingButton.isEnabled = !isTrackingEnabled
            enableTrackingButton.backgroundColor = colorForButton(isEnabled: !isTrackingEnabled)
        }
    }
    private var isNorthOriented: Bool! {
        didSet {
            orientToNorthButton.isEnabled = !isNorthOriented
            orientToNorthButton.backgroundColor = colorForButton(isEnabled: !isNorthOriented)
        }
    }
    private var callout: YMKPlacemarkMapObject! {
        willSet {
            if callout != nil {
                map.mapObjects.remove(with: callout)
            }
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topGradientView.color = UIColor.black.withAlphaComponent(0.3)
        topGradientView.startLocation = 0
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        
        let userLocationLayer = YMKMapKit.sharedInstance().createUserLocationLayer(with: mapView.mapWindow)
        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.setObjectListenerWith(self)
        
        map.addCameraListener(with: self)
        map.mapObjects.addTapListener(with: self)
        map.isNightModeEnabled = UserDefaults.standard.bool(forKey: "isMapNightModeEnabled")
        map.move(with: YMKCameraPosition(target: YMKPoint(latitude: 53.2001, longitude: 50.15),
                                         zoom: 11, azimuth: 0, tilt: 0))
        
        enableTrackingButton.tintColor = map.isNightModeEnabled ? .white : .black
        orientToNorthButton.tintColor = map.isNightModeEnabled ? .white : .black
        enableTrackingButton.layer.dropShadow(opacity: 0.35, radius: 7)
        orientToNorthButton.layer.dropShadow(opacity: 0.35, radius: 7)
        isTrackingEnabled = true
        isNorthOriented = true
    
        addQuestionPlacemarks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3, delay: 0.2, options: []) {
            [weak self] in self?.tabBarController?.tabBar.alpha = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.3) {
            [weak self] in self?.tabBarController?.tabBar.alpha = 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLocationTracking(status: CLLocationManager.authorizationStatus())
    }
    
    // MARK: - IBActions
    
    @IBAction func enableTrackingButtonPressed(_ sender: UIButton) {
        isTrackingEnabled = true
        moveToUserLocation(withAnimationType: .smooth,
                           zoom: map.cameraPosition.zoom < 13 ? 13 : nil,
                           duration: 1)
    }
    
    @IBAction func orientToNorthButtonPressed(_ sender: UIButton) {
        isNorthOriented = true
        map.move(with: YMKCameraPosition(target: map.cameraPosition.target,
                                         zoom: map.cameraPosition.zoom,
                                         azimuth: 0,
                                         tilt: map.cameraPosition.tilt),
                 animationType: YMKAnimation(type: .smooth, duration: 0.5))
    }
    
    @IBAction func modeButtonPressed(_ sender: UIButton) {
        map.isNightModeEnabled = !map.isNightModeEnabled
        isTrackingEnabled.toggle()
        isTrackingEnabled.toggle()
        isNorthOriented.toggle()
        isNorthOriented.toggle()
        enableTrackingButton.tintColor = map.isNightModeEnabled ? .white : .black
        orientToNorthButton.tintColor = map.isNightModeEnabled ? .white : .black
        UserDefaults.standard.setValue(map.isNightModeEnabled, forKey: "isMapNightModeEnabled")
    }
    
    // MARK: - Private Functions
    
    private func colorForButton(isEnabled: Bool) -> UIColor {
        if map.isNightModeEnabled {
            return UIColor.black.withAlphaComponent(isEnabled ? 0.8 : 0.35)
        } else {
            return UIColor.white.withAlphaComponent(isEnabled ? 1 : 0.5)
        }
    }
    
    private func startLocationTracking(status: CLAuthorizationStatus) {
        guard status == .authorizedAlways || status == .authorizedWhenInUse else { return }
        moveToUserLocation(withAnimationType: .smooth, zoom: 16, duration: 2)
        buildRoute()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    private func moveToUserLocation(withAnimationType type: YMKAnimationType,
                                    zoom: Float? = nil,
                                    duration: Float) {
        guard let coordinates = locationManager.location?.coordinate else { return }
        let targetLocation = YMKPoint(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        map.move(with: YMKCameraPosition(target: targetLocation,
                                         zoom: zoom ?? map.cameraPosition.zoom,
                                         azimuth: map.cameraPosition.azimuth,
                                         tilt: map.cameraPosition.tilt),
                 animationType: YMKAnimation(type: type, duration: duration))
    }
    
    private func addQuestionPlacemarks() {
        let firstIncompleteIndex = route.firstIncompleteIndex(for: routeVariation)
        
        for (placemarkIndex, questionIndex) in routeVariation.questionIndexes.enumerated() {
            let location = route[questionIndex].location
            let point = YMKPoint(latitude: location.latitude, longitude: location.longtitude)
            let placemark = MapPlacemark(index: placemarkIndex,
                                         isComplete: route[questionIndex].isComplete,
                                         firstIncompleteIndex: firstIncompleteIndex)
            map.mapObjects.addPlacemark(with: point, view: YRTViewProvider(uiView: placemark))
        }
    }
    
    private func buildRoute() {
        guard let coordinates = locationManager.location?.coordinate,
              let firstIncompleteIndex = route.firstIncompleteIndex(for: routeVariation) else { return }
        let question = route[routeVariation[firstIncompleteIndex]]
        let startPoint = YMKPoint(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let targetPoint = YMKPoint(latitude: question.location.latitude,
                                   longitude: question.location.longtitude)
        
        let requestPoints = [YMKRequestPoint(point: startPoint, type: .waypoint, pointContext: nil),
                             YMKRequestPoint(point: targetPoint, type: .waypoint, pointContext: nil)]
    
        let drivingRouter = YMKDirections.sharedInstance().createDrivingRouter()
        drivingSession = drivingRouter.requestRoutes(with: requestPoints,
                                                     drivingOptions: YMKDrivingDrivingOptions(),
                                                     vehicleOptions: YMKDrivingVehicleOptions()) {
            routesResponse, error in
            if let routes = routesResponse {
                self.map.mapObjects.clear()
                self.addQuestionPlacemarks()
                let polyline = self.map.mapObjects.addPolyline(with: routes[0].geometry)
                polyline.strokeColor = self.map.isNightModeEnabled ? .systemYellow : .lightBlue
            } else {
                self.onRoutesError(error!)
            }
        }
    }
    
    private func onRoutesError(_ error: Error) {
        let routingError = (error as NSError).userInfo[YRTUnderlyingErrorKey] as! YRTError
        var errorMessage = "Unknown error"
        if routingError.isKind(of: YRTNetworkError.self) {
            errorMessage = "Network error"
        } else if routingError.isKind(of: YRTRemoteError.self) {
            errorMessage = "Remote server error"
        }
        let alert = UIAlertController(title: "YandexMapKit Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


// MARK: - YMKMapCameraListener

extension MapController: YMKMapCameraListener {
    
    func onCameraPositionChanged(with map: YMKMap,
                                 cameraPosition: YMKCameraPosition,
                                 cameraUpdateReason: YMKCameraUpdateReason,
                                 finished: Bool) {
        if cameraUpdateReason == .gestures {
            isTrackingEnabled = false
            isNorthOriented = cameraPosition.azimuth == 0
        }
        orientToNorthButton.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * CGFloat(cameraPosition.azimuth) / 180)
    }
}


// MARK: - CLLocationManagerDelegate

extension MapController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {

        
        let mapCallout: MapCallout = MapCallout.fromNib()
        mapCallout.configure(for: route[0].location)
        
        let style = YMKIconStyle(anchor: CGPoint(x: 1, y: 1) as NSValue,
                                 rotationType: nil,
                                 zIndex: 100,
                                 flat: 0,
                                 visible: 1,
                                 scale: 1,
                                 tappableArea: nil)
        callout = map.mapObjects.addPlacemark(with: point, image: convertViewToImage(mapCallout)!, style: style)
        callout.opacity = 1
        return true
    }
    
    private func convertViewToImage(_ view: UIView) -> UIImage? {
        let size = CGSize(width: view.bounds.size.width, height: view.bounds.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
        }
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


// MARK: - CLLocationManagerDelegate

extension MapController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        startLocationTracking(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if isTrackingEnabled {
            moveToUserLocation(withAnimationType: .linear, duration: 0.2)
        }
    }
}


// MARK: - YMKUserLocationObjectListener

extension MapController: YMKUserLocationObjectListener {
    
    func onObjectAdded(with view: YMKUserLocationView) {
        view.accuracyCircle.fillColor = UIColor.systemBlue.withAlphaComponent(0.25)
        view.accuracyCircle.strokeColor = UIColor.systemBlue.withAlphaComponent(0.4)
        view.accuracyCircle.strokeWidth = 2
        
        view.pin.setIconWith(UIImage(named: "user_location_pin")!,
                             style: YMKIconStyle(anchor: CGPoint(x: 0.5, y: 1) as NSValue,
                                                 rotationType: YMKRotationType.noRotation.rawValue as NSNumber,
                                                 zIndex: 0,
                                                 flat: false,
                                                 visible: true,
                                                 scale: 1,
                                                 tappableArea: nil))
        
        view.arrow.setIconWith(UIImage(named: "user_location_arrow")!,
                               style: YMKIconStyle(anchor: nil,
                                                   rotationType: YMKRotationType.rotate.rawValue as NSNumber,
                                                   zIndex: 0,
                                                   flat: true,
                                                   visible: true,
                                                   scale: 1,
                                                   tappableArea: nil))
    }
    
    func onObjectRemoved(with view: YMKUserLocationView) { }
    
    func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) { }
}
