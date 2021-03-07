//
//  Question.swift
//  SpaceQuest
//
//  Created by Максим Голов on 16.11.2020.
//

import Foundation

/// Вопрос
final class Question {
    /// Название вопроса
    let title: String
    /// Локация
    let location: Location
    /// Автор вопроса
    let author: Author
    /// Текст вопроса
    let questionText: String
    /// Ссылка на видео с вопросом
    let questionVideoUrl: URL?
    /// Правильный ответ (построчно)
    let answer: [String]
    /// Альтернативный правильный ответ (построчно)
    let alternativeAnswer: [String]?
    /// Список букв, из которых пользователь может составлять ответ
    let answerCharacters: [Character]
    /// Ссылка на видео с правильным ответом
    let answerVideoUrl: URL?
    /// Завершен ли вопрос
    var isComplete = false
    /// Количество очков, заработанных пользователем за ответ
    var score = 0
    /// Использовано подсказок
    var usedHints = 0
    
    var answerLength: Int {
        var count = 0
        for row in answer {
            Array(row).forEach {
                if $0.isLetter || $0.isNumber { count += 1 }
            }
        }
        return count
    }
    
    init(title: String, location: Location, author: Author, questionText: String, questionVideoUrl: URL?, answerVideoUrl: URL?, answer: [String], alternativeAnswer: [String]? = nil, answerCharacters: String) {
        self.title = title
        self.location = location
        self.author = author
        self.questionText = questionText
        self.questionVideoUrl = questionVideoUrl
        self.answerVideoUrl = answerVideoUrl
        self.answer = answer
        self.answerCharacters = Array(answerCharacters)
        self.alternativeAnswer = alternativeAnswer
    }
}
