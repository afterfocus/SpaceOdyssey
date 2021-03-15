//
//  Author.swift
//  SpaceQuest
//
//  Created by Максим Голов on 19.12.2020.
//

import Foundation

/// Автор вопроса
final class Author {
    
    // MARK: - Internal Properties
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
    /// Название файла с фотографией автора
    let photoFilename: String
    /// Фамилия и инициалы
    var initials: String {
        let patronymicString = patronymic.count > 0 ? " \(patronymic.first!)." : ""
        return "\(surname) \(name.first!).\(patronymicString)"
    }
    /// Полное ФИО
    var fio: String {
        return "\(surname) \(name)" + (patronymic.count > 0 ? " \(patronymic)" : "")
    }
    
    // MARK: - Initializers
    
    init(surname: String, name: String, patronymic: String, aboutAuthor: String, aboutAuthorFull: String, photoFilename: String) {
        self.surname = surname
        self.name = name
        self.patronymic = patronymic
        self.aboutAuthor = aboutAuthor
        self.aboutAuthorFull = aboutAuthorFull
        self.photoFilename = photoFilename
    }
}
