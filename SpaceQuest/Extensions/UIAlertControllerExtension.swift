//
//  UIAlertExtension.swift
//  SpaceQuest
//
//  Created by Максим Голов on 07.03.2021.
//

import UIKit

extension UIAlertController {
    
    public static func okAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.okAction)
        return alert
    }
    
    public static var incorrentNameAlert: UIAlertController {
        return okAlert(
            title: "Ошибка входа",
            message: "Пожалуйста, укажите корректное имя пользователя.")
    }
    
    public static var incorrentEmailAlert: UIAlertController {
        return okAlert(
            title: "Ошибка входа",
            message: "Указан некорректный адрес электронной почты.\nПожалуйста, укажите существующий адрес электронной почты для доставки наград.")
    }
    
    public static var cannotSendEmailAlert: UIAlertController {
        return okAlert(
            title: "Отправка E-mail недоступа.",
            message: "\nОтправка E-mail невозможна в связи с настройками Вашего устройства.")
    }
    
    public static var profileEditSuccessAlert: UIAlertController {
        return okAlert(
            title: "Данные изменены",
            message: "Для повторного входа необходимо использовать новое имя пользователя и электронную почту.")
    }
    
    public static var profileEditFailedAlert: UIAlertController {
        return okAlert(
            title: "Ошибка изменения данных",
            message: "Пользователь с таким именем и электронной почтой уже зарегистрирован на устройстве.\nПожалуйста, осуществите вход в профиль данного пользователя или укажите другую комбинацию имени и электронной почты.")
    }
    
    public static var registrationPrizesNotSendWithUndefinedError: UIAlertController {
        return okAlert(
            title: "Ошибка отправки награды за регистрацию",
            message: "Произошла неизвестная ошибка при отправке наград за регистрацию на указанный Вами email. Пожалуйста, повторите попытку позже или напишите нам об этом через форму «‎Напишите нам».‎")
    }
    
    public static func registrationPrizesNotSend(errorCode: Int) -> UIAlertController {
        return okAlert(
            title: "Ошибка отправки награды за регистрацию",
            message: "Произошла ошибка при отправке наград за регистрацию на указанный Вами email. Пожалуйста, повторите попытку позже или напишите нам об этом через форму «‎Напишите нам».‎\nКод ошибки: \(errorCode).")
    }
    
    public static var routePrizesNotSendWithUndefinedError: UIAlertController {
        return okAlert(
            title: "Ошибка отправки наград за прохождение маршрута",
            message: "Произошла неизвестная ошибка при отправке наград за прохождение маршрута на указанный Вами email. Пожалуйста, повторите попытку позже или напишите нам об этом через форму «‎Напишите нам».‎")
    }
    
    public static func routePrizesNotSend(errorCode: Int) -> UIAlertController {
        return okAlert(
            title: "Ошибка отправки наград за прохождение маршрута",
            message: "Произошла ошибка при отправке наград за прохождение маршрута на указанный Вами email. Пожалуйста, повторите попытку позже или напишите нам об этом через форму «‎Напишите нам».‎\nКод ошибки: \(errorCode).")
    }
    
    public static var resendPrizesSuccessful: UIAlertController {
        return okAlert(
            title: "Награды успешно отправлены",
            message: "Все полученные Вами награды успешно переотправлены на указанный Вами адрес электронной почты.")
    }
    
    public static func ymkErrorAlert(message: String) -> UIAlertController {
        return okAlert(
            title: "YandexMapKit Error",
            message: message)
    }
    
    public static func useHintAlert(remainingHints: Int, onHintUse: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "Использовать подсказку",
            message: "\nИспользовать одну из оставшихся подсказок, чтобы открыть первую и последнюю буквы?\n\nОставшихся подсказок: \(remainingHints)",
            preferredStyle: .alert)
        let useAction = UIAlertAction(title: "Использовать", style: .default) { _ in
            onHintUse()
        }
        alert.addAction(.cancelAction)
        alert.addAction(useAction)
        return alert
    }
    
    public static func confirmExitAlert(onExitConfirmed: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "Вы действительно хотите выйти?",
            message: "\nВесь прогресс пользователя будет сохранен и восстановлен при следующем входе.",
            preferredStyle: .alert)
        let exitAction = UIAlertAction(title: "Выход", style: .default) { _ in
            onExitConfirmed()
        }
        alert.addAction(exitAction)
        alert.addAction(.cancelAction)
        return alert
    }
    
    public static func confirmResendPrizes(onResendConfirmed: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "Отправить награды повторно?",
            message: "На указанный Вами адрес электронной почты будут повторно отправлены все полученные Вами награды.",
            preferredStyle: .alert)
        let resendAction = UIAlertAction(title: "Отправить", style: .default) { _ in
            onResendConfirmed()
        }
        alert.addAction(resendAction)
        alert.addAction(.cancelAction)
        return alert
    }
}

extension UIAlertAction {
    
    public static var okAction: UIAlertAction {
        UIAlertAction(title: "ОК", style: .default)
    }
    
    public static var cancelAction: UIAlertAction {
        UIAlertAction(title: "Отменить", style: .cancel)
    }
}
