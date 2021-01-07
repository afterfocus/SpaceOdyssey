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
    /// Об авторе
    let aboutAuthor: String
    
    init(surname: String, name: String, patronymic: String, aboutAuthor: String) {
        self.surname = surname
        self.name = name
        self.patronymic = patronymic
        self.aboutAuthor = aboutAuthor
    }
}