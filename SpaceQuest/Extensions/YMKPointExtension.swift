//
//  YMKPoint+InitFromLocation.swift
//  SpaceQuest
//
//  Created by Максим Голов on 14.03.2021.
//

import YandexMapsMobile
import CoreLocation

extension YMKPoint {
    
    convenience init(location: Location) {
        self.init(latitude: location.latitude, longitude: location.longitude)
    }
    
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
