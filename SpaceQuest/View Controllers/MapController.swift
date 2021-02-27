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
    
    @IBOutlet weak var topGradientView: TopGradientView!
    @IBOutlet weak var mapView: YMKMapView!
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
    private let pedestrianRouter = YMKTransport.sharedInstance()!.createPedestrianRouter()
    private var masstransitSession: YMKMasstransitSession?
    private var firstIncompleteIndex: Int?
    private var map: YMKMap {
        return mapView.mapWindow.map
    }
    private var selectedPlacemark: YMKPlacemarkMapObject! {
        willSet {
            newValue?.zIndex = 100
            selectedPlacemark?.zIndex = 0
        }
    }
    private var callout: YMKPlacemarkMapObject! {
        willSet {
            if callout != nil {
                map.mapObjects.remove(with: callout)
            }
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
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topGradientView.color = UIColor.black.withAlphaComponent(0.35)
        topGradientView.startLocation = 0
        
        map.addCameraListener(with: self)
        map.addInputListener(with: self)
        map.mapObjects.addTapListener(with: self)
        map.isNightModeEnabled = DataModel.current.isMapNightModeEnabled
        map.move(with: YMKCameraPosition(target: YMKPoint(latitude: 53.2001, longitude: 50.15),
                                         zoom: 11, azimuth: 0, tilt: 0))
        
        let tintColor: UIColor = map.isNightModeEnabled ? .white : .black
        zoomInButton.tintColor = tintColor
        zoomOutButton.tintColor = tintColor
        enableTrackingButton.tintColor = tintColor
        orientToNorthButton.tintColor = tintColor
        
        zoomInButton.backgroundColor = backgroundColorForButton(isEnabled: true)
        zoomOutButton.backgroundColor = backgroundColorForButton(isEnabled: true)
        enableTrackingButton.backgroundColor = backgroundColorForButton(isEnabled: false)
        orientToNorthButton.backgroundColor = backgroundColorForButton(isEnabled: false)
        
        questionLabel.layer.dropShadow(opacity: 0.7, radius: 7)
        distanceLabel.layer.dropShadow(opacity: 0.7, radius: 7)
        distanceUnitLabel.layer.dropShadow(opacity: 0.7, radius: 7)
        zoomInButton.layer.dropShadow(opacity: 0.35, radius: 7)
        zoomOutButton.layer.dropShadow(opacity: 0.35, radius: 7)
        enableTrackingButton.layer.dropShadow(opacity: 0.35, radius: 7)
        orientToNorthButton.layer.dropShadow(opacity: 0.35, radius: 7)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        
        let userLocationLayer = YMKMapKit.sharedInstance().createUserLocationLayer(with: mapView.mapWindow)
        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.setObjectListenerWith(self)
        addQuestionPlacemarks()
        
        firstIncompleteIndex = route.firstIncompleteIndex(for: routeVariation)
        
        if let index = firstIncompleteIndex {
            questionLabel.text = "\(index + 1). \(route[routeVariation[index]].title)"
        } else {
            questionLabel.text = "Маршрут завершен"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3, delay: 0.2, options: []) {
            [weak self] in self?.tabBarController?.tabBar.alpha = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        selectedPlacemark = nil
        callout = nil
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
        let cameraPosition = YMKCameraPosition(target: map.cameraPosition.target,
                                               zoom: map.cameraPosition.zoom + 1.5,
                                               azimuth: map.cameraPosition.azimuth,
                                               tilt: map.cameraPosition.tilt)
        map.move(with: cameraPosition, animationType: YMKAnimation(type: .smooth, duration: 0.5), cameraCallback: nil)
    }
    
    @IBAction func zoomOutButtonPressed(_ sender: UIButton) {
        let cameraPosition = YMKCameraPosition(target: map.cameraPosition.target,
                                               zoom: map.cameraPosition.zoom - 1.5,
                                               azimuth: map.cameraPosition.azimuth,
                                               tilt: map.cameraPosition.tilt)
        map.move(with: cameraPosition, animationType: YMKAnimation(type: .smooth, duration: 0.5), cameraCallback: nil)
    }
    
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
    
    // MARK: - Private Functions
    
    private func backgroundColorForButton(isEnabled: Bool) -> UIColor {
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
        for (placemarkIndex, questionIndex) in routeVariation.questionIndexes.enumerated() {
            let question = route[questionIndex]
            let point = YMKPoint(latitude: question.location.latitude, longitude: question.location.longtitude)
            let placemarkView = MapPlacemarkView(index: placemarkIndex,
                                                 isComplete: route[questionIndex].isComplete,
                                                 isLocked: placemarkIndex > (firstIncompleteIndex ?? 100))
            let ymkPlacemark = map.mapObjects.addPlacemark(with: point, view: YRTViewProvider(uiView: placemarkView))
            ymkPlacemark.userData = question
            ymkPlacemark.zIndex = 0
        }
    }
    
    private func buildRoute() {
        guard let coordinates = locationManager.location?.coordinate,
              let firstIncompleteIndex = firstIncompleteIndex else { return }
        let question = route[routeVariation[firstIncompleteIndex]]
        
        let startPoint = YMKPoint(latitude: coordinates.latitude, longitude: coordinates.longitude)
        routeEndPoint = YMKPoint(latitude: question.location.latitude,
                                 longitude: question.location.longtitude)
        
        let requestPoints = [YMKRequestPoint(point: startPoint, type: .waypoint, pointContext: nil),
                             YMKRequestPoint(point: routeEndPoint!, type: .waypoint, pointContext: nil)]
        
        masstransitSession = pedestrianRouter.requestRoutes(with: requestPoints, timeOptions: .init()) {
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


// MARK: - YMKMapObjectTapListener

extension MapController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let ymkPlacemark = mapObject as? YMKPlacemarkMapObject,
              let question = ymkPlacemark.userData as? Question,
              ymkPlacemark != selectedPlacemark else {
            callout = nil
            selectedPlacemark = nil
            return false
        }
        selectedPlacemark = ymkPlacemark
        
        let mapCallout: MapCalloutView = MapCalloutView.fromNib()
        mapCallout.configure(for: question.location)
        
        let style = YMKIconStyle(anchor: CGPoint(x: 1, y: 1) as NSValue,
                                 rotationType: nil,
                                 zIndex: 100,
                                 flat: 0,
                                 visible: 1,
                                 scale: 1,
                                 tappableArea: nil)
        callout = map.mapObjects.addPlacemark(with: YMKPoint(latitude: question.location.latitude,
                                                             longitude: question.location.longtitude),
                                              image: convertViewToImage(mapCallout)!,
                                              style: style)
        
        let deltaX = Float(120 * UIScreen.main.scale)
        let deltaY = Float(135 * UIScreen.main.scale)
        let calloutScreenPoint = mapView.mapWindow.worldToScreen(withWorldPoint: callout.geometry)!
        let ymkScreenPoint = YMKScreenPoint(x: calloutScreenPoint.x - deltaX, y: calloutScreenPoint.y - deltaY)
        
        map.move(with: YMKCameraPosition(target: mapView.mapWindow.screenToWorld(with: ymkScreenPoint)!,
                                         zoom: map.cameraPosition.zoom,
                                         azimuth: map.cameraPosition.azimuth,
                                         tilt: map.cameraPosition.tilt),
                 animationType: YMKAnimation(type: .smooth, duration: 0.5),
                 cameraCallback: nil)
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


// MARK: - YMKMapInputListener

extension MapController: YMKMapInputListener {
    
    func onMapTap(with map: YMKMap, point: YMKPoint) {
        callout = nil
        selectedPlacemark = nil
    }
    
    func onMapLongTap(with map: YMKMap, point: YMKPoint) { }
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
        guard let endPoint = routeEndPoint,
              let coordinates = locationManager.location?.coordinate else { return }
        let currentPoint = YMKPoint(latitude: coordinates.latitude, longitude: coordinates.longitude)
        var distance = YMKDistance(currentPoint, endPoint)
        
        if distance > 1000 {
            distance /= 1000
            distanceLabel.text = "\(String(format: "%.1f", distance))"
            distanceUnitLabel.text = "км"
        } else {
            distanceLabel.text = "\(Int(distance))"
            distanceUnitLabel.text = "м"
        }
    }
}


// MARK: - YMKLocationDelegate

extension MapController: YMKLocationDelegate {
    
    func onLocationUpdated(with location: YMKLocation) {
        print(#function)
    }
    
    func onLocationStatusUpdated(with status: YMKLocationStatus) { }
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
