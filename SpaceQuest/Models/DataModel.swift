//
//  DataProvider.swift
//  SpaceQuest
//
//  Created by Максим Голов on 20.11.2020.
//

import Foundation
import YandexMapsMobile

// MARK: - Data To Save

struct DataToSave: Codable {
    var isRouteFirstTimeLaunched: Bool
    var isMapNightModeEnabled: Bool
    var isRoutingDisabled: Bool
    var shouldSendRegistrationPrizes: Bool
    var routesData: [[QuestionData]]
}

// MARK: - Data Model

final class DataModel {

    // MARK: - Properties
    
    private(set) var userName: String
    private(set) var email: String
    var isRouteFirstTimeLaunched = true
    var isMapNightModeEnabled = true
    var isRoutingDisabled = false
    var shouldSendRegistrationPrizes = false
    
    // MARK: - Init
    
    private init(userName: String, email: String) {
        self.userName = userName
        self.email = email
        
        /// Проверить существует ли файл.
        if (try? dataFilePath().checkResourceIsReachable()) ?? false {
            loadFromFile()
            shouldSendRegistrationPrizes = false
        } else {
            clearUserProgress()
            shouldSendRegistrationPrizes = true
        }
    }
    
    /// Сменить имя пользователя и/или e-mail
    /// Возвращает false, если файл с таким именем уже существует
    func editUser(newName: String, newEmail: String) -> Bool {
        let newFilePath = dataFilePath(for: "\(newName) - \(newEmail).plist")
        do {
            if (try? newFilePath.checkResourceIsReachable()) ?? false {
                return false
            }
            try FileManager.default.moveItem(at: dataFilePath(), to: newFilePath)
            userName = newName
            email = newEmail
            DataModel.loggedInUser = (newName, newEmail)
            return true
        } catch {
            return false
        }
    }
    
    /// Сохранить настройки и прогресс пользователя в файл
    func saveToFile() {
        do {
            let data = try PropertyListEncoder().encode(dataToSave)
            try data.write(to: dataFilePath(), options: .atomic)
        } catch {
            print("DATA SAVING ERROR: \(error.localizedDescription)")
        }
    }
    
    /// Загрузить настройки и прогресс пользователя из файла
    func loadFromFile() {
        guard let data = try? Data(contentsOf: dataFilePath()) else { return }
        do {
            let savedData = try PropertyListDecoder().decode(DataToSave.self, from: data)
            unpackSavedData(savedData)
        } catch {
            print("DATA LOADING ERROR: \(error.localizedDescription)")
        }
    }
    
    /// Отправить призы за регистрацию
    func sendRegistrationPrize(completion: @escaping (_ statusCode: Int?) -> Void) {
        var urlComponents = URLComponents(string: "https://odysseymars.com/api/v0/sendemail")!
        urlComponents.queryItems = postServiceQueryItems + [URLQueryItem(name: "prize", value: "registration")]
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"

        let dataTask = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            let response = response as? HTTPURLResponse
            DispatchQueue.main.async {
                completion(response?.statusCode)
            }
        }
        dataTask.resume()
    }
    
    /// Отправить призы за маршрут
    func sendRoutePrize(route: Route, completion: ((_ statusCode: Int?) -> Void)? = nil) {
        var urlComponents = URLComponents(string: "https://odysseymars.com/api/v0/sendemail")!
        urlComponents.queryItems = postServiceQueryItems + [
            URLQueryItem(name: "route", value: route.id),
            URLQueryItem(name: "prize", value: route.isMoreThanHalfVisited ? "walk" : "sofa"),
            URLQueryItem(name: "distance", value: "\(Double(route.distancePassed) / 1000)"),
            URLQueryItem(name: "ccal", value: "\(route.caloriesBurned)"),
            URLQueryItem(name: "score", value: "\(route.score)")
        ]
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"

        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let response = response as? HTTPURLResponse
            DispatchQueue.main.async {
                completion?(response?.statusCode)
            }
        }
        dataTask.resume()
    }
    
    // MARK: - Private Functions
    
    /// Имя файла с данными для текущего вользователя
    private var filename: String {
        "\(userName) - \(email).plist"
    }
    
    private var postServiceQueryItems: [URLQueryItem] {
        [URLQueryItem(name: "key", value: DataModel.postServerApiKey),
         URLQueryItem(name: "email", value: email),
         URLQueryItem(name: "name", value: userName)]
    }
    
    /// Подготовить данные для сохранения
    private var dataToSave: DataToSave {
        let routesData = DataModel.routes.map { $0.dataToSave() }
        return DataToSave(isRouteFirstTimeLaunched: isRouteFirstTimeLaunched,
                          isMapNightModeEnabled: isMapNightModeEnabled,
                          isRoutingDisabled: isRoutingDisabled,
                          shouldSendRegistrationPrizes: shouldSendRegistrationPrizes,
                          routesData: routesData)
    }
    
    /// Полный путь к файлу
    private func dataFilePath(for filename: String? = nil) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(filename ?? self.filename)
    }
    
    /// Распаковать сохраненные данные
    private func unpackSavedData(_ data: DataToSave) {
        isRouteFirstTimeLaunched = data.isRouteFirstTimeLaunched
        isMapNightModeEnabled = data.isMapNightModeEnabled
        isRoutingDisabled = data.isRoutingDisabled
        shouldSendRegistrationPrizes = data.shouldSendRegistrationPrizes
        
        for (routeIndex, questionsData) in data.routesData.enumerated() {
            for (questionIndex, questionData) in questionsData.enumerated() {
                let question = DataModel.routes[routeIndex][questionIndex]
                question.isComplete = questionData.isComplete
                question.score = questionData.score
                question.usedHints = questionData.usedHints
                question.location.isVisited = questionData.isVisited
            }
        }
    }
    
    /// Обнулить прогресс
    private func clearUserProgress() {
        for route in DataModel.routes {
            for question in route.questions {
                question.isComplete = false
                question.score = 0
                question.usedHints = 0
                question.location.isVisited = false
            }
        }
    }
}
    

// MARK: Static
    
extension DataModel {
    
    /// Синглтон. Доступен только после авторизации пользователя.
    static var current: DataModel!
    
    static var isLoggedIn: Bool {
        get { userDefaults.bool(forKey: "IsLoggedIn") }
        set { userDefaults.setValue(newValue, forKey: "IsLoggedIn") }
    }
    
    /// Текущий авторизованный пользователь
    static var loggedInUser: (name: String, email: String) {
        get {
            return (name: userDefaults.string(forKey: "UserName") ?? "Undefined",
                    email: userDefaults.string(forKey: "UserEmail") ?? "Undefined")
        }
        set {
            userDefaults.setValue(newValue.name, forKey: "UserName")
            userDefaults.setValue(newValue.email, forKey: "UserEmail")
        }
    }
    
    static var postServerApiKey: String {
        return "ZfMtsgkd$2RpkWWx"
    }
    
    static func setYandexMapsAPIKey() {
        YMKMapKit.setApiKey("7ab269af-7c79-4c99-bb21-9afad48c1db9")
    }
    
    static func logIn(userName: String, email: String) {
        current = DataModel(userName: userName, email: email)
        DataModel.isLoggedIn = true
        DataModel.loggedInUser = (userName, email)
    }
    
    static func logIn() {
        current = DataModel(userName: loggedInUser.name, email: loggedInUser.email)
    }
    
    /// Срахнить данные и выйти
    static func logOut() {
        current.saveToFile()
        DataModel.isLoggedIn = false
        DataModel.loggedInUser = ("Undefined", "Undefined")
    }
    
    private static var userDefaults: UserDefaults {
        return UserDefaults.standard
    }
    
    
    // MARK: - Authors
    
    static let leonov = Author(
        surname: "Леонов",
        name: "Алексей",
        patronymic: "Архипович\n1934 – 2019",
        aboutAuthor: "",
        aboutAuthorFull: "Дважды Герой Советского Союза,\nЛётчик-космонавт СССР №11,\nГенерал-майор авиации, к.т.н.,\nПервый человек, вышедший в открытый космос, участник первого международного космического полёта «Союз-Аполлон»",
        photoFilename: "Леонов")
    
    static let tkachenko = Author(
        surname: "Ткаченко",
        name: "Сергей",
        patronymic: "Иванович\n1950 – 2017",
        aboutAuthor: "",
        aboutAuthorFull: "Профессор кафедры космического машиностроения Самарского университета, д.т.н., заместитель Генерального конструктора по научной работе АО «РКЦ «Прогресс», главный конструктор серии малых космических аппаратов «АИСТ»",
        photoFilename: "Ткаченко")
    
