//
//  Location.swift
//  SpaceQuest
//
//  Created by Максим Голов on 08.02.2021.
//

import Foundation

final class Location {
    
    // MARK: - Internal Properties
    /// Название достопремичательности
    let name: String
    /// Название достопремичательности
    let address: String
    /// Широта
    let latitude: Double
    /// Долгота
    let longitude: Double
    /// Название файла с фотографией
    let photoFilename: String
    /// Радиус активации вопроса
    let activationRadius: Double
    /// Расстояние до локации от предыдущей точки (в метрах)
    let distance: Int
    /// Посещена ли локация
    var isVisited: Bool
    
    // MARK: - Initializers
    
    init(name: String, address: String, latitude: Double, longitude: Double, photoFilename: String, activationRadius: Double = 35, distance: Int, isVisited: Bool = false) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.photoFilename = photoFilename
        self.activationRadius = activationRadius
        self.isVisited = isVisited
        self.distance = distance
    }
}
