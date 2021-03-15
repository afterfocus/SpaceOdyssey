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
    
    private static func confirmAlert(title: String,
                                     message: String,
                                     confirmButtonTitle: String,
                                     onConfirm: @escaping () -> Void,
                                     onCancel: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmButtonTitle, style: .default) { _ in
            onConfirm()
        }
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel) { _ in
            if let closure = onCancel {
                closure()
            }
        }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
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
    
    public static var locationAuthorizationDeniedAlert: UIAlertController {
        return okAlert(
            title: "Доступ к геолокации запрещен",
            message: "Для отображения геопозиции и построения маршрутов до локаций необходимо разрешить приложению доступ к геолокации в настройках устройства.\nДля отключения следования по маршруту активируйте режим «‎На диване» во вкладке «‎Профиль».")
    }
    
    public static var cannotSendEmailAlert: UIAlertController {
        return okAlert(
            title: "Отправка E-mail недоступа",
            message: "Отправка E-mail невозможна в связи с настройками Вашего устройства.")
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

    public static var tooFarFromLocationAlert: UIAlertController {
        return okAlert(
            title: "Ошибка построения маршрута",
            message: "Не удалось построить пешеходный маршрут, так как Вы находитесь слишком далеко от нужной локации.\nДля пользователей из других городов рекомендуется включить режим «‎На диване» в разделе «‎Профиль».")
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
        return confirmAlert(
            title: "Использовать подсказку",
            message: "\nИспользовать одну из оставшихся подсказок, чтобы открыть первую и последнюю буквы?\n\nОставшихся подсказок: \(remainingHints)",
            confirmButtonTitle: "Использовать",
            onConfirm: onHintUse)
    }
    
    public static func confirmExitAlert(onExitConfirmed: @escaping () -> Void) -> UIAlertController {
        return confirmAlert(
            title: "Вы действительно хотите выйти?",
            message: "Весь прогресс пользователя будет сохранен и восстановлен при следующем входе.",
            confirmButtonTitle: "Выход",
            onConfirm: onExitConfirmed)
    }
    
    public static func confirmResendPrizes(onResendConfirmed: @escaping () -> Void) -> UIAlertController {
        return confirmAlert(
            title: "Отправить награды повторно?",
            message: "На указанный Вами адрес электронной почты будут повторно отправлены все полученные Вами награды.",
            confirmButtonTitle: "Отправить",
            onConfirm: onResendConfirmed)
    }
    
    public static func confirmDisableRouting(onDisablingConfirmed: @escaping () -> Void,
                                             onCancel: @escaping () -> Void) -> UIAlertController {
        return confirmAlert(
            title: "Включить режим «‎На диване»?",
            message: "При включенном режиме «‎На диване» не требуется посещения локаций для ответа на вопрос. Вы сможете пройти весь квест не выходя из дома, однако полный набор наград доступен только при посещении локаций.",
            confirmButtonTitle: "Включить",
            onConfirm: onDisablingConfirmed,
            onCancel: onCancel)
    }
    
    public static func confirmEnableRouting(onDisablingConfirmed: @escaping () -> Void,
                                            onCancel: @escaping () -> Void) -> UIAlertController {
        return confirmAlert(
            title: "Отключить режим «‎На диване»?",
            message: "В режиме следования по маршруту для активации вопросов необходимо посещать локации, отмеченные на карте. В этом режиме Вы сможете получить полный набор наград за прохождение маршрутов, а так же открыть для себя новые интересные места города.",
            confirmButtonTitle: "В путь!",
            onConfirm: onDisablingConfirmed,
            onCancel: onCancel)
    }
}

extension UIAlertAction {
    
    public static var okAction: UIAlertAction {
        UIAlertAction(title: "ОК", style: .default)
    }
}