    static let authors: [String: Author] = [
        "Артемьев": Author(surname: "Артемьев",
                           name: "Олег",
                           patronymic: "Германович",
                           aboutAuthor: "Герой РФ\nЛётчик-космонавт",
                           aboutAuthorFull: "Герой Российской Федерации,\nЛётчик-космонавт РФ, к.э.н.,\nКосмонавт 118/534 (России/мира),\n2 полёта – 365 сут. 23 час. 5 мин.,\n3 выхода в открытый космос – 20 час. 20 мин.",
                           photoFilename: "Артемьев"),
        "Авдеев": Author(surname: "Авдеев",
                         name: "Сергей",
                         patronymic: "Васильевич",
                         aboutAuthor: "Герой РФ\nЛетчик-космонавт",
                         aboutAuthorFull: "Герой Российской Федерации,\nЛётчик-космонавт РФ, к.ф.-м.н.,\nКосмонавт 74/277 (России/мира),\n3 полёта – 747 сут. 14 час. 14 мин.,\n10 выходов в открытый космос – 41 час. 59 мин.",
                         photoFilename: "Авдеев"),
        "Бабкин": Author(surname: "Бабкин",
                         name: "Андрей",
                         patronymic: "Николаевич",
                         aboutAuthor: "Космонавт-испытатель Роскосмоса",
                         aboutAuthorFull: "Космонавт-испытатель отряда космонавтов Роскосмоса, к.т.н.,\nВедущий научный сотрудник РКК «Энергия»",
                         photoFilename: "Бабкин"),
        "Баранов": Author(surname: "Баранов",
                          name: "Дмитрий",
                          patronymic: "Александрович",
                          aboutAuthor: "Генеральный директор\nАО «РКЦ «Прогресс»",
                          aboutAuthorFull: "Заслуженный конструктор Российской Федерации, к.т.н.,\nГенеральный директор АО «РКЦ «Прогресс»",
                          photoFilename: "Баранов"),
        "Виноградов": Author(surname: "Виноградов",
                             name: "Павел",
                             patronymic: "Владимирович",
                             aboutAuthor: "Герой РФ\nЛётчик-космонавт",
                             aboutAuthorFull: "Герой Российской Федерации,\nЛётчик-космонавт РФ,\nКосмонавт 87/363 (России/мира),\n3 полёта – 546 сут. 22 час. 33 мин.,\n7 выходов в открытый космос – 38 час. 27 мин.",
                             photoFilename: "Виноградов"),
        "Котельников": Author(surname: "Котельников",
                              name: "Геннадий",
                              patronymic: "Петрович",
                              aboutAuthor: "Академик РАН, председатель Самарской Думы",
                              aboutAuthorFull: "Академик РАН, заслуженный деятель науки Российской Федерации,\nПредседатель Самарской губернской Думы,\nПрезидент Самарского государственного медицинского университета,\nПредседатель Совета ректоров Самарской области, заведующий кафедрой травматологии, ортопедии и экстремальной хирургии",
                              photoFilename: "Котельников"),
        "Котов": Author(surname: "Котов",
                        name: "Олег",
                        patronymic: "Валерьевич",
                        aboutAuthor: "Герой РФ\nЛётчик-космонавт",
                        aboutAuthorFull: "Герой Российской Федерации,\nЛётчик-космонавт РФ,\nКосмонавт 100/452 (России/мира),\n3 полёта – 526 сут. 6 час. 2 мин.,\n3 выхода в открытый космос – 37 час. 19 мин.",
                        photoFilename: "Котов"),
        "Кикина": Author(surname: "Кикина",
                         name: "Анна",
                         patronymic: "Юрьевна",
                         aboutAuthor: "Космонавт-испытатель Роскосмоса",
                         aboutAuthorFull: "Космонавт-испытатель отряда космонавтов Роскосмоса,\nМастер спорта по полиатлону (многоборье) и рафтингу",
                         photoFilename: "Кикина"),
        "Корзун": Author(surname: "Корзун",
                         name: "Валерий",
                         patronymic: "Григорьевич",
                         aboutAuthor: "Герой РФ\nЛётчик-космонавт",
                         aboutAuthorFull: "Герой Российской Федерации,\nЛётчик-космонавт РФ,\nКосмонавт 85/351 (России/мира),\n2 полёта – 381 сут. 15 час. 41 мин.,\n4 выхода в открытый космос – 22 час. 20 мин.",
                         photoFilename: "Корзун"),
        "Корниенко": Author(surname: "Корниенко",
                            name: "Михаил",
                            patronymic: "Борисович",
                            aboutAuthor: "Герой РФ\nЛётчик-космонавт",
                            aboutAuthorFull: "Герой Российской Федерации,\nЛётчик-космонавт РФ,\nКосмонавт 106/511 (России/мира),\n2 полёта – 516 сут. 10 час. 43 мин.,\nУчастник годовой экспедиции,\n2 выхода в открытый космос – 12 час. 17 мин.",
                            photoFilename: "Корниенко"),
        "Королёв": Author(surname: "Королёв",
                          name: "Андрей",
                          patronymic: "Вадимович",
                          aboutAuthor: "Внук С.П. Королёва",
                          aboutAuthorFull: "Внук советского учёного, конструктора С.П. Королёва, д.м.н., профессор,\nхирург-ортопед-травматолог, профессор Российского университета дружбы народов, главный врач и директор Европейской клиники спортивной травматологии и ортопедии ECSTO",
                          photoFilename: "Королев"),
        "Королёва": Author(surname: "Королёва",
                           name: "Наталия",
                           patronymic: "Сергеевна",
                           aboutAuthor: "Дочь С.П. Королёва",
                           aboutAuthorFull: "Дочь советского учёного, конструктора\nС.П. Королёва, д.м.н.,\nпрофессор кафедры госпитальной хирургии\n1-го МГМУ имени И. М. Сеченова,\nЛауреат Государственной премии, автор книг",
                           photoFilename: "Королева"),
        "Лазаренко": Author(surname: "Лазаренко",
                            name: "Александр",
                            patronymic: "Юрьевич",
                            aboutAuthor: "Ветеран поисково-спасательного отдела",
                            aboutAuthorFull: "Ветеран поисково-спасательного отдела космонавтов",
                            photoFilename: "Лазаренко"),
        "Лазуткин": Author(surname: "Лазуткин",
                           name: "Александр",
                           patronymic: "Иванович",
                           aboutAuthor: "Герой РФ\nЛётчик-космонавт",
                           aboutAuthorFull: "Герой Российской Федерации,\nЛётчик-космонавт РФ,\nКосмонавт 86/356 (России/мира),\n1 полёт – 184 сут. 22 час. 7 мин.",
                           photoFilename: "Лазуткин"),
        "Прокопьев": Author(surname: "Прокопьев",
                            name: "Сергей",
                            patronymic: "Валерьевич",
                            aboutAuthor: "Герой РФ\nЛётчик-космонавт",
                            aboutAuthorFull: "Герой Российской Федерации,\nЛётчик-космонавт РФ\nКосмонавт 122/554 (России/мира),\n1 полёта – 196 сут. 17 час. 49 мин.,\n2 выхода в открытый космос – 15 час. 31 мин.",
                            photoFilename: "Прокопьев"),
        "Просочкина": Author(surname: "Просочкина",
                             name: "Анастасия",
                             patronymic: "",
                             aboutAuthor: "Художник, иллюстратор и дизайнер An.Pro ART",
                             aboutAuthorFull: "Художник, иллюстратор и дизайнер An.Pro ART\nАвтор космического арт-календаря",
                             photoFilename: "Просочкина"),
        "Рень": Author(surname: "Рень",
                       name: "Виктор",
                       patronymic: "Алексеевич",
                       aboutAuthor: "Герой РФ\nИнструктор-испытатель",
                       aboutAuthorFull: "Герой Российской Федерации, полковник,\nИнструктор-испытатель авиационно-космической техники,\nСвыше 900 полётов в воздушной лаборатории для проверки влияния перегрузок и невесомости на человека,\nСвыше 2000 парашютных прыжков,\nБолее 400 часов работы под водой в скафандрах",
                       photoFilename: "Рень"),
        "Сердюк": Author(surname: "Сердюк",
                         name: "Александр",
                         patronymic: "Владимирович",
                         aboutAuthor: "Старший преподаватель по физподготовке ЦПК",
                         aboutAuthorFull: "Старший тренер-преподаватель по физической подготовке Центра подготовки космонавтов имени Ю. А. Гагарина",
                         photoFilename: "Сердюк"),
        "Сойфер": Author(surname: "Сойфер",
                         name: "Виктор",
                         patronymic: "Александрович",
                         aboutAuthor: "Академик РАН",
                         aboutAuthorFull: "Академик РАН, заслуженный деятель науки Российской Федерации,\nПрезидент Самарского университета",
                         photoFilename: "Соифер"),
        "Степанова": Author(surname: "Степанова",
                                     name: "Анастасия",
                                     patronymic: "Александровна",
                                     aboutAuthor: "Участник «Марc 160»\nИспытатель-исследователь",
                                     aboutAuthorFull: "Ведущий инженер Института медико-биологических проблем РАН,\nУчастница международного проекта Марс 160,\n Испытатель-исследователь экипажа изоляционного имитационного полета к Луне «SIRIUS-19»,\nКосмический журналист, волонтер-спасатель отряда Спасрезерв",
                                     photoFilename: "Степанова"),
        "Титов": Author(surname: "Титов",
                             name: "Владимир",
                             patronymic: "Георгиевич",
                             aboutAuthor: "Герой СССР\nЛётчик-космонавт",
                             aboutAuthorFull: "Герой Советского Союза,\nЛётчик-космонавт СССР,\n  Космонавт 54/118 (России/мира),\n4 полёта – 387 сут. 00 час. 45 мин.,\n4 выхода в открытый космос – 18 час. 48 мин.",
                             photoFilename: "Титов"),
        "Тихонов": Author(surname: "Тихонов",
                                 name: "Николай",
                                 patronymic: "Владимирович",
                                 aboutAuthor: "Космонавт-испытатель Роскосмоса",
                                 aboutAuthorFull: "Космонавт-испытатель отряда космонавтов Роскосмоса,\nИнженер РКК «Энергия»",
                                 photoFilename: "Тихонов"),
        "Федяев": Author(surname: "Федяев",
                               name: "Андрей",
                               patronymic: "Валерьевич",
                               aboutAuthor: "Космонавт-испытатель Роскосмоса",
                               aboutAuthorFull: "Космонавт-испытатель отряда космонавтов Роскосмоса,\nВоенный летчик 2-го класса",
                               photoFilename: "Федяев"),
        "Филатова": Author(surname: "Филатова",
                                   name: "Тамара",
                                   patronymic: "Дмитриевна",
                                   aboutAuthor: "Племянница Ю.А. Гагарина",
                                   aboutAuthorFull: "Племянница первого космонавта Ю.А. Гагарина,\nЗаведующая мемориальным отделом Объединенного мемориального музея Ю.А. Гагарина (г. Гагарин)",
                                   photoFilename: "Филатова"),
        "Черкасов": Author(surname: "Черкасов",
                                   name: "Андрей",
                                   patronymic: "Николаевич",
                                   aboutAuthor: "Инженер-испытатель\nНПП «Звезда»",
                                   aboutAuthorFull: "Инженер-испытатель АО «НПП «Звезда»",
                                   photoFilename: "Черкасов"),
        "Юрченко": Author(surname: "Юрченко",
                                 name: "Екатерина",
                                 patronymic: "Сергеевна",
                                 aboutAuthor: "Инструктор по исследованию Земли из космоса",
                                 aboutAuthorFull: "Инструктор по подготовке к экспериментам по исследованию Земли из космоса Центра подготовки космонавтов имени Ю. А. Гагарина",
                                 photoFilename: "Юрченко"),
        "Шкаплеров": Author(surname: "Шкаплеров",
                                     name: "Антон",
                                     patronymic: "Николаевич",
                                     aboutAuthor: "Герой РФ\nЛётчик-космонавт",
                                     aboutAuthorFull: "Герой Российской Федерации,\nЛётчик-космонавт РФ,\nКосмонавт 111/521 (России/мира),\n3 полёта – 533 сут. 05 час. 31 мин.,\n2 выхода в открытый космос – 14 час. 28 мин.",
                                     photoFilename: "Шкаплеров")
    ]
    
