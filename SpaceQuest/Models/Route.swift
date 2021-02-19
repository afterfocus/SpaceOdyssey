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
    /// Максимально возможное количество очков
    var maxScore: Int {
        return questions.count * 3
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
        let completed = variation.questionIndexes.reduce(into: 0) {
            $0 += questions[$1].isComplete ? 1 : 0
        }
        return (completed * 100) / variation.questionIndexes.count
    }
    
    /// Первый не пройденный вопрос для заданной вариации маршрута
    func firstIncompleteIndex(for variation: RouteVariation) -> Int? {
        for (index, questionIndex) in variation.questionIndexes.enumerated() {
            if !questions[questionIndex].isComplete {
                return index
            }
        }
        return nil
    }
    
    /// Пройдена ли указанная вариация маршрута
    func isVariationComplete(_ variation: RouteVariation) -> Bool {
        for questionIndex in variation.questionIndexes where !questions[questionIndex].isComplete {
            return false
        }
        return true
    }
    
    func dataToSave() -> [QuestionData] {
        return questions.map {
            QuestionData(isComplete: $0.isComplete, score: $0.score)
        }
    }
}
