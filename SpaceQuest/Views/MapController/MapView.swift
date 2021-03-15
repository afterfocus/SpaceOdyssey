//
//  MapView.swift
//  SpaceQuest
//
//  Created by Максим Голов on 08.03.2021.
//

import UIKit
import YandexMapsMobile

// MARK: - MapViewDelegate

protocol MapViewDelegate: class {
    func mapView(_ mapView: MapView, didChange cameraPosition: YMKCameraPosition, userInitiated: Bool)
    func mapView(_ mapView: MapView, didSelect placemark: YMKPlacemarkMapObject)
    func mapView(_ mapView: MapView, didReceieved routingError: String)
    func mapViewNeedsToReloadPlacemarks(_ mapView: MapView)
}

// MARK: - MapView

final class MapView: UIView {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var mapView: YMKMapView!
    
    // MARK: - Public properties
    
    public var isNightModeEnabled: Bool {
        get { map.isNightModeEnabled }
        set { map.isNightModeEnabled = newValue }
    }
    
    public weak var delegate: MapViewDelegate?
    
    public var map: YMKMap {
        mapView.mapWindow.map
    }
    
    public var needsToBuildRoute = true
    
    // MARK: - Private properties
    
    private let pedestrianRouter = YMKTransport.sharedInstance()!.createPedestrianRouter()
    private var masstransitSession: YMKMasstransitSession?
    
    private var selectedPlacemark: YMKPlacemarkMapObject! {
        willSet {
            newValue?.zIndex = 100
            selectedPlacemark?.zIndex = 1
        }
    }
    
    private var callout: YMKPlacemarkMapObject! {
        willSet {
            if callout != nil {
                map.mapObjects.remove(with: callout)
            }
        }
    }
    
    // MARK: - Public methods
    
    func initialize() {
        map.addCameraListener(with: self)
        map.addInputListener(with: self)
        map.mapObjects.addTapListener(with: self)
        
        let userLocationLayer = YMKMapKit.sharedInstance().createUserLocationLayer(with: mapView.mapWindow)
        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.setObjectListenerWith(self)
    }
    
    func zoomIn(step: Float, duration: Float) {
        moveCamera(zoom: map.cameraPosition.zoom + step, duration: duration)
    }
    
    func zoomOut(step: Float, duration: Float) {
        moveCamera(zoom: map.cameraPosition.zoom - step, duration: duration)
    }
    
    func turnToNorth(duration: Float) {
        moveCamera(azimuth: 0, duration: duration)
    }
    
    func moveCamera(target: YMKPoint? = nil,
                    zoom: Float? = nil,
                    azimuth: Float? = nil,
                    tilt: Float? = nil,
                    animationType: YMKAnimationType = .smooth,
                    duration: Float) {
        map.move(with: YMKCameraPosition(target: target ?? map.cameraPosition.target,
                                         zoom: zoom ?? map.cameraPosition.zoom,
                                         azimuth: azimuth ?? map.cameraPosition.azimuth,
                                         tilt: tilt ?? map.cameraPosition.tilt),
                 animationType: YMKAnimation(type: animationType, duration: duration))
    }
    
    func addPlacemark(location: Location, placemark: MapPlacemarkView) -> YMKPlacemarkMapObject {
        return map.mapObjects.addPlacemark(with: YMKPoint(location: location),
                                           view: YRTViewProvider(uiView: placemark))
    }
    
    func addGeoCircle(location: Location) {
        let circle = YMKCircle(center: YMKPoint(location: location),
                               radius: Float(location.activationRadius))
        map.mapObjects.addCircle(with: circle,
                                 stroke: UIColor.systemBlue.withAlphaComponent(0.4),
                                 strokeWidth: 2.5,
                                 fill: UIColor.systemBlue.withAlphaComponent(0.2))
    }
    
    func buildRoute(startPoint: YMKPoint, endPoint: YMKPoint) {
        let requestPoints = [YMKRequestPoint(point: startPoint, type: .waypoint, pointContext: nil),
                             YMKRequestPoint(point: endPoint, type: .waypoint, pointContext: nil)]
        
        masstransitSession = pedestrianRouter.requestRoutes(with: requestPoints, timeOptions: .init()) {
            routesResponse, error in
            if let routes = routesResponse {
                self.map.mapObjects.clear()
                self.delegate?.mapViewNeedsToReloadPlacemarks(self)
                let polyline = self.map.mapObjects.addPolyline(with: routes[0].geometry)
                polyline.strokeColor = self.map.isNightModeEnabled ? .systemYellow : .lightBlue
                self.needsToBuildRoute = false
            } else {
                self.onRoutesError(error!)
            }
        }
    }
    
    func show(mapCallout: MapCalloutView, at point: YMKPoint) -> YMKPlacemarkMapObject {
        let style = YMKIconStyle(anchor: CGPoint(x: 1, y: 1) as NSValue,
                                 rotationType: nil, zIndex: 100, flat: 0, visible: 1, scale: 1, tappableArea: nil)
        callout = map.mapObjects.addPlacemark(with: point,
                                              image: convertViewToImage(mapCallout)!,
                                              style: style)
        let deltaX = Float(120 * UIScreen.main.scale)
        let deltaY = Float(135 * UIScreen.main.scale)
        let calloutScreenPoint = mapView.mapWindow.worldToScreen(withWorldPoint: callout.geometry)!
        let ymkScreenPoint = YMKScreenPoint(x: calloutScreenPoint.x - deltaX,
                                            y: calloutScreenPoint.y - deltaY)
        moveCamera(target: mapView.mapWindow.screenToWorld(with: ymkScreenPoint)!, duration: 0.5)
        return callout
    }
    
    func removeCallout() {
        selectedPlacemark = nil
        callout = nil
    }
    
    func clearObjects() {
        selectedPlacemark = nil
        callout = nil
        map.mapObjects.clear()
    }
    
    // MARK: - Private methods
    
    private func onRoutesError(_ error: Error) {
        let routingError = (error as NSError).userInfo[YRTUnderlyingErrorKey] as! YRTError
        var errorMessage = "Unknown error"
        if routingError.isKind(of: YRTNetworkError.self) {
            errorMessage = "Network error"
        } else if routingError.isKind(of: YRTRemoteError.self) {
            errorMessage = "Remote server error"
        }
        delegate?.mapView(self, didReceieved: errorMessage)
    }
    
    private func convertViewToImage(_ view: UIView) -> UIImage? {
        let size = CGSize(width: view.bounds.size.width, height: view.bounds.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - YMKMapCameraListener

extension MapView: YMKMapCameraListener {
    
    func onCameraPositionChanged(with map: YMKMap,
                                 cameraPosition: YMKCameraPosition,
                                 cameraUpdateReason: YMKCameraUpdateReason,
                                 finished: Bool) {
        delegate?.mapView(self, didChange: cameraPosition, userInitiated: cameraUpdateReason == .gestures)
    }
}

// MARK: - YMKMapObjectTapListener

extension MapView: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let placemark = mapObject as? YMKPlacemarkMapObject,
              placemark != selectedPlacemark else {
            removeCallout()
            return false
        }
        selectedPlacemark = placemark
        delegate?.mapView(self, didSelect: placemark)
        return true
    }
}

// MARK: - YMKMapInputListener

extension MapView: YMKMapInputListener {
    
    func onMapTap(with map: YMKMap, point: YMKPoint) {
        callout = nil
        selectedPlacemark = nil
    }
    
    func onMapLongTap(with map: YMKMap, point: YMKPoint) { }
}

// MARK: - YMKUserLocationObjectListener

extension MapView: YMKUserLocationObjectListener {
    
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