    // MARK: - Routes
    
    // MARK: - Космическая столица России
    static var routes = [
        Route(id: "spacecapital",
              imageFileName: "background1.png",
              title: "Космическая столица России",
              subtitle: "Историческая часть города",
              questions: [
                Question(
                    title: "Перед стартом",
                    location: Location(name: "МВЦ «Самара Космическая»",
                                       address: "Проспект Ленина 21",
                                       latitude: 53.212677,
                                       longitude: 50.145232,
                                       photoFilename: "МВЦ Самара Космическая",
                                       activationRadius: 100,
                                       distance: 0),
                    author: authors["Корзун"]!,
                    questionText: "Посмотрите внимательно на ракету. Так она выглядит за 2,5 часа до старта. Назовите настоящий цвет ракеты «Союз» до того, как она становится белой.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/33hnI0SLtnw?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/9nKjkbawOEI?playsinline=1"),
                    answer: ["СЕРЫЙ"],
                    answerCharacters: "СРЧРЕБИЫЕНИЛСЙ"),
                
                Question(
                    title: "Великолепная шестёрка",
                    location: Location(name: "Памятник Д.И.Козлову",
                                       address: "Проспект Ленина 1",
                                       latitude: 53.212891,
                                       longitude: 50.145006,
                                       photoFilename: "Памятник Козлову",
                                       distance: 50),
                    author: authors["Баранов"]!,
                    questionText: "В 1946 году перед ведущими конструкторами СССР ставилась единая цель – создание баллистических, а затем и космических ракет. Для управления этой системой был создан координационный орган, который хоть и имел совещательно-консультативные функции, однако его члены обладали необходимыми полномочиями для формирования направления развития советской ракетно-космической программы и смежных исследований. Назовите название этого совещательного органа.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/TIvJebiqV9o?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/R50m7lnY5AM?playsinline=1"),
                    answer: ["СОВЕТ", "ГЛАВНЫХ"],
                    answerCharacters: "СТСВГЛХЫВЕОАЮНОЗ"),
                
                Question(
                    title: "Дом-рекордсмен",
                    location: Location(name: "Сквер им. В.И.Фадеева",
                                       address: "Проспект Ленина 1",
                                       latitude: 53.205863,
                                       longitude: 50.133248,
                                       photoFilename: "Сквер Фадеева",
                                       activationRadius: 150,
                                       distance: 1200),
                    author: authors["Авдеев"]!,
                    questionText: "Дмитрий Ильич Козлов всю жизнь защищал Родину, причем в молодости ему пришлось делать это собственной кровью. 1 июля 1941 года студент пятого курса института Дмитрий Козлов добровольцем записался в народное ополчение, прошел всю Великую Отечественную войну, был трижды ранен и потерял руку. Получил несколько боевых наград. Медалью за оборону какого города был награжден Козлов?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/iVOB-crqAmQ?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/UU4D150Q6pQ?playsinline=1"),
                    answer: ["ЛЕНИНГРАД"],
                    answerCharacters: "ЛРСАНДЕРТНГМАИАСА"),
                
