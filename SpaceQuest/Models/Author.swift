//
//  Author.swift
//  SpaceQuest
//
//  Created by Максим Голов on 19.12.2020.
//

import Foundation

/// Автор вопроса
class Author {
    /// Фамилия
    let surname: String
    /// Имя
    let name: String
    /// Отчество
    let patronymic: String
    /// Об авторе (должность)
    let aboutAuthor: String
    /// Об авторе (полный текст)
    let aboutAuthorFull: String
    /// Фамилия и инициалы
    var initials: String {
        return "\(surname) \(name.first!)." + (patronymic.count > 0 ? " \(patronymic.first!)." : "")
    }
    /// Полное ФИО
    var fio: String {
        return "\(surname) \(name)" + (patronymic.count > 0 ? " \(patronymic)" : "")
    }
    
    init(surname: String, name: String, patronymic: String, aboutAuthor: String, aboutAuthorFull: String) {
        self.surname = surname
        self.name = name
        self.patronymic = patronymic
        self.aboutAuthor = aboutAuthor
        self.aboutAuthorFull = aboutAuthorFull
    }
}
