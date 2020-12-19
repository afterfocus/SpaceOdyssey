//
//  Question.swift
//  SpaceQuest
//
//  Created by Максим Голов on 16.11.2020.
//

import Foundation

/// Вопрос
class Question {
    /// Название вопроса
    let title: String
    /// Адрес достопремичательности
    let address: String
    /// Автор вопроса
    let author: Author
    /// Текст вопроса
    let questionText: String
    /// Ссылка на видео с вопросом
    let questionVideoUrl: URL?
    /// Правильный ответ (построчно)
    let answer: [String]
    /// Список букв, из которых пользователь может составлять ответ
    let answerButtons: [Character]
    /// Ссылка на видео с правильным ответом
    let answerVideoUrl: URL?
    /// Количнство очков, заработанных пользователем за ответ
    let score: Int
    /// Фамилия и инициалы автора
    var authorInitials: String {
        return "\(author.surname) \(author.name.first!)." + (author.patronymic.count > 0 ? " \(author.patronymic.first!)." : "")
    }
    
    init(title: String, address: String, author: Author, questionText: String, questionVideoUrl: URL?, answerVideoUrl: URL?, answer: [String], answerButtons: String, score: Int) {
        self.title = title
        self.address = address
        self.author = author
        self.questionText = questionText
        self.questionVideoUrl = questionVideoUrl
        self.answerVideoUrl = answerVideoUrl
        self.answer = answer
        self.answerButtons = Array(answerButtons)
        self.score = score
    }
}
