//
//  Route.swift
//  SpaceQuest
//
//  Created by Максим Голов on 16.11.2020.
//

import Foundation

// MARK: - RouteVariation

/// Вариация сложности маршурта
final class RouteVariation {
    
    // MARK: - Internal Properties
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
final class Route {
    
    // MARK: - Internal Properties
    /// Имя маршрута для отправки наград
    let id: String
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
    /// Максимально возможное количество очков
    var maxScore: Int {
        return questions.count * 3
    }
    /// Пройденная дистанция
    var distancePassed: Int {
        let distance = questions.reduce(into: 0) {
            $0 += $1.location.isVisited ? $1.location.distance : 0
        }
        return Int(Double(distance) * 1.1)
    }
    /// Соженные калории
    var caloriesBurned: Int {
        return Int(0.06 * Double(distancePassed))
    }
    /// Завершен ли маршрут
    var isCompleted: Bool {
        return variations.contains { isVariationComplete($0) }
    }
    /// Посещена ли большая часть локаций
    var isMoreThanHalfVisited: Bool {
        let visitedCount = questions.filter { $0.location.isVisited }.count
        return visitedCount * 2 > questions.count
    }
    
    // MARK: - Initializers
    
    init(id: String, imageFileName: String, title: String, subtitle: String, questions: [Question], variations: [RouteVariation]) {
        self.id = id
        self.imageFileName = imageFileName
        self.title = title
        self.subtitle = subtitle
        self.questions = questions
        self.variations = variations
    }
    
    // MARK: - Internal Methods
    
    subscript(index: Int) -> Question {
        get { return questions[index] }
    }
    
    /// Процент прохождения вариации маршрута пользователем
    func progress(for variation: RouteVariation) -> Int {
        let completedCount = variation.questionIndexes.filter { questions[$0].isComplete }.count
        return (completedCount * 100) / variation.questionIndexes.count
    }
    
    /// Первый не пройденный вопрос для заданной вариации маршрута
    func firstIncompleteIndex(for variation: RouteVariation) -> Int? {
        return variation.questionIndexes.firstIndex {
            !questions[$0].isComplete
        }
    }
    
    /// Пройдена ли указанная вариация маршрута
    func isVariationComplete(_ variation: RouteVariation) -> Bool {
        return firstIncompleteIndex(for: variation) == nil
    }
    
    func dataToSave() -> [QuestionData] {
        return questions.map { $0.dataToSave }
    }
}