                Question(
                    title: "Семейные узы",
                    location: Location(name: "Дворец бракосочетания",
                                       address: "Молодогвардейская 238",
                                       latitude: 53.207815,
                                       longitude: 50.121862,
                                       photoFilename: "Дворец бракосочетания",
                                       activationRadius: 70,
                                       distance: 1300),
                    author: authors["Черкасов"]!,
                    questionText: "В истории отечественной космонавтики есть потомственные космонавты, когда дети осознанно выбирают путь своих отцов и становятся достойными их продолжателями в профессии космонавта. Назовите фамилии двух основателей космических династий.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/aCGk9x3gKEQ?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/XgjiacSNFk8?playsinline=1"),
                    answer: ["ВОЛКОВ", "РОМАНЕНКО"],
                    answerCharacters: "ВЛАОКОКВГАЕНОРНРАОМИН"),
                
                Question(
                    title: "К звёздам",
                    location: Location(name: "Скульптура «Первый спутник»",
                                       address: "Волжский проспект 36",
                                       latitude: 53.208451,
                                       longitude: 50.114155,
                                       photoFilename: "Скульптура Первыи Спутник",
                                       distance: 800),
                    author: authors["Шкаплеров"]!,
                    questionText: "Сегодня самарский РКЦ «Прогресс» - единственное в мире предприятие, осуществляющее пуски ракет-носителей с четырех площадок. Перечислите названия этих космодромов в алфавитном порядке.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/K7OAFKBM3ho?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/eWtvOw_tK4k?playsinline=1"),
                    answer: ["БАЙКОНУР", "ВОСТОЧНЫЙ", "КУРУ", "ПЛЕСЕЦК"],
                    answerCharacters: "БНЕУВАЫПНУЙСРКЕЛРЙСОКОТЦОЧКУ"),
                
                Question(
                    title: "Покорившая небо",
                    location: Location(name: "Спортивный комплекс ЦСКА ВВС",
                                       address: "Волжский проспект 10",
                                       latitude: 53.204991,
                                       longitude: 50.106830,
                                       photoFilename: "Спортивныи комплекс ЦСКА ВВС",
                                       activationRadius: 75,
                                       distance: 600),
                    author: authors["Кикина"]!,
                    questionText: "Один из основных факторов космического полёта — элемент риска и опасности, заставляющий быть готовым быстро принимать правильные решения, — моделирует специальная парашютная подготовка. У истоков парашютной подготовки космонавтов стояла ЭТА удивительная хрупкая женщина. К моменту зачисления в отряд космонавтов она уже выполнила около 700 прыжков. А общее число прыжков — около 2500. Кроме того она является полковником ВВС в отставке, дублёром Валентины Терешковой. Назовите фамилию этой женщины.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/xRIKovb9Eh4?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/UxBcOgDIg58?playsinline=1"),
                    answer: ["СОЛОВЬЁВА"],
                    answerCharacters: "СВЬАЛКГЁОГРРВОАИОАН"),
                
                Question(
                    title: "Родной край",
                    location: Location(name: "Монумент «Гордость, честь и слава»",
                                       address: "Площадь Славы, лестница",
                                       latitude: 53.204076,
                                       longitude: 50.109611,
                                       photoFilename: "Монумент Гордость, Честь и Слава",
                                       distance: 300),
                    author: authors["Корниенко"]!,
                    questionText: "Четыре космонавта родились в Самарской области. Назовите их фамилии в алфавитном порядке.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/yxZzwP_OYCc?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/JWYIcLjgWWw?playsinline=1"),
                    answer: ["АВДЕЕВ", "АТЬКОВ", "ГУБАРЕВ", "КОРНИЕНКО"],
                    answerCharacters: "КАЕКНУАЕРИТЕНОБОВРВАДГЕВКОЬВ"),
                
                Question(
                    title: "Счёт на секунды",
                    location: Location(name: "Монумент Славы",
                                       address: "Площадь Славы",
                                       latitude: 53.203791,
                                       longitude: 50.109941,
                                       photoFilename: "Монумент Славы",
                                       distance: 50),
                    author: authors["Титов"]!,
                    questionText: "Назовите фамилию руководителя стартовой команды корабля «Союз-Т-10-1» – Героя Социалистического Труда, заместителя генерального конструктора «ЦСКБ-Прогресс».",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/vulFYcCDSr0?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/2O7px0BRJWQ?playsinline=1"),
                    answer: ["СОЛДАТЕНКОВ"],
                    answerCharacters: "СЁНТОВАЕЛДКОРК"),
                
                Question(
                    title: "На удачу",
                    location: Location(name: "Мемориальная доска\nА.М. Солдатенкову",
                                       address: "Молодогвардейская 218",
                                       latitude: 53.203951,
                                       longitude: 50.113508,
                                       photoFilename: "Мемориальная доска Солдатенкову",
                                       distance: 350),
                    author: authors["Лазаренко"]!,
                    questionText: "У Сергея Павловича Королева был любимый головной убор, который он всегда носил с осени и до ранней весны. Сергей Павлович был также весьма суеверным человеком, и этот предмет непременно был на нем во время каждого старта. О каком головном уборе идет речь?",
                    questionVideoUrl: nil,
                    answerVideoUrl: nil,
                    answer: ["ШЛЯПА"],
                    answerCharacters: "ШСРАЕЗКПКЕПЯКОКЫБЛАРА"),
                
                Question(
                    title: "Заключённый",
                    location: Location(name: "Памятник Д.Ф. Устинову",
                                       address: "Самарская площадь",
                                       latitude: 53.200971,
                                       longitude: 50.112744,
                                       photoFilename: "Памятник Устинову",
                                       activationRadius: 65,
                                       distance: 450),
                    author: authors["Артемьев"]!,
                    questionText: "В 1944 г. отечественные инженеры впервые получили возможность ознакомиться с немецкой ракетной техникой: в их распоряжение попали элементы конструкции ракеты А-4. Назовите общеизвестное название этой ракеты.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/CHzZXM1yMms?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/LPd9HiORRQw?playsinline=1"),
                    answer: ["ФАУ-2"],
                    answerCharacters: "ФОНРИДУАСК1234"),
                
                Question(
                    title: "Вечный двигатель",
                    location: Location(name: "1 корпус Самарского университета",
                                       address: "Молодогвардейская 151",
                                       latitude: 53.201156,
                                       longitude: 50.108302,
                                       photoFilename: "1 корпус Самарского университета",
                                       activationRadius: 45,
                                       distance: 450),
                    author: authors["Сойфер"]!,
                    questionText: "Сколько маршевых двигателей у ракеты-носителя Союз-2, предназначенных для вывода кораблей Союз-МС?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/XNvl2r3nJHY?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/assyWByROes?playsinline=1"),
                    answer: ["6"],
                    answerCharacters: "0123456"),
                
                Question(
                    title: "Музыкальная пауза",
                    location: Location(name: "Памятник Дмитрию Шостаковичу",
                                       address: "Площадь Куйбышева, Галактионовская",
                                       latitude: 53.193476,
                                       longitude: 50.102042,
                                       photoFilename: "Памятник Дмитрию Шостаковичу",
                                       distance: 1000),
                    author: authors["Филатова"]!,
                    questionText: "Песня, написанная Дмитрием Шостаковичем на слова Евгения Долматовского в 1950 году, неразрывно связана с началом космической эры. Первоначально она создавалась как «песня-позывной» для лётчика. Стала известна в исполнении солиста и хора, ещё большую популярность песня получила после того, как её спел Юрий Алексеевич Гагарин в первом космическом полёте. Назовите название этой песни.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/Meilc24vjuM?playsinline=1"),
                    answerVideoUrl: nil,
                    answer: ["РОДИНА", "СЛЫШИТ"],
                    answerCharacters: "РАВЫОТЛЗНЁСИДИШОТ"),
                
                Question(
                    title: "Железный конь",
                    location: Location(name: "Бункер Сталина",
                                       address: "Фрунзе 167",
                                       latitude: 53.196744,
                                       longitude: 50.098099,
                                       photoFilename: "Бункер Сталина",
                                       activationRadius: 45,
                                       distance: 800),
                    author: authors["Бабкин"]!,
                    questionText: "История РКЦ «Прогресс» началась в Москве в 1894 году, когда обрусевший немец Ю. Меллер основал небольшую мастерскую по ремонту популярного в то время вида транспорта. О каком транспортом средстве идет речь?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/pqXqCznx6FU?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/nJ5PIYGle4w?playsinline=1"),
                    answer: ["ВЕЛОСИПЕД"],
                    answerCharacters: "ВАЕСЕЛДОМКАПИТ"),
                
                Question(
                    title: "Разведка",
                    location: Location(name: "Мемориальная доска «Кембриджской пятерке»",
                                       address: "Фрунзе 179",
                                       latitude: 53.197983,
                                       longitude: 50.098590,
                                       photoFilename: "Мемориальная доска Кембриджскои пятерке",
                                       distance: 150),
                    author: authors["Королёва"]!,
                    questionText: "Когда и каким космическим аппаратом была сфотографирована обратная сторона Луны?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/aOMuZ2cWb8M?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/s3JETFgFLY0?playsinline=1"),
                    answer: ["04.10.1959", "ЛУНА-3"],
                    answerCharacters: "ЛНМРАУС310450919"),
                
                Question(
                    title: "Космическая физика",
                    location: Location(name: "Композиция «Дама с ракеткой»",
                                       address: "Пушкинский сквер",
                                       latitude: 53.198556,
                                       longitude: 50.097990,
                                       photoFilename: "Композиция Дама с ракеткои",
                                       distance: 130),
                    author: authors["Прокопьев"]!,
                    questionText: "В классической механике существует теорема теннисной ракетки о неустойчивости вращения твёрдого тела относительно второй главной оси инерции. Проявление этой теоремы в невесомости названо в честь советского космонавта, который заметил это явление 25 июня 1985 года, находясь на борту космической станции «Салют-7». Назовите фамилию этого космонавта.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/g2kjgqjdGwg?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/as-ln4yFwUo?playsinline=1"),
                    answer: ["ДЖАНИБЕКОВ"],
                    answerCharacters: "ДБЖЕЕКНОБЗВАИЕ"),
                
                Question(
                    title: "Про любовь",
                    location: Location(name: "Памятник товарищу Сухову",
                                       address: "Максима Горького 115",
                                       latitude: 53.190846,
                                       longitude: 50.083693,
                                       photoFilename: "Памятник Сухову",
                                       distance: 1500),
                    author: authors["Котов"]!,
                    questionText: "Памятник товарищу Сухову посвящён главному персонажу фильма, которого блестяще сыграл актёр Анатолий Борисович Кузнецов. Этот памятник расположен здесь не случайно. Ведь именно в Самару писал свои трогательные письма красноармеец Сухов. Назовите имя «единственной и незабвенной» Фёдора Ивановича.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/eEPryrDe9Jw?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/N-uvsQSjs7c?playsinline=1"),
                    answer: ["КАТЕРИНА"],
                    answerCharacters: "КАТЕНАРЕНИАЛЯН"),
                
                Question(
                    title: "Астрокошка",
                    location: Location(name: "Фонтан «Парус»",
                                       address: "М. Горького 107",
                                       latitude: 53.189641,
                                       longitude: 50.082413,
                                       photoFilename: "Фонтан Парус",
                                       distance: 100),
                    author: authors["Котельников"]!,
                    questionText: "В космос успешно запускали не только собак, но и наиболее близких человеку по физиологии обезьян. А вот судьба кошек-космонавтов, к сожалению, не сложилась. На данный момент достоверно подтверждён полет в космос единственного представителя вида. Назовите имя этой астрокошки.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/uXlN_zx5Gkw?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/1ar5imu87vI?playsinline=1"),
                    answer: ["ФЕЛИСЕТТ"],
                    answerCharacters: "ФЕКТМАИЕРУЛСТА"),
                
                Question(
                    title: "Космический художник",
                    location: Location(name: "Композиция «Бурлаки на Волге»",
                                       address: "М. Горького 107",
                                       latitude: 53.189791,
                                       longitude: 50.082047,
                                       photoFilename: "Бурлаки на Волге",
                                       distance: 50),
                    author: authors["Просочкина"]!,
                    questionText: "Среди космонавтов тоже есть талантливые художники. Картины этого человека хранятся в Третьяковской галереи. Назовите фамилию первого космического художника.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/Y0e44G3izrE?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/8fbB8usbTbo?playsinline=1"),
                    answer: ["ЛЕОНОВ"],
                    answerCharacters: "ЛОРНЕГАГВОИАНВ"),
                
                Question(
                    title: "Свет далёких планет",
                    location: Location(name: "Речной вокзал",
                                       address: "М. Горького 82",
                                       latitude: 53.187425,
                                       longitude: 50.078923,
                                       photoFilename: "Речнои вокзал",
                                       activationRadius: 100,
                                       distance: 350),
                    author: authors["Королёв"]!,
                    questionText: "Исследование каких двух планет проводилось под руководством С.П. Королева?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/tXaxZzYRiHw?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/-EqX3bQOp9M?playsinline=1"),
                    answer: ["ВЕНЕРА", "МАРС"],
                    answerCharacters: "ВАРПСЮЕУИАНПЕЛАЕМРНТР"),
                
                Question(
                    title: "Секреты космонавтики",
                    location: Location(name: "Мемориальная доска С.Г. Хумарьяну",
                                       address: "Степана Разина 31",
                                       latitude: 53.182427,
                                       longitude: 50.083386,
                                       photoFilename: "Мемориальная доска Хумарьяну",
                                       distance: 1100),
                    author: authors["Артемьев"]!,
                    questionText: "С.П. Королев был настолько засекречен, что когда он 12 апреля 1961 года приехал в, так называемый, «домик на Волге» и хотел войти, сотрудник КГБ попытался этому воспрепятствовать. Так как в лицо его знали только начальники. Назовите фамилию человека, к которому на встречу шел Королев.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/szt07mZFoqg?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/tu3ecFZI5LY?playsinline=1"),
                    answer: ["ГАГАРИН"],
                    answerCharacters: "ГИДОВТНИАТВЕАГЕАР")
              ],
              variations: [
                RouteVariation(length: 6.3, duration: 90, questionIndexes: [4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]),
                RouteVariation(length: 7.5, duration: 120, questionIndexes: [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]),
                RouteVariation(length: 10.7, duration: 180, questionIndexes: Array(0...19))
              ]),
        
        
        // MARK: - Космос и культура
        
        Route(id: "spaceculture",
              imageFileName: "background2.png",
              title: "Космос и культура",
              subtitle: "Историческая часть города",
              questions: [
                Question(
                    title: "Священное писание",
                    location: Location(name: "Стела «Ладья»",
                                       address: "Стела «Ладья»",
                                       latitude: 53.215900,
                                       longitude: 50.132266,
                                       photoFilename: "Ладья",
                                       activationRadius: 45,
                                       distance: 0),
                    author: authors["Лазаренко"]!,
                    questionText: "В одной книге рассказывается о первых космических полетах. Автор шутит, что люди отправили в космос разделённый на части груз этого «плавательного средства». Оно отсылает нас к одной из священных книг. Назовите это плавательное средство, состоящее из двух слов.",
                    questionVideoUrl: nil,
                    answerVideoUrl: nil,
                    answer: ["НОЕВ", "КОВЧЕГ"],
                    answerCharacters: "НЕОККОЧГВДОВЕЛ"),
                
                Question(
                    title: "Учитель",
                    location: Location(name: "Скульптурная композиция «Колыбель человечества»",
                                       address: "Волжский проспект 49",
                                       latitude: 53.211678,
                                       longitude: 50.121983,
                                       photoFilename: "Колыбель человечества",
                                       distance: 900),
                    author: authors["Бабкин"]!,
                    questionText: "Этот человек происходил из польского дворянского рода, но был «обычным» сельским учителем. Автор научно-фантастических произведений, сторонник и пропагандист идей освоения космического пространства. Его именем назван кратер на Луне и малая планета «1590», открытая 1 июля 1933 года. В 2015 году его имя присвоено городу, построенному близ космодрома «Восточный». В Самаре, Москве, Санкт-Петербурге, а также во многих других населённых пунктах есть улицы его имени. Назовите фамилию этого человека.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/eOs_G65fE_8?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/Mrchfp3YFtM?playsinline=1"),
                    answer: ["ЦИОЛКОВСКИЙ"],
                    answerCharacters: "ЦКИОИЛЙОВККОСН"),
                
                Question(
                    title: "Древние цивилизации",
                    location: Location(name: "Скульптура «Первый спутник»",
                                       address: "Волжский проспект 36",
                                       latitude: 53.208451,
                                       longitude: 50.114155,
                                       photoFilename: "Скульптура Первыи Спутник",
                                       distance: 650),
                    author: authors["Артемьев"]!,
                    questionText: "Константин Эдуардович Циолковский из-за глухоты рано оказался наедине с собой, со своими мыслями, он мерил жизнь и мир собственной меркой, иначе определял границы между реальным и воображаемым. И стирал их. Своё отношение к жизни он описал в одной очень увлекательной книге, в которой отмечал, что самое важное для него – «не прожить даром жизнь». О какой книге идёт речь?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/clmAWfZ8SWI?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/5aUkc15McW4?playsinline=1"),
                    answer: ["КОСМИЧЕСКАЯ", "ФИЛОСОФИЯ"],
                    answerCharacters: "КИАИЛОЯЕОСФСЧССИКФМОЯ"),
                
                Question(
                    title: "Космическая «нетленка»",
                    location: Location(name: "Скульптура «Открытая книга»",
                                       address: "Волжский проспект 10",
                                       latitude: 53.206004,
                                       longitude: 50.107852,
                                       photoFilename: "Открытая книга",
                                       distance: 400),
                    author: authors["Филатова"]!,
                    questionText: "Однажды осенью 1960 года срочно потребовалась песня о завоевании космического пространства великим советским народом — позже выяснилось, что задание о песне было спущено с самого верха, от советского правительства. Сотрудник Всесоюзного радио Владимир Войнович, набравшись храбрости, предложил в качестве поэта себя. На другое утро он показал комиссии свои стихи. Музыка О.Фельцмана была готова уже через несколько часов, а Владимира Трошина стал первым исполнителем. Назовите название этой песни на слова Войновича, планы озвученные в которой спустя почти 60 лет так и остаются пока мечтой.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/cG78ZItzT6o?playsinline=1"),
                    answerVideoUrl: nil,
                    answer: ["14 МИНУТ", "ДО СТАРТА"],
                    answerCharacters: "12432МОДАРНУТТТСИА"),
                
                Question(
                    title: "Мёртвая станция",
                    location: Location(name: "Памятник отопительной батарее",
                                       address: "Волжский проспект 11",
                                       latitude: 53.202746,
                                       longitude: 50.103302,
                                       photoFilename: "Памятник отопительнои батарее",
                                       distance: 1000),
                    author: authors["Прокопьев"]!,
                    questionText: "Вы находитесь около памятника отопительной батарее. Об этом предмете в 1987 году в космосе мечтали два космонавта, когда, прилетев на станцию, они узнали, что температура внутри нее 3 – 5°С. Запасы воды, оставшиеся на станции, замёрзли. Температура была настолько низкой, что приходилось надевать тёплые комбинезоны, шерстяные шапки и варежки. Это произошло из-за сбоя системы ориентации солнечных батарей, что повлекло отключение всей системы электропитания станции. Эта история описана в книге «Записки с мертвой станции», а в 2017 году по этой книге был снят фильм. Назовите фамилии двух космонавтов и название «мертвой» станции.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/NyTrU0KgXCo?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/ISkp7OZlg9o?playsinline=1"),
                    answer: ["ДЖАНИБЕКОВ", "САВИНЫХ", "САЛЮТ-7"],
                    answerCharacters: "СДАИНХАКОИЫСЮАБНВЕЛЖВТ7"),
                
                Question(
                    title: "Искусство обмана",
                    location: Location(name: "Самарский академ. театр драмы им. М.Горького",
                                       address: "Чапаева 1",
                                       latitude: 53.197366,
                                       longitude: 50.097198,
                                       photoFilename: "Театр драмы",
                                       activationRadius: 80,
                                       distance: 800),
                    author: authors["Юрченко"]!,
                    questionText: "Айзек Азимов писал, что, когда женщина занимается макияжем, она творит из Хаоса ЭТО. Что имел ввиду известный фантаст?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/EDC5uqBB4y8?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/gZkx07CMYRY?playsinline=1"),
                    answer: ["КОСМОС"],
                    answerCharacters: "КЕОМСВЛОАССЕНЯ"),
                
                Question(
                    title: "Ключ на старт",
                    location: Location(name: "Буратино. Музей-усадьба А. Толстого",
                                       address: "Фрунзе, 155",
                                       latitude: 53.193640,
                                       longitude: 50.095622,
                                       photoFilename: "Буратино",
                                       distance: 650),
                    author: authors["Титов"]!,
                    questionText: "Все космонавты берут с собой на борт игрушку. На какой минуте полета игрушка выполняет свое предназначение?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/s8W9_QDu_4w?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/V1rmyaAigQ4?playsinline=1"),
                    answer: ["8"],
                    alternativeAnswer: ["9"],
                    answerCharacters: "123456789"),
                
                Question(
                    title: "Знаете, каким он парнем был",
                    location: Location(name: "Самарская гос. филармония",
                                       address: "Фрунзе, 141",
                                       latitude: 53.191646,
                                       longitude: 50.094859,
                                       photoFilename: "Самарская филармония",
                                       activationRadius: 65,
                                       distance: 150),
                    author: authors["Черкасов"]!,
                    questionText: "Одной из самых известных его песен стала – «Знаете, каким он парнем был». Песня-посвящение Ю.А. Гагарину. Назовите фамилии композитора и автора стихов данного произведения.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/zznNR8-Yco0?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/9gzWVaZ0feE?playsinline=1"),
                    answer: ["ДОБРОНРАВОВ", "ПАХМУТОВА"],
                    answerCharacters: "ДОНВООТВАБМВОХУАРРПАН"),
                
                Question(
                    title: "Сила духа",
                    location: Location(name: "Дядя Стёпа",
                                       address: "Молодогвардейская 72",
                                       latitude: 53.186435,
                                       longitude: 50.095572,
                                       photoFilename: "Дядя Степа",
                                       distance: 850),
                    author: authors["Корниенко"]!,
                    questionText: "Чтобы сократить после полёта время реабилитации, на МКС космонавт должен ежедневно заниматься около двух с половиной часов. Силовых упражнений нет — только аэробные: если нарастить мышечную массу, можно не поместиться в кресло, и тогда вернуться на Землю будет затруднительно. Назовите явление, которое является главным «врагом» мышц в космосе.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/kooxsq4aE3w?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/p7b6OzE9FuM?playsinline=1"),
                    answer: ["НЕВЕСОМОСТЬ"],
                    answerCharacters: "НСМТМООДЬОХЕЬТОВЕЛСАН"),
                
                Question(
                    title: "Поля без границ",
                    location: Location(name: "Стела в честь 150-летия Самарской Губернии",
                                       address: "Куйбышева, 99",
                                       latitude: 53.187927,
                                       longitude: 50.089384,
                                       photoFilename: "Стела в честь 150-летия Самарскои Губернии",
                                       distance: 450),
                    author: authors["Лазуткин"]!,
                    questionText: "Играли ли когда-нибудь люди в космосе в гольф? Назовите количество раз (0, если не играли никогда).",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/F5qeCjrx6yA?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/Lv4PR8yrJfM?playsinline=1"),
                    answer: ["2"],
                    answerCharacters: "0123456"),
                
                Question(
                    title: "Хвостатые герои",
                    location: Location(name: "Памятник бравому солдату Швейку",
                                       address: "Некрасовская, 26",
                                       latitude: 53.190364,
                                       longitude: 50.090982,
                                       photoFilename: "Памятник Швеику",
                                       distance: 300),
                    author: authors["Королёва"]!,
                    questionText: "Какие до полета в космос были имена у собак Белки и Стрелки?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/mbOapNVz1WE?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/WhKzzm9DJx4?playsinline=1"),
                    answer: ["ВИЛЬНА", "КАПЛЯ"],
                    answerCharacters: "ВБОЬАИЛЯКЛИАПНБК"),
                
                Question(
                    title: "Про любовь",
                    location: Location(name: "Памятник товарищу Сухову",
                                       address: "Максима Горького 115",
                                       latitude: 53.190846,
                                       longitude: 50.083693,
                                       photoFilename: "Памятник Сухову",
                                       distance: 600),
                    author: authors["Котов"]!,
                    questionText: "Памятник товарищу Сухову посвящён главному персонажу фильма, которого блестяще сыграл актёр Анатолий Борисович Кузнецов. Этот памятник расположен здесь не случайно. Ведь именно в Самару писал свои трогательные письма красноармеец Сухов. Назовите имя «единственной и незабвенной» Фёдора Ивановича.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/eEPryrDe9Jw?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/N-uvsQSjs7c?playsinline=1"),
                    answer: ["КАТЕРИНА"],
                    answerCharacters: "КЕАТТЯААРНЬТИН"),
                
                Question(
                    title: "Поэма о космонавте",
                    location: Location(name: "Фонтан «Парус»",
                                       address: "Максима Горького 107",
                                       latitude: 53.189641,
                                       longitude: 50.082413,
                                       photoFilename: "Фонтан Парус",
                                       distance: 100),
                    author: authors["Сойфер"]!,
                    questionText: "В стихотворении В. Высоцкого «Поэма о космонавте» есть такие строки:\n\tВот мой дублер, который мог быть Первым,\n\tКоторый смог впервые стать вторым.\n\tПока что на него не тратят шрифта —\n\tЗапас заглавных букв на одного.\n\tМы с ним вдвоем прошли весь путь до лифта,\n\tНо дальше я поднялся без него.\nНазовите фамилию этого известного всем Героя.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/fw6dEOdLvHI?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/C4p1b2dsmNQ?playsinline=1"),
                    answer: ["ТИТОВ"],
                    answerCharacters: "ГГАТТЁИОРКОВРА"),
                
                Question(
                    title: "Космический художник",
                    location: Location(name: "Композиция «Бурлаки на Волге»",
                                       address: "Максима Горького 107",
                                       latitude: 53.189791,
                                       longitude: 50.082047,
                                       photoFilename: "Бурлаки на Волге",
                                       distance: 50),
                    author: authors["Просочкина"]!,
                    questionText: "Среди космонавтов тоже есть талантливые художники. Картины этого человека хранятся в Третьяковской галереи. Назовите фамилию первого космического художника.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/Y0e44G3izrE?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/8fbB8usbTbo?playsinline=1"),
                    answer: ["ЛЕОНОВ"],
                    answerCharacters: "РЛАНИГОГЕАНОЬВ"),
                
                Question(
                    title: "Океан вселенной",
                    location: Location(name: "Речной вокзал",
                                       address: "Максима Горького 82",
                                       latitude: 53.187425,
                                       longitude: 50.078923,
                                       photoFilename: "Речнои вокзал",
                                       activationRadius: 100,
                                       distance: 350),
                    author: authors["Артемьев"]!,
                    questionText: "Отбытие экипажа на старт всегда сопровождает песня сверхпопулярной некогда группы «Земляне». Вспомните название этой песни.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/ODWOj9HfrLU?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/5R4NGIii8YI?playsinline=1"),
                    answer: ["ТРАВА", "У ДОМА"],
                    answerCharacters: "УМАСРАЕАДОТВВА")
              ],
              variations: [
                RouteVariation(length: 7.3, duration: 120, questionIndexes: Array(0...14))
              ]),
        
        
        
        // MARK: - Первые шаги. Почему Куйбышев?
        
        Route(id: "firststeps",
              imageFileName: "background3.png",
              title: "Первые шаги. Почему Куйбышев?",
              subtitle: "Центральная часть города",
              questions: [
                Question(
                    title: "Опередивший время",
                    location: Location(name: "Монумент «Энергия-Буран»",
                                       address: "Московское шоссе 34",
                                       latitude: 53.211518,
                                       longitude: 50.176868,
                                       photoFilename: "Монумент Энергия-Буран",
                                       distance: 0),
                    author: authors["Корзун"]!,
                    questionText: "15 ноября 1988 года состоялся полет советского многоразового орбитального корабля «Буран». Впервые в истории «челнок» успешно приземлился в автоматическом режиме и попал в книгу рекордов Гиннесса. «Шаттлы» сажали исключительно вручную. Назовите фамилию летчика-космонавта, научившего «летать» Буран.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/X1LlOO46lzU?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/HZ_1CR-VCYo?playsinline=1"),
                    answer: ["ВОЛК"],
                    answerCharacters: "КЕЛВРАТЕМОЬОРВ"),
                
                Question(
                    title: "Кузница кадров",
                    location: Location(name: "Административный корпус",
                                       address: "Московское шоссе 34",
                                       latitude: 53.212032,
                                       longitude: 50.177602,
                                       photoFilename: "Административныи корпус",
                                       activationRadius: 70,
                                       distance: 100),
                    author: authors["Лазуткин"]!,
                    questionText: "Заведующим кафедрой динамики полета и систем управления, а также кафедрой летательных аппаратов в КуАИ и СГАУ более 20 лет был последователь С.П. Королева, прошедший ВОВ, ведущий конструктор знаменитой «семёрки». Назовите его фамилию.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/jWBza3HR_20?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/ZOnsglvUHDQ?playsinline=1"),
                    answer: ["КОЗЛОВ"],
                    answerCharacters: "КМОЕВЕТОЬЛЗРАН"),
                
                Question(
                    title: "Новый старт",
                    location: Location(name: "Бюст С.П. Королёва",
                                       address: "Московское шоссе 34",
                                       latitude: 53.212421,
                                       longitude: 50.178640,
                                       photoFilename: "Бюст Королева",
                                       distance: 100),
                    author: authors["Рень"]!,
                    questionText: "Назовите космодром, при пуске с которого трасса выведения пилотируемого транспортного корабля в основном проходит над водной поверхностью.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/4fiE4VgggOo?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/BUvmG0p_Oj0?playsinline=1"),
                    answer: ["ВОСТОЧНЫЙ"],
                    answerCharacters: "ВСЧАУТКРЙНБОЫО"),
                
                Question(
                    title: "На земле и в космосе",
                    location: Location(name: "Ботанический сад",
                                       address: "Ботанический сад",
                                       latitude: 53.212826,
                                       longitude: 50.179764,
                                       photoFilename: "Ботаническии сад",
                                       distance: 400),
                    author: authors["Филатова"]!,
                    questionText: "В честь Гагарина называли улицы, скверы, школы, университеты и прочее. Кроме этого, существует сорт гладиолусов, посвященный Гагарину. Как называются эти гладиолусы?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/rV8dIlAgCYU?playsinline=1"),
                    answerVideoUrl: nil,
                    answer: ["УЛЫБКА", "ГАГАРИНА"],
                    answerCharacters: "УАЫНАГЛИЕЮБКАГРАИ"),
                
                Question(
                    title: "Костюмчик на выход",
                    location: Location(name: "Памятник М.В. Ломоносову",
                                       address: "Академика Павлова 1",
                                       latitude: 53.223527,
                                       longitude: 50.171350,
                                       photoFilename: "Памятник Ломоносову",
                                       distance: 2000),
                    author: authors["Котельников"]!,
                    questionText: "Невесомость приводит к общему ухудшению состояния здоровья. Сегодня космические экспедиции длятся около полугода. Во время них космонавты каждый день занимаются спортом минимум два часа, а перед возвращением на Землю используют нагрузочный костюм. С помощью специальных прорезиненных жгутов он позволяет придать телу нагрузку, похожую на земную. Как называется нагрузочный костюм, благодаря которому космонавты возвращаются на Землю немного ослабевшими, но все же здоровыми?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/SbRvHT1ZvZs?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/XB2TG19tmpM?playsinline=1"),
                    answer: ["ПИНГВИН"],
                    answerCharacters: "ПГИАИТТЛНСВЕНК"),
                
                Question(
                    title: "Домик над Волгой",
                    location: Location(name: "Загородный парк",
                                       address: "Ново-Садовая 106",
                                       latitude: 53.227521,
                                       longitude: 50.173981,
                                       photoFilename: "Загородныи парк",
                                       activationRadius: 70,
                                       distance: 600),
                    author: authors["Лазуткин"]!,
                    questionText: "Перед полётом в космос Юрий Гагарин имел звание старшего лейтенанта. Какое воинское звание было присвоено ему в городе Куйбышеве после полета в космос?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/n6JTh09TNqY?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/b5WhVuJlar0?playsinline=1"),
                    answer: ["МАЙОР"],
                    answerCharacters: "МНИЙЙЕАТАКРОЛН"),
                
                Question(
                    title: "Путь из космоса",
                    location: Location(name: "Телебашня, ГТРК «Самара»",
                                       address: "Советской Армии, 205",
                                       latitude: 53.230631,
                                       longitude: 50.192130,
                                       photoFilename: "Телебашня",
                                       activationRadius: 150,
                                       distance: 1800),
                    author: authors["Федяев"]!,
                    questionText: "Улица Гагарина – одна из основных транспортных магистралей города Самары. Она получила свое название 15 апреля 1961 года решением Горисполкома Куйбышева. По этой дороге, сразу после возвращения из космоса, проехал Юрий Гагарин, следуя с заводского аэродрома на Безымянке на обкомовскую дачу на берегу Волги. Назовите название улицы, которое она носила до апреля 1961 года.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/mvV5Y0pInIk?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/7z3wSGbdQsA?playsinline=1"),
                    answer: ["ЧЕРНОВСКОЕ", "ШОССЕ"],
                    answerCharacters: "ЕЕНСОШОВОЧРМСКОЕССК"),
                
                Question(
                    title: "На пыльных дорожках",
                    location: Location(name: "«Космические» ворота",
                                       address: "Парк культуры и отдыха имени Юрия Гагарина",
                                       latitude: 53.229117,
                                       longitude: 50.195489,
                                       photoFilename: "Космические ворота",
                                       distance: 300),
                    author: authors["Степанова"]!,
                    questionText: "Средняя температура Марса –55 градусов, его атмосфера на 95% состоит из углекислого газа. Диаметр Марса почти в 2 раза меньше диаметра Земли. А сколько процентов составляет сила тяжести на поверхности Красной планеты относительно земной?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/Sn7bxOzAC5A?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/ibnAGcoK2gI?playsinline=1"),
                    answer: ["37"],
                    answerCharacters: "1234567"),
                
                Question(
                    title: "Первопроходец",
                    location: Location(name: "Бюст Ю.А. Гагарина",
                                       address: "Парк культуры и отдыха имени Юрия Гагарина",
                                       latitude: 53.228681,
                                       longitude: 50.196993,
                                       photoFilename: "Бюст Гагарина",
                                       distance: 300),
                    author: authors["Артемьев"]!,
                    questionText: "12 апреля 1961 года первый космонавт Ю.А. Гагарин приземлился на поле колхоза имени Шевченко, близь деревни Смеловка в 27 километрах южнее города Энгельса. После посадки подобравшего его вертолета удивленный председатель колхоза вручил ему награду. Как называется первая медаль, которой был награжден Юрий Алексеевич после полета?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/8TQvAiMfyC0?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/9K3m7RproCQ?playsinline=1"),
                    answer: ["ЗА ОСВОЕНИЕ", "ЦЕЛИННЫХ", "ЗЕМЕЛЬ"],
                    answerCharacters: "ЗВНННИМАЛЕЕЕЫХОЕЦОИЗСЛЕЬ"),
                
                Question(
                    title: "Минуты, изменившие мир",
                    location: Location(name: "Мост через пруд",
                                       address: "Парк культуры и отдыха имени Юрия Гагарина",
                                       latitude: 53.228771,
                                       longitude: 50.198803,
                                       photoFilename: "Мост через пруд",
                                       distance: 300),
                    author: authors["Королёва"]!,
                    questionText: "Сколько минут длился первый в мире полет человека в космос?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/uLZ5GC9Uey8?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/Jtiu9n3VUkQ?playsinline=1"),
                    answer: ["108"],
                    answerCharacters: "1523806"),
                
                Question(
                    title: "Звёздный сосед",
                    location: Location(name: "Колесо обозрения",
                                       address: "Парк культуры и отдыха имени Юрия Гагарина",
                                       latitude: 53.230543,
                                       longitude: 50.198083,
                                       photoFilename: "Колесо обозрения",
                                       activationRadius: 80,
                                       distance: 300),
                    author: authors["Виноградов"]!,
                    questionText: "Как называется звезда самая близкая к Солнцу и нашей Солнечной системе?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/AU98WbhIzEw?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/P6Kpsv3rH78?playsinline=1"),
                    answer: ["АЛЬФА", "ЦЕНТАВРА"],
                    answerCharacters: "ФЛТАВСАРЦЕЬНАА"),
                
                Question(
                    title: "Космос-арена",
                    location: Location(name: "Ипподром",
                                       address: "пр. Кирова 320",
                                       latitude: 53.250156,
                                       longitude: 50.219906,
                                       photoFilename: "Ипподром",
                                       activationRadius: 200,
                                       distance: 3000),
                    author: authors["Прокопьев"]!,
                    questionText: "Какое природное явление космонавты видят 16 раз в сутки?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/BQnXb6XYikw?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/Nj2y-oT8DNI?playsinline=1"),
                    answer: ["ВОСХОД"],
                    answerCharacters: "ОЗДАКАВХАЕСОРВ"),
                
                Question(
                    title: "Летающий танк",
                    location: Location(name: "Штурмовик Ил-2",
                                       address: "Московское шоссе / пр. Кирова",
                                       latitude: 53.251052,
                                       longitude: 50.222563,
                                       photoFilename: "Штурмовик Ил-2",
                                       activationRadius: 90,
                                       distance: 500),
                    author: authors["Тихонов"]!,
                    questionText: "Ил-2 изначально разрабатывался как двухместный самолет. Но в ходе испытаний были выявлены некоторые серьезные недостатки. Ильюшин решил пойти на хитрость, сделав Ил-2 одноместным. Вместо кабины штурмана был установлен еще один бензобак. Бронекорпус был уменьшен. Это позволило сделать штурмовик легче. Ил-2 называли БШ-2 «Бронированным штурмовиком». Для улучшения обзора кабину пилота приподняли, после чего Ил-2 приобрёл другое прозвище. Какое новое прозвище получил Ил-2?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/H98rGx4yrQ0?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/re4MJulRoc0?playsinline=1"),
                    answer: ["ГОРБАТЫЙ"],
                    answerCharacters: "ОЫТГБКЛРАЕГЙИН")
              ],
              variations: [
                RouteVariation(length: 6.2, duration: 90, questionIndexes: [0,1,2,3,4,5,6,7,8,9,10]),
                RouteVariation(length: 9.7, duration: 160, questionIndexes: Array(0...12))
              ]),
        
        
        
        // MARK: - Самарские предприятия, проложившие путь в космос
        
        Route(id: "spaceindustry",
              imageFileName: "background4.png",
              title: "Самарские предприятия, проложившие путь в космос",
              subtitle: "Аллея трудовой славы",
              questions: [
                Question(
                    title: "К полёту готов",
                    location: Location(name: "Фонтан «Царевна-Лебедь»",
                                       address: "Парк культуры и отдыха 50-летия Октября",
                                       latitude: 53.235150,
                                       longitude: 50.267655,
                                       photoFilename: "Фонтан Царевна-Лебедь",
                                       activationRadius: 200,
                                       distance: 0),
                    author: authors["Лазуткин"]!,
                    questionText: "Вне зависимости от типа и предназначения все российские скафандры названы в честь НИХ. О ком идет речь?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/yWdd2Hx1JAs?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/FwZgfQFVwEU?playsinline=1"),
                    answer: ["ПТИЦЫ"],
                    answerCharacters: "ПБКЦОТШКИИСЫАР"),
                
                Question(
                    title: "Как за каменной стеной",
                    location: Location(name: "АО «Арконик СМЗ»",
                                       address: "пр. Юных Пионеров 167Г",
                                       latitude: 53.233293,
                                       longitude: 50.264262,
                                       photoFilename: "АО Арконик СМЗ",
                                       distance: 600),
                    author: authors["Шкаплеров"]!,
                    questionText: "Какова толщина стенок герметичной оболочки Международной космической Станции (в миллиметрах)?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/pQfw7ZVmtn4?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/TvvNnkJAp20?playsinline=1"),
                    answer: ["3"],
                    answerCharacters: "1234567"),
                
                Question(
                    title: "Космическая эстафета",
                    location: Location(name: "Стела в честь первого магистрального газопровода",
                                       address: "пр. Юных Пионеров 167В",
                                       latitude: 53.232963,
                                       longitude: 50.263508,
                                       photoFilename: "Стела в честь первого магистрального газопровода",
                                       distance: 150),
                    author: authors["Котов"]!,
                    questionText: "«Сердце» этого предмета, было изготовлено специалистами ПАО «Кузнецов» и учеными Самарского аэрокосмического университета. Он стал главным символом мероприятия, которое состоялось в 2014 году в Сочи. Перед этим событием уменьшенная копия этого предмета впервые побывала в открытом космосе. Назовите предмет, о котором идёт речь.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/L_8nHkB7q1k?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/OKTzzU8HGFA?playsinline=1"),
                    answer: ["ФАКЕЛ"],
                    answerCharacters: "АРДВФЕКЛТЕАКЗА"),
                
                Question(
                    title: "Вопреки",
                    location: Location(name: "ПАО «Кузнецов»",
                                       address: "пр. Юных Пионеров 165",
                                       latitude: 53.231881,
                                       longitude: 50.260880,
                                       photoFilename: "ПАО Кузнецов",
                                       distance: 300),
                    author: authors["Корниенко"]!,
                    questionText: "Этот Двигатель создавался в Куйбышеве коллективом под руководством Генерального конструктора Н.Д. Кузнецова в конце 60-х – начале 70-х годов для первой ступени «лунной» ракеты Н1-Л3. К сожалению, в 1974 году «лунная программа» была закрыта. Этот двигатель получил своё второе рождение спустя более чем 20 лет: он применялся в первой ступени американской РН «Антарес», и сейчас используется в первой ступени РН легкого класса «Союз-2.1в». Как называется этот двигатель?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/kXStxFIS6RU?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/dc-_hKzb4J0?playsinline=1"),
                    answer: ["НК-33"],
                    answerCharacters: "ЛНРК373"),
                
                Question(
                    title: "За гранью возможного",
                    location: Location(name: "Монумент подшипникового завода",
                                       address: "пр. Юных Пионеров 155",
                                       latitude: 53.231065,
                                       longitude: 50.259496,
                                       photoFilename: "Монумент подшипникового завода",
                                       distance: 250),
                    author: authors["Королёв"]!,
                    questionText: "Перечислите в алфавитном порядке названия пилотируемых кораблей, созданных под руководством С.П. Королева.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/YsshUKGTC_Y?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/Y3p4HJAQa8A?playsinline=1"),
                    answer: ["ВОСТОК", "ВОСХОД", "СОЮЗ"],
                    answerCharacters: "СЗОВОСКНКХЮСОТОВОД"),
                
                Question(
                    title: "Пешком вокруг земли",
                    location: Location(name: "Центральная композиция аллеи",
                                       address: "пр. Юных Пионеров 143",
                                       latitude: 53.230229,
                                       longitude: 50.257340,
                                       photoFilename: "Центральная композиция аллеи",
                                       distance: 250),
                    author: authors["Артемьев"]!,
                    questionText: "Скорость бега космонавтов на тренировках составляет примерно 7-14 км/ч. За 5 лет на беговой дорожке космонавты провели около 4000 часов и преодолели путь равный экватору Земли. Сколько километров пробежали космонавты по беговой дорожке БД-2?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/fL_N8bNBeaQ?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/hohri1xNzEA?playsinline=1"),
                    answer: ["40075"],
                    answerCharacters: "0023457"),
                
                Question(
                    title: "Упавшая звезда",
                    location: Location(name: "Монумент Куйбышевкабель",
                                       address: "пр. Юных Пионеров 139",
                                       latitude: 53.229717,
                                       longitude:  50.256493,
                                       photoFilename: "Монумент Куибышевкабель",
                                       distance: 200),
                    author: authors["Рень"]!,
                    questionText: "Что проходят в Центре подготовки космонавтов при подготовке к космическим полетам для того, чтобы члены экипажа сохранили жизнь и здоровье?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/VDAvGeSl76c?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/JBA_Z4e67LM?playsinline=1"),
                    answer: ["ТРЕНИРОВКИ", "ПО", "ВЫЖИВАНИЮ"],
                    answerCharacters: "ТРИЫИЕОКПОРИИВЖВВАННЮ"),
                
                Question(
                    title: "Трещин нет!",
                    location: Location(name: "Куйбышевский авиационный завод",
                                       address: "пр. Юных Пионеров 136",
                                       latitude: 53.228337,
                                       longitude: 50.253214,
                                       photoFilename: "Куибышевскии авиационныи завод",
                                       distance: 500),
                    author: authors["Артемьев"]!,
                    questionText: "Начало пути Юрия Алексеевича Гагарина в авиации тоже было связано с посадкой. Он был невысокого роста и во время обучения в летном училище оказался на грани отчисления, так как не мог корректно выполнить посадку. Заметив это, один из руководителей предложил Юрию положить на сидение самолета этот предмет. Назовите этот предмет.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/5ZMVn6dqFA8?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/yYWdTxiNrco?playsinline=1"),
                    answer: ["ПОДУШКА"],
                    answerCharacters: "ПАОГИКЛИКУНДША"),
                
                Question(
                    title: "Война и космос",
                    location: Location(name: "Мемориал «Триумфальная арка»",
                                       address: "пр. Юных Пионеров 134",
                                       latitude: 53.228092,
                                       longitude: 50.252851,
                                       photoFilename: "Триумфальная арка",
                                       distance: 100),
                    author: authors["Авдеев"]!,
                    questionText: "Победители в Великой Отечественной стали и победителями в освоении космоса, среди них много конструкторов и рабочих. Кроме того, и в отряде космонавтов был человек, прошедший всю войну. И ставший единственным, кто удостоен первой звезды Героя за Великую Отечественную войну, а второй — за полёт в космос. Назовите фамилию этого человека.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/PeU5f2T-UKE?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/3HmbOv1m6YI?playsinline=1"),
                    answer: ["БЕРЕГОВОЙ"],
                    answerCharacters: "БВЕКОРЗГЕУОЕНЙ"),
                
                Question(
                    title: "Восточный",
                    location: Location(name: "Монумент РКЦ «Прогресс»",
                                       address: "пр. Юных Пионеров 130А",
                                       latitude: 53.227167,
                                       longitude: 50.250851,
                                       photoFilename: "Монумент РКЦ Прогресс",
                                       distance: 300),
                    author: authors["Сердюк"]!,
                    questionText: "Назовите область, в которой расположен космодром Восточный и как называется наукоград при космодроме?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/DZAbvh2EZSs?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/DiXX00YnvVA?playsinline=1"),
                    answer: ["АМУРСКАЯ", "ЦИОЛКОВСКИЙ"],
                    answerCharacters: "ЦВКРООУКААСЛЙСИИКМЯ"),
                
                Question(
                    title: "Пункт назначения",
                    location: Location(name: "Монумент завода Авиаагрегат",
                                       address: "пр. Юных Пионеров 116",
                                       latitude: 53.226298,
                                       longitude: 50.248775,
                                       photoFilename: "Монумент завода Авиаагрегат",
                                       distance: 200),
                    author: authors["Степанова"]!,
                    questionText: "Транспортное сообщение между двумя этими пунктами налажено около 50 лет назад, но грузообмен явно неравномерен. В пункте Б на данный момент находится примерно 170 тонн различных грузов и материалов, доставленных из пункта А, в то время как пункт А за все это время получил всего 382 килограмма из пункта Б. Назовите пункты А и Б в правильном порядке.",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/nmCpguXTaA8?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/8692mPIK3Iw?playsinline=1"),
                    answer: ["ЗЕМЛЯ", "ЛУНА"],
                    answerCharacters: "ЛЕЛРУМНЯМНААЗС"),
                
                Question(
                    title: "Космические посадки",
                    location: Location(name: "Парк культуры и отдыха «Молодежный»",
                                       address: "Городской парк культуры и отдыха «Молодёжный»",
                                       latitude: 53.223446,
                                       longitude: 50.239791,
                                       photoFilename: "Парк Молодежныи",
                                       activationRadius: 250,
                                       distance: 800),
                    author: authors["Лазаренко"]!,
                    questionText: "За сколько часов происходит возвращение космонавтов с орбиты: от момента расстыковки корабля с МКС до посадки?",
                    questionVideoUrl: URL(string: "https://www.youtube.com/embed/Y_JK9ZhypaI?playsinline=1"),
                    answerVideoUrl: URL(string: "https://www.youtube.com/embed/ZVZmUfUp-sA?playsinline=1"),
                    answer: ["3"],
                    alternativeAnswer: ["4"],
                    answerCharacters: "1234567")
              ],
              variations: [
                RouteVariation(length: 4, duration: 60, questionIndexes: Array(0...11))
              ])
        
    ]
}
