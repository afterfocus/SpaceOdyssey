//
//  Location.swift
//  SpaceQuest
//
//  Created by Максим Голов on 08.02.2021.
//

import Foundation

class Location {
    /// Название достопремичательности
    let name: String
    /// Название достопремичательности
    let address: String
    /// Широта
    let latitude: Double
    /// Долгота
    let longtitude: Double
    /// Название файла с фотографией
    let photoFilename: String
    
    init(name: String, address: String, latitude: Double, longtitude: Double, photoFilename: String) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longtitude = longtitude
        self.photoFilename = photoFilename
    }
}
