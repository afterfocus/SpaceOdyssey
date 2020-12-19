//
//  Route.swift
//  SpaceQuest
//
//  Created by Максим Голов on 16.11.2020.
//

import Foundation

// MARK: - RouteVariation

/// Вариация сложности маршурта
class RouteVariation {
    /// Длина маршрута в километрах
    let length: Double
    /// Длительность маршрута в минутах
    let duration: Int
    /// Номера вопросов
    let questionIndexes: [Int]
    
    init(length: Double, duration: Int, questionIndexes: [Int]) {
        self.length = length
        self.duration = duration
        self.questionIndexes = questionIndexes
    }
    
    subscript(index: Int) -> Int {
        get { return questionIndexes[index] }
    }
}

// MARK: - Route

/// Маршрут
class Route {
    /// Название файла изобрежния-заставки
    let imageFileName: String
    /// Название маршрута
    let title: String
    /// Описание маршрута
    let subtitle: String
    /// Вопросы
    let questions: [Question]
    /// Вариации сложности
    let variations: [RouteVariation]
    /// Количество очков, заработанных пользователем
    var score: Int {
        return questions.reduce(0) { $0 + $1.score }
    }
    
    init(imageFileName: String, title: String, subtitle: String, questions: [Question], variations: [RouteVariation]) {
        self.imageFileName = imageFileName
        self.title = title
        self.subtitle = subtitle
        self.questions = questions
        self.variations = variations
    }
    
    subscript(index: Int) -> Question {
        get { return questions[index] }
    }
    
    /// Процент прохождения вариации маршрута пользователем
    func progress(for variation: RouteVariation) -> Int {
        var completed = 0
        for questionIndex in variation.questionIndexes where questions[questionIndex].score > 0 {
            completed += 1
        }
        return (completed * 100) / variation.questionIndexes.count
    }
}
