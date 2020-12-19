//
//  DataProvider.swift
//  SpaceQuest
//
//  Created by Максим Голов on 20.11.2020.
//

import Foundation

// MARK: - Temp File

class DataProvider {
    
    // MARK: - Authors
    
    struct Authors {
        static let artemiev = Author(surname: "Артемьев",
                                     name: "Олег",
                                     patronymic: "Германович",
                                     aboutAuthor: "Герой РФ\nЛётчик-космонавт")
        static let avdeev = Author(surname: "Авдеев",
                                   name: "Сергей",
                                   patronymic: "Васильевич",
                                   aboutAuthor: "Герой РФ\nЛетчик-космонавт")
        static let anshakov = Author(surname: "Аншаков",
                                     name: "Геннадий",
                                     patronymic: "Петрович",
                                     aboutAuthor: "Герой Социалистического Труда")
        static let babkin = Author(surname: "Бабкин",
                                   name: "Андрей",
                                   patronymic: "Николаевич",
                                   aboutAuthor: "Космонавт-испытатель Роскосмоса")
        static let baranov = Author(surname: "Баранов",
                                    name: "Дмитрий",
                                    patronymic: "Александрович",
                                    aboutAuthor: "Заслуженный конструктор РФ")
        static let vinogradov = Author(surname: "Виноградов",
                                       name: "Павел",
                                       patronymic: "Владимирович",
                                       aboutAuthor: "Герой РФ\nЛётчик-космонавт")
        static let kotov = Author(surname: "Котов",
                                  name: "Олег",
                                  patronymic: "Валерьевич",
                                  aboutAuthor: "Герой РФ\nЛётчик-космонавт")
        static let kikina = Author(surname: "Кикина",
                                   name: "Анна",
                                   patronymic: "Юрьевна",
                                   aboutAuthor: "Космонавт-испытатель Роскосмоса")
        static let korzun = Author(surname: "Корзун",
                                   name: "Валерий",
                                   patronymic: "Григорьевич",
                                   aboutAuthor: "Герой РФ\nЛётчик-космонавт")
        static let kornienko = Author(surname: "Корниенко",
                                      name: "Михаил",
                                      patronymic: "Борисович",
                                      aboutAuthor: "Герой РФ\nЛётчик-космонавт")
        static let korolev = Author(surname: "Королёв",
                                    name: "Андрей",
                                    patronymic: "Вадимович",
                                    aboutAuthor: "Внук С.П. Королёва")
        static let koroleva = Author(surname: "Королёва",
                                     name: "Наталия",
                                     patronymic: "Сергеевна",
                                     aboutAuthor: "Дочь С.П. Королёва")
        static let lazarenko = Author(surname: "Лазаренко",
                                      name: "Александр",
                                      patronymic: "Юрьевич",
                                      aboutAuthor: "Ветеран поисково-спасательного отдела")
        static let lazutkin = Author(surname: "Лазуткин",
                                     name: "Александр",
                                     patronymic: "Иванович",
                                     aboutAuthor: "Герой РФ\nЛётчик-космонавт")
        static let prokopiev = Author(surname: "Прокопьев",
                                      name: "Сергей",
                                      patronymic: "Валерьевич",
                                      aboutAuthor: "Герой РФ\nЛётчик-космонавт")
        static let prosochkina = Author(surname: "Просочкина",
                                        name: "Анастасия",
                                        patronymic: "",
                                        aboutAuthor: "Художник, иллюстратор и дизайнер An.Pro ART")
        static let soifer = Author(surname: "Сойфер",
                                   name: "Виктор",
                                   patronymic: "Александрович",
                                   aboutAuthor: "Заслуженный деятель науки РФ")
        static let stepanova = Author(surname: "Степанова",
                                      name: "Анастасия",
                                      patronymic: "Александровна",
                                      aboutAuthor: "Ведущий инженер Института РАН")
        static let titov = Author(surname: "Титов",
                                  name: "Владимир",
                                  patronymic: "Георгиевич",
                                  aboutAuthor: "Герой СССР\nЛётчик-космонавт")
        static let filatova = Author(surname: "Филатова",
                                     name: "Тамара",
                                     patronymic: "Дмитриевна",
                                     aboutAuthor: "Племянница Ю.А. Гагарина")
        static let ren = Author(surname: "Рень",
                                name: "Виктор",
                                patronymic: "Алексеевич",
                                aboutAuthor: "Герой РФ\nИнструктор-испытатель")
        static let cherkasov = Author(surname: "Черкасов",
                                      name: "Андрей",
                                      patronymic: "",
                                      aboutAuthor: "Инженер-испытатель НПП «Звезда»")
        static let tihonov = Author(surname: "Тихонов",
                                    name: "Николай",
                                    patronymic: "Владимирович",
                                    aboutAuthor: "Космонавт-испытатель Роскосмоса")
        static let shkaplerov = Author(surname: "Шкаплеров",
                                       name: "Антон",
                                       patronymic: "Николаевич",
                                       aboutAuthor: "Герой РФ\nЛётчик-космонавт")
    }

    // MARK: - Routes
    
    static var routes = [
            Route(imageFileName: "background1.png",
                  title: "Космическая столица России",
                  subtitle: "Историческая часть города",
                  questions: [
                    Question(
                        title: "Перед стартом",
                        address: "МВЦ «Самара Космическая»",
                        author: Authors.korzun,
                        questionText: "Посмотрите внимательно на ракету. Так она выглядит за 2,5 часа до старта. Назовите настоящий цвет ракеты «Союза» и причину того, что ракета становится белой.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/33hnI0SLtnw?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/9nKjkbawOEI?playsinline=1"),
                        answer: ["СЕРЫЙ"],
                        answerButtons: "СРЧРНЕБИЫЕНИЛСЙ",
                        score: 0),
                    
                    Question(
                        title: "Великолепная шестёрка",
                        address: "Памятник Д.И.Козлову",
                        author: Authors.baranov,
                        questionText: "В 1946 году перед ведущими конструкторами СССР ставилась единая цель – создание баллистических, а затем и космических ракет. Для управления этой системой был создан координационный орган, который хоть и имел совещательно-консультативные функции, однако его члены обладали необходимыми полномочиями для формирования направления развития советской ракетно-космической программы и смежных исследований. Вспомните название этого совещательного органа.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/TIvJebiqV9o?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/R50m7lnY5AM?playsinline=1"),
                        answer: ["СОВЕТ", "ГЛАВНЫХ"],
                        answerButtons: "СТСВГЛХЫВЕОАЮНОЗ",
                        score: 0),
                    
                    Question(
                        title: "Дом-рекордсмен",
                        address: "Сквер им. В.И.Фадеева",
                        author: Authors.avdeev,
                        questionText: "Дмитрий Ильич Козлов всю жизнь защищал Родину, причем в молодости ему пришлось делать это собственной кровью. 1 июля 1941 года студент пятого курса института Дмитрий Козлов добровольцем записался в народное ополчение, прошел всю Великую Отечественную войну, был трижды ранен и потерял руку. Получил несколько боевых наград. Медалью за оборону какого города был награжден Козлов?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/iVOB-crqAmQ?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/UU4D150Q6pQ?playsinline=1"),
                        answer: ["ЛЕНИНГРАД"],
                        answerButtons: "ЛРСАНДЕРТНГМАИАСА",
                        score: 0),
                    
                    Question(
                        title: "Семейные узы",
                        address: "Дворец бракосочетания",
                        author: Authors.cherkasov,
                        questionText: "В истории отечественной космонавтики есть потомственные космонавты, когда дети осознанно выбирают путь своих отцов и становятся достойными их продолжателями в профессии космонавта. Назовите фамилии двух основателей космических династий.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/aCGk9x3gKEQ?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/XgjiacSNFk8?playsinline=1"),
                        answer: ["ВОЛКОВ", "РОМАНЕНКО"],
                        answerButtons: "ВЛАОКОКВГАЕНОГРНРАОМИН",
                        score: 0),
                    
                    Question(
                        title: "К звёздам",
                        address: "Скульптура «Первый спутник»",
                        author: Authors.shkaplerov,
                        questionText: "Сегодня самарский РКЦ «Прогресс» - единственное в мире предприятие, осуществляющее пуски ракет-носителей с четырех площадок. Перечислите названия этих космодромов.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/K7OAFKBM3ho?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/eWtvOw_tK4k?playsinline=1"),
                        answer: ["БАЙКОНУР", "ПЛЕСЕЦК", "ВОСТОЧНЫЙ", "КУРУ"],
                        answerButtons: "БНЕУВАЫПНУЙСРКЕЛРЙСОКОТЦОЧКУ",
                        score: 2),
                    
                    Question(
                        title: "Покорившая небо",
                        address: "Спортивный комплекс ЦСКА ВВС",
                        author: Authors.kikina,
                        questionText: "Один из основных факторов космического полёта — элемент риска и опасности, заставляющий быть готовым быстро принимать правильные решения, — моделирует специальная парашютная подготовка. У истоков парашютной подготовки космонавтов стояла ЭТА удивительная хрупкая женщина. К моменту зачисления в отряд космонавтов она уже выполнила около 700 прыжков. А общее число прыжков — около 2500. Кроме того она является полковником ВВС в отставке, дублёром Валентины Терешковой. Назовите фамилию этой женщины.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/xRIKovb9Eh4?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/UxBcOgDIg58?playsinline=1"),
                        answer: ["СОЛОВЬЁВА"],
                        answerButtons: "СВЬАЛКГЁОГРРВОАИОАН",
                        score: 3),
                    
                    Question(
                        title: "Родной край",
                        address: "Монумент «Гордость, честь и слава Самарской области»",
                        author: Authors.kornienko,
                        questionText: "Четыре космонавта родились в Самарской области. Назовите их фамилии.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/yxZzwP_OYCc?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/JWYIcLjgWWw?playsinline=1"),
                        answer: ["КОРНИЕНКО", "ГУБАРЕВ", "АТЬКОВ", "АВДЕЕВ"],
                        answerButtons: "КАЕКНУАЕРИТЕНОБОВРВАДГЕВКОЬВ",
                        score: 2),
                    
                    Question(
                        title: "Счёт на секунды",
                        address: "Монумент Славы",
                        author: Authors.titov,
                        questionText: "Назовите фамилию руководителя стартовой команды корабля «Союз-Т-10-1» – Героя Социалистического Труда, заместителя генерального конструктора «ЦСКБ-Прогресс».",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/vulFYcCDSr0?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/2O7px0BRJWQ?playsinline=1"),
                        answer: ["СОЛДАТЕНКОВ"],
                        answerButtons: "СЁНТОВАЕЛДОРККОЛ",
                        score: 3),
                    
                    Question(
                        title: "На удачу",
                        address: "Мемориальная доска А.М. Солдатенкову",
                        author: Authors.lazarenko,
                        questionText: "У Сергея Павловича Королева был любимый головной убор, который он всегда носил с осени и до ранней весны. Сергей Павлович был также весьма суеверным человеком, и этот предмет непременно был на нем во время каждого старта. О каком головном уборе идет речь?",
                        questionVideoUrl: nil,
                        answerVideoUrl: nil,
                        answer: ["ШЛЯПА"],
                        answerButtons: "ШСРАЕЗКПКЕПЯКОКЫБЛАА",
                        score: 1),
                   
                    Question(
                        title: "Заключённый",
                        address: "Памятник Д.Ф. Устинову",
                        author: Authors.artemiev,
                        questionText: "В 1944 г. отечественные инженеры впервые получили возможность ознакомиться с немецкой ракетной техникой: в их распоряжение попали элементы конструкции ракеты А-4. Назовите общеизвестное название этой ракеты.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/CHzZXM1yMms?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/LPd9HiORRQw?playsinline=1"),
                        answer: ["ФАУ-2"],
                        answerButtons: "ФНРДУАСК234",
                        score: 2),
                   
                    Question(
                        title: "Вечный двигатель",
                        address: "Адм.корпус Самарского университета",
                        author: Authors.soifer,
                        questionText: "Сколько маршевых двигателей у ракеты-носителя Союз-2, предназначенных для вывода кораблей Союз-МС?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/XNvl2r3nJHY?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/assyWByROes?playsinline=1"),
                        answer: ["6"],
                        answerButtons: "0123456",
                        score: 2),
                    
                    Question(
                        title: "Музыкальная пауза",
                        address: "Памятник Дмитрию Шостаковичу",
                        author: Authors.filatova,
                        questionText: "Ещё одна песня, написанная Дмитрием Шостаковичем на слова Евгения Долматовского в 1950 году, неразрывно связана с началом космической эры. Первоначально она создавалась как «песня-позывной» для лётчика. Стала известна в исполнении солиста и хора, ещё большую популярность песня получила после того, как её спел Юрий Алексеевич Гагарин в первом космическом полёте. Назовите название этой песни.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/Meilc24vjuM?playsinline=1"),
                        answerVideoUrl: nil,
                        answer: ["РОДИНА", "СЛЫШИТ"],
                        answerButtons: "РАВЫОТЛЗНЁСИДИШОТ",
                        score: 3),
                   
                    Question(
                        title: "Железный конь",
                        address: "Бункер Сталина",
                        author: Authors.babkin,
                        questionText: "История РКЦ «Прогресс» началась в Москве в 1894 году, когда обрусевший немец Ю. Меллер основал небольшую мастерскую по ремонту популярного в то время вида транспорта. О каком транспорте идет речь?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/pqXqCznx6FU?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/nJ5PIYGle4w?playsinline=1"),
                        answer: ["ВЕЛОСИПЕД"],
                        answerButtons: "ВАЕСЕЛДОМКСОАПИТ",
                        score: 1),
                   
                    Question(
                        title: "Разведка",
                        address: "Мемориальная доска «Кембриджской пятерке»",
                        author: Authors.koroleva,
                        questionText: "Когда и каким космическим аппаратом была сфотографирована обратная сторона Луны?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/aOMuZ2cWb8M?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/s3JETFgFLY0?playsinline=1"),
                        answer: ["04.10.1959", "ЛУНА-3"],
                        answerButtons: "ЛНМРАУС310450919",
                        score: 0),
                    
                    Question(
                        title: "Космическая физика",
                        address: "Композиция «Дама с ракеткой»",
                        author: Authors.prokopiev,
                        questionText: "В классической механике существует теорема теннисной ракетки о неустойчивости вращения твёрдого тела относительно второй главной оси инерции. Проявление этой теоремы в невесомости названо в честь советского космонавта, который заметил это явление 25 июня 1985 года, находясь на борту космической станции «Салют-7». Назовите фамилию этого космонавта.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/g2kjgqjdGwg?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/as-ln4yFwUo?playsinline=1"),
                        answer: ["ДЖАНИБЕКОВ"],
                        answerButtons: "ДБЖЕЕКНОВАИЕ",
                        score: 2),
                  
                    Question(
                        title: "Про любовь",
                        address: "Памятник товарищу Сухову",
                        author: Authors.kotov,
                        questionText: "Памятник товарищу Сухову посвящён главному персонажу фильма, которого блестяще сыграл актёр Анатолий Борисович Кузнецов. Этот памятник расположен здесь не случайно. Ведь именно в Самару писал свои трогательные письма красноармеец Сухов. Назовите имя «единственной и незабвенной» Фёдора Ивановича",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/eEPryrDe9Jw?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/N-uvsQSjs7c?playsinline=1"),
                        answer: ["КАТЕРИНА"],
                        answerButtons: "КТЕНАРЕНИАЛЯ",
                        score: 3),
                  
                    Question(
                        title: "Астрокошка",
                        address: "Фонтан «Парус»",
                        author: Authors.anshakov,
                        questionText: "В космос успешно запускали не только собак, но и наиболее близких человеку по физиологии обезьян. А вот судьба кошек-космонавтов, к сожалению, не сложилась. На данный момент достоверно подтверждён полет в космос единственного представителя вида. Назовите имя этой астрокошки.",
                        questionVideoUrl: nil,
                        answerVideoUrl: nil,
                        answer: ["ФЕЛИСЕТТ"],
                        answerButtons: "ФЕКТМИЕРУЛСТА",
                        score: 3),
                   
                    Question(
                        title: "Космический художник",
                        address: "Композиция «Бурлаки на Волге»",
                        author: Authors.prosochkina,
                        questionText: "Среди космонавтов тоже есть талантливые художники. Картины этого человека хранятся в Третьяковской галереи. Назовите фамилию первого космического художника.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/Y0e44G3izrE?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/8fbB8usbTbo?playsinline=1"),
                        answer: ["ЛЕОНОВ"],
                        answerButtons: "ЛОРНЕГАГВОИАН",
                        score: 1),
                   
                    Question(
                        title: "Свет далёких планет",
                        address: "Речной вокзал",
                        author: Authors.korolev,
                        questionText: "Исследование каких двух планет проводилось под руководством С.П. Королева?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/tXaxZzYRiHw?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/-EqX3bQOp9M?playsinline=1"),
                        answer: ["ВЕНЕРА", "МАРС"],
                        answerButtons: "ВРПСЮЕИАЕАЕМРНТР",
                        score: 2),
                   
                    Question(
                        title: "Секреты космонавтики",
                        address: "Мемориальная доска С.Г. Хумарьяну",
                        author: Authors.artemiev,
                        questionText: "Королев был настолько засекречен, что когда он 12 апреля 1961 года приехал в, так называемый, «домик на Волге» и хотел войти, сотрудник КГБ попытался этому воспрепятствовать. Так как в лицо его знали только начальники. Назовите фамилию человека, к которому на встречу шел Королев.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/szt07mZFoqg?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/tu3ecFZI5LY?playsinline=1"),
                        answer: ["ГАГАРИН"],
                        answerButtons: "ГИДОВТНИАТВЕАГЕАРВ",
                        score: 3)
                  ],
                  variations: [
                    RouteVariation(length: 6.3, duration: 90, questionIndexes: [4,5,6,7,8,9,10,11,12,19,14,15,16,17,18]),
                    RouteVariation(length: 7.5, duration: 120, questionIndexes: [0,1,2,3,4,5,6,7,8,9,10,11,12,19,14]),
                    RouteVariation(length: 10.7, duration: 180, questionIndexes: Array(0...19))
            ]),
        
        
        
        
            Route(imageFileName: "background2.png",
                  title: "Космос и культура",
                  subtitle: "Историческая часть города",
                  questions: [
                    Question(
                        title: "Священное писание",
                        address: "Стела «Ладья»",
                        author: Authors.lazarenko,
                        questionText: "В одной книге рассказывается о первых космических полетах. Автор шутит, что люди отправили в космос разделённый на части груз этого «плавательного средства». Оно отсылает нас к одной из священных книг. Назовите это плавательное средство, состоящее из двух слов.",
                        questionVideoUrl: nil,
                        answerVideoUrl: nil,
                        answer: ["НОЕВ", "КОВЧЕГ"],
                        answerButtons: "НЕОККОЧГВДОВЕЛА",
                        score: 2),
                    
                    Question(
                        title: "Учитель",
                        address: "Скульптурная композиция «Колыбель человечества»",
                        author: Authors.babkin,
                        questionText: "Этот человек происходил из польского дворянского рода, но был «обычным» сельским учителем. Автор научно-фантастических произведений, сторонник и пропагандист идей освоения космического пространства. Его именем назван кратер на Луне и малая планета «1590», открытая 1 июля 1933 года. В 2015 году его имя присвоено городу, построенному близ космодрома «Восточный». В Самаре, Москве, Санкт-Петербурге, а также во многих других населённых пунктах есть улицы его имени.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/eOs_G65fE_8?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/Mrchfp3YFtM?playsinline=1"),
                        answer: ["ЦИОЛКОВСКИЙ"],
                        answerButtons: "ЦКЗИОИЛЙОВККРУОСН",
                        score: 1),
                   
                    Question(
                        title: "Древние цивилизации",
                        address: "Скульптура «Первый спутник»",
                        author: Authors.artemiev,
                        questionText: "Константин Эдуардович Циолковский из-за глухоты рано оказался наедине с собой, со своими мыслями, он мерил жизнь и мир собственной меркой, иначе определял границы между реальным и воображаемым. И стирал их. Своё отношение к жизни он описал в одной очень увлекательной книге, в которой отмечал, что самое важное для него – «не прожить даром жизнь». О какой книге идёт речь?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/clmAWfZ8SWI?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/5aUkc15McW4?playsinline=1"),
                        answer: ["КОСМИЧЕСКАЯ", "ФИЛОСОФИЯ"],
                        answerButtons: "КИАИЛОЯЕОСФСЧСИКФМОЯ",
                        score: 1),
                   
                    Question(
                        title: "Космическая «нетленка»",
                        address: "Скульптура «Открытая книга»",
                        author: Authors.filatova,
                        questionText: "Однажды осенью 1960 года срочно потребовалась песня о завоевании космического пространства великим советским народом — позже выяснилось, что задание о песне было спущено с самого верха, от советского правительства. Сотрудник Всесоюзного радио Владимир Войнович, набравшись храбрости, предложил в качестве поэта себя. На другое утро он показал комиссии свои стихи. Музыка О.Фельцмана была готова уже через несколько часов, а Владимира Трошина стал первым исполнителем. Назовите название этой песни на слова Войновича, планы озвученные в которой спустя почти 60 лет так и остаются пока мечтой.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/cG78ZItzT6o?playsinline=1"),
                        answerVideoUrl: nil,
                        answer: ["14 МИНУТ", "ДО СТАРТА"],
                        answerButtons: "12432МОДАРНУТТТСИА",
                        score: 1),
                   
                    Question(
                        title: "Мёртвая станция",
                        address: "Памятник отопительной батарее",
                        author: Authors.prokopiev,
                        questionText: "Вы находитесь около памятника отопительной батарее. Об этом предмете в 1987 году в космосе мечтали два космонавта, когда, прилетев на станцию, они узнали, что температура внутри нее 3 – 5°С. Запасы воды, оставшиеся на станции, замёрзли. Температура была настолько низкой, что приходилось надевать тёплые комбинезоны, шерстяные шапки и варежки. Это произошло из-за сбоя системы ориентации солнечных батарей, что повлекло отключение всей системы электропитания станции. Данный полёт является одной из сложнейших успешных космических экспедиций, когда-либо проводившихся советскими и российскими космонавтами – впервые были на практике отработаны методы наведения, сближения и стыковки с неуправляемым космическим объектом, реактивация вышедшей из строя космической станции в экстремальных для человека условиях. Эта история описана в книге «Записки с мертвой станции», а в 2017 году по этой книге был снят фильм. Назовите фамилии двух космонавтов и название «мертвой» станции.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/NyTrU0KgXCo?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/ISkp7OZlg9o?playsinline=1"),
                        answer: ["ДЖАНИБЕКОВ", "САВИНОВ", "САЛЮТ-7"],
                        answerButtons: "СДАИНВАКОИОСЮАБНВЕЛЖВТ7",
                        score: 2),
                   
                    Question(
                        title: "Искусство обмана",
                        address: "Самарский академический театр драмы им. М.Горького",
                        author: Authors.kikina,
                        questionText: "Айзек Азимов писал, что, когда женщина занимается макияжем, она творит из Хаоса ЭТО. Что имел ввиду известный фантаст?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/EDC5uqBB4y8?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/gZkx07CMYRY?playsinline=1"),
                        answer: ["КОСМОС"],
                        answerButtons: "КЕОМСВЛОАССЕННЯ",
                        score: 3),
                  
                    Question(
                        title: "Ключ на старт",
                        address: "Буратино. Музей-усадьба А. Толстого",
                        author: Authors.titov,
                        questionText: "Все космонавты берут с собой на борт игрушку. На какой минуте полета игрушка выполняет свое предназначение?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/s8W9_QDu_4w?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/V1rmyaAigQ4?playsinline=1"),
                        answer: ["9"],
                        answerButtons: "123456789",
                        score: 3),
                   
                    Question(
                        title: "Знаете, каким он парнем был",
                        address: "Самарская государственная филармония",
                        author: Authors.cherkasov,
                        questionText: "Одной из самых известных его песен стала – «Знаете, каким он парнем был». Песня-посвящение Ю.А. Гагарину. Назовите фамилии композитора и автора стихов данного произведения.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/zznNR8-Yco0?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/9gzWVaZ0feE?playsinline=1"),
                        answer: ["ПАХМУТОВА", "ДОБРОНРАВОВ"],
                        answerButtons: "ДОНВООТВАБМВОХУАРРПА",
                        score: 3),
                   
                    Question(
                        title: "Сила духа",
                        address: "Дядя Степа",
                        author: Authors.kornienko,
                        questionText: "Форму важно поддерживать не только на земле, но и в космосе. Чтобы сократить после полёта время реабилитации, на МКС космонавт должен ежедневно заниматься около двух с половиной часов. Силовых упражнений нет — только аэробные: если нарастить мышечную массу, можно не поместиться в кресло, и тогда вернуться на Землю будет затруднительно. Назовите явление, которое является главным «врагом» мышц в космосе.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/kooxsq4aE3w?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/p7b6OzE9FuM?playsinline=1"),
                        answer: ["НЕВЕСОМОСТЬ"],
                        answerButtons: "НСМТМООДЬОХЕЬТОВЕЛСА",
                        score: 3),
                   
                    Question(
                        title: "Поля без границ",
                        address: "Стела в честь 150-летия Самарской Губернии",
                        author: Authors.lazutkin,
                        questionText: "Играли ли когда-нибудь люди в космосе в гольф? Назовите количество раз (0, если не играли никогда).",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/F5qeCjrx6yA?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/Lv4PR8yrJfM?playsinline=1"),
                        answer: ["2"],
                        answerButtons: "0123456",
                        score: 2),
                  
                    Question(
                        title: "Хвостатые герои",
                        address: "Памятник бравому солдату Швейку",
                        author: Authors.koroleva,
                        questionText: "Какие до полета в космос были имена у собак Белки и Стрелки?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/mbOapNVz1WE?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/WhKzzm9DJx4?playsinline=1"),
                        answer: ["КАПЛЯ", "ВИЛЬНА"],
                        answerButtons: "ВБОЬАИЛЯКЛИАПНБК",
                        score: 1),
                  
                    Question(
                        title: "Про любовь",
                        address: "Памятник товарищу Сухову",
                        author: Authors.kotov,
                        questionText: "Памятник товарищу Сухову посвящён главному персонажу фильма, которого блестяще сыграл актёр Анатолий Борисович Кузнецов. Этот памятник расположен здесь не случайно. Ведь именно в Самару писал свои трогательные письма красноармеец Сухов. Назовите имя «единственной и незабвенной» Фёдора Ивановича.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/eEPryrDe9Jw?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/N-uvsQSjs7c?playsinline=1"),
                        answer: ["КАТЕРИНА"],
                        answerButtons: "КЕАТТЯААРНЬТИН",
                        score: 0),
                  
                    Question(
                        title: "Поэма о космонавте",
                        address: "Фонтан «Парус»",
                        author: Authors.soifer,
                        questionText: "В 1967 году в городе Куйбышев прошли 5 концертов Владимира Высоцкого. Высоцкий был дружен с Гагариным и другими первыми космонавтами. Он посвящал им свои песни и стихи. А они брали и берут с собой записи Владимира Семеновича на борт космического корабля. Самое сильное его произведение из этой серии – «Поэма о космонавте». В ней есть такие строки:\n\tВот мой дублер, который мог быть Первым,\n\tКоторый смог впервые стать вторым.\n\tПока что на него не тратят шрифта —\n\tЗапас заглавных букв на одного.\n\tМы с ним вдвоем прошли весь путь до лифта,\n\tНо дальше я поднялся без него.\nНазовите фамилию этого известного всем Героя",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/fw6dEOdLvHI?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/C4p1b2dsmNQ?playsinline=1"),
                        answer: ["ТИТОВ"],
                        answerButtons: "ГГАТТЁИОРКОВРАНЛВ",
                        score: 0),
                  
                    Question(
                        title: "Космический художник",
                        address: "Композиция «Бурлаки на Волге»",
                        author: Authors.prosochkina,
                        questionText: "Среди космонавтов тоже есть талантливые художники. Картины этого человека хранятся в Третьяковской галереи. Назовите фамилию первого космического художника.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/Y0e44G3izrE?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/8fbB8usbTbo?playsinline=1"),
                        answer: ["ЛЕОНОВ"],
                        answerButtons: "РЛАНИГОГЕАНОЬРВ",
                        score: 1),
                   
                    Question(
                        title: "Океан вселенной",
                        address: "Речной вокзал",
                        author: Authors.artemiev,
                        questionText: "Отбытие экипажа на старт всегда сопровождает песня сверхпопулярной некогда группы «Земляне». Вспомните название этой песни.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/ODWOj9HfrLU?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/5R4NGIii8YI?playsinline=1"),
                        answer: ["ТРАВА", "У ДОМА"],
                        answerButtons: "УМАСРНАЕАДОТВВИА",
                        score: 2)
                  ],
                  variations: [
                    RouteVariation(length: 7.3, duration: 120, questionIndexes: Array(0...14))
            ]),
            Route(imageFileName: "background3.png",
                  title: "Первые шаги. Почему Куйбышев?",
                  subtitle: "Центральная часть города",
                  questions: [
                    Question(
                        title: "Опередивший время",
                        address: "Монумент «Энергия-Буран»",
                        author: Authors.korzun,
                        questionText: "15 ноября 1988 года состоялся полет советского многоразового орбитального корабля «Буран». Впервые в истории «челнок» успешно приземлился в автоматическом режиме и попал в книгу рекордов Гиннесса. «Шаттлы» сажали исключительно вручную. Назовите фамилию летчика-космонавта, научившего «летать» Буран.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/X1LlOO46lzU?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/HZ_1CR-VCYo?playsinline=1"),
                        answer: ["ВОЛК"],
                        answerButtons: "КЕЛВРАТЕМОЬОЁРВ",
                        score: 2),
                    
                    Question(
                        title: "Поэма о космонавте",
                        address: "Административный корпус",
                        author: Authors.lazutkin,
                        questionText: "Заведующим кафедрой динамики полета и систем управления, а также кафедрой летательных аппаратов в КуАИ и СГАУ более 20 лет был последователь С.П. Королева, прошедший ВОВ, ведущий конструктор знаменитой «семёрки». Назовите его фамилию.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/jWBza3HR_20?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/ZOnsglvUHDQ?playsinline=1"),
                        answer: ["КОЗЛОВ"],
                        answerButtons: "КМОЕВЕТОЬЛЗРАН",
                        score: 3),
                   
                    Question(
                        title: "Новый старт",
                        address: "Бюст С.П. Королева",
                        author: Authors.ren,
                        questionText: "Назовите космодром, при пуске с которого трасса выведения пилотируемого транспортного корабля в основном проходит над водной поверхностью.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/4fiE4VgggOo?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/BUvmG0p_Oj0?playsinline=1"),
                        answer: ["ВОСТОЧНЫЙ"],
                        answerButtons: "ВСЧАУТКРЙНБОЫОУ",
                        score: 0),
                   
                    Question(
                        title: "На земле и в космосе",
                        address: "Ботанический сад",
                        author: Authors.filatova,
                        questionText: "В честь Гагарина называли улицы, скверы, школы, университеты и прочее. Кроме этого, существует сорт гладиолусов, посвященный Гагарину. Как называются эти гладиолусы?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/rV8dIlAgCYU?playsinline=1"),
                        answerVideoUrl: nil,
                        answer: ["УЛЫБКА", "ГАГАРИНА"],
                        answerButtons: "УАЫНАГЛИЕЮБКАГРАИ",
                        score: 2),
                   
                    Question(
                        title: "Костюм на выход",
                        address: "Самарский университет",
                        author: Authors.cherkasov,
                        questionText: "Ещё во время подготовки к космическим полётам была выявлена и обозначена проблема, что невесомость и как следствие отсутствие нагрузки, приводит к общему ухудшению состояния здоровья. Сегодня космические экспедиции длятся около полугода. Во время них космонавты каждый день занимаются спортом минимум два часа, а перед возвращением на Землю используют нагрузочный костюм. С помощью специальных прорезиненных жгутов он позволяет придать телу нагрузку, похожую на земную. Назовите название нагрузочного костюма, благодаря которому космонавты возвращаются на Землю немного ослабевшими, но все же здоровыми?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/CHoUkDjrd7w?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/TVyLNhelTdo?playsinline=1"),
                        answer: ["ПИНГВИН"],
                        answerButtons: "ПГИАИТТЛНСВЕНК",
                        score: 3),
                   
                    Question(
                        title: "Домик над Волгой",
                        address: "Загородный парк",
                        author: Authors.lazutkin,
                        questionText: "Перед полётом в космос Юрий Гагарин имел звание старшего лейтенанта. Какое воинское звание было присвоено ему в городе Куйбышеве после полета в космос?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/n6JTh09TNqY?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/b5WhVuJlar0?playsinline=1"),
                        answer: ["МАЙОР"],
                        answerButtons: "МНИЙЙЕАТТАЕПКРОЛН",
                        score: 3),
                   
                    Question(
                        title: "Путь из космоса",
                        address: "Телебашня, ГТРК «Самара»",
                        author: Authors.kikina,
                        questionText: "Улица Гагарина – одна из основных транспортных магистралей города Самары. Она получила свое название 15 апреля 1961 года решением Горисполкома Куйбышева. По этой дороге, сразу после возвращения из космоса, проехал Юрий Гагарин, следуя с заводского аэродрома на Безымянке на обкомовскую дачу на берегу Волги. Назовите название улицы, которое она носила до апреля 1961 года.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/mvV5Y0pInIk?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/7z3wSGbdQsA?playsinline=1"),
                        answer: ["ЧЕРНОВСКОЕ", "ШОССЕ"],
                        answerButtons: "ЕЕНСОШОВОЧРМСКОЕССК",
                        score: 3),
                   
                    Question(
                        title: "На пыльных дорожках",
                        address: "«Космические» ворота",
                        author: Authors.stepanova,
                        questionText: "Средняя температура Марса –55 градусов, его атмосфера на 95% состоит из углекислого газа. Диаметр Марса почти в 2 раза меньше диаметра Земли. А сколько процентов составляет сила тяжести на поверхности Красной планеты относительно земной?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/Sn7bxOzAC5A?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/ibnAGcoK2gI?playsinline=1"),
                        answer: ["37%"],
                        answerButtons: "1234567",
                        score: 2),
                   
                    Question(
                        title: "Первопроходец",
                        address: "Бюст Ю.А. Гагарина",
                        author: Authors.artemiev,
                        questionText: "12 апреля 1961 года первый космонавт Ю.А. Гагарин приземлился на поле колхоза имени Шевченко, близь деревни Смеловка в 27 километрах южнее города Энгельса. После посадки подобравшего его вертолета удивленный председатель колхоза вручил ему награду. Как называется первая медаль, которой был награжден Юрий Алексеевич после полета?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/8TQvAiMfyC0?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/9K3m7RproCQ?playsinline=1"),
                        answer: ["ЗА ОСВОЕНИЕ", "ЦЕЛИННЫХ", "ЗЕМЕЛЬ"],
                        answerButtons: "ЗВНННИМАЛЕЕЕЫХОЕЦОИЗСЛЕЬ",
                        score: 3),
                   
                    Question(
                        title: "Минуты, изменившие мир",
                        address: "Мост через пруд",
                        author: Authors.koroleva,
                        questionText: "Сколько минут длился первый в мире полет человека в космос?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/uLZ5GC9Uey8?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/Jtiu9n3VUkQ?playsinline=1"),
                        answer: ["108"],
                        answerButtons: "1523806",
                        score: 3),
                   
                    Question(
                        title: "Звёздный сосед",
                        address: "Колесо обозрения",
                        author: Authors.vinogradov,
                        questionText: "Как называется звезда самая близкая к Солнцу и нашей Солнечной системе?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/AU98WbhIzEw?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/P6Kpsv3rH78?playsinline=1"),
                        answer: ["АЛЬФА", "ЦЕНТАВРА"],
                        answerButtons: "ФЛТАСВПАРЦЕЬНАИРКАВОМ",
                        score: 1),
                    
                    Question(
                        title: "Космос-арена",
                        address: "Ипподром",
                        author: Authors.prokopiev,
                        questionText: "Какое природное явление космонавты видят 16 раз в сутки?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/BQnXb6XYikw?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/Nj2y-oT8DNI?playsinline=1"),
                        answer: ["ВОСХОД"],
                        answerButtons: "ОЗДАКАВХАЕССОРВТСТ",
                        score: 2),
                    
                    Question(
                        title: "Летающий танк",
                        address: "Штурмовик Ил-2",
                        author: Authors.tihonov,
                        questionText: "Ил-2 изначально разрабатывался как двухместный самолет. Но в ходе испытаний были выявлены некоторые серьезные недостатки. Ильюшин решил пойти на хитрость, сделав Ил-2 одноместным. Вместо кабины штурмана был установлен еще один бензобак. Бронекорпус был уменьшен. Это позволило сделать штурмовик легче. Ил-2 называли БШ-2 «Бронированным штурмовиком». Для улучшения обзора кабину пилота приподняли, после чего Ил-2 приобрёл другое прозвище. Какое новое прозвище получил Ил-2?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/H98rGx4yrQ0?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/re4MJulRoc0?playsinline=1"),
                        answer: ["ГОРБАТЫЙ"],
                        answerButtons: "ОЫТГБКЛРАЕГЙИ",
                        score: 2)
                  ],
                  variations: [
                    RouteVariation(length: 6.2, duration: 90, questionIndexes: [0,1,2,3,4,5,6,7,8,11,12]),
                    RouteVariation(length: 9.7, duration: 160, questionIndexes: Array(0...12))
            ]),
            Route(imageFileName: "background4.png",
                  title: "Самарские предприятия, проложившие путь в космос",
                  subtitle: "Аллея трудовой славы",
                  questions: [
                    Question(
                        title: "К полёту готов",
                        address: "Парк культуры и отдыха 50-летия Октября, Фонтан «Царевна-Лебедь»",
                        author: Authors.lazutkin,
                        questionText: "Вне зависимости от типа и предназначения все российские скафандры названы в честь НИХ. О ком идет речь?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/yWdd2Hx1JAs?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/FwZgfQFVwEU?playsinline=1"),
                        answer: ["ПТИЦЫ"],
                        answerButtons: "ПБКЦОТШКИИСЫА",
                        score: 2),
                  
                    Question(
                        title: "Как за каменной стеной",
                        address: "АО «Арконик СМЗ»",
                        author: Authors.shkaplerov,
                        questionText: "Какова толщина стенок Международной космической Станции (в миллиметрах)?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/pQfw7ZVmtn4?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/TvvNnkJAp20?playsinline=1"),
                        answer: ["3"],
                        answerButtons: "1234567",
                        score: 3),
                  
                    Question(
                        title: "Космическая эстафета",
                        address: "Стелла в честь первого магистрального газопровода",
                        author: Authors.kotov,
                        questionText: "«Сердце» этого предмета, было изготовлено специалистами ПАО «Кузнецов» и учеными Самарского аэрокосмического университета. Он стал главным символом мероприятия, которое состоялось в 2014 году в Сочи. Перед этим событием уменьшенная копия этого предмета впервые побывала в открытом космосе. Назовите предмет, о котором идёт речь",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/L_8nHkB7q1k?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/OKTzzU8HGFA?playsinline=1"),
                        answer: ["ФАКЕЛ"],
                        answerButtons: "АРДВФЕКЛЗЕТЕАКЗА",
                        score: 1),
                   
                    Question(
                        title: "Вопреки",
                        address: "ПАО «Кузнецов»",
                        author: Authors.kornienko,
                        questionText: "Этот Двигатель создавался в Куйбышеве коллективом под руководством Генерального конструктора Н.Д. Кузнецова в конце 60-х – начале 70-х годов для первой ступени «лунной» ракеты Н1-Л3. К сожалению, в 1974 году «лунная программа» была закрыта. Этот двигатель получил своё второе рождение спустя более чем 20 лет: он применялся в первой ступени американской РН «Антарес», и сейчас используется в первой ступени РН легкого класса «Союз-2.1в». Как называется этот двигатель?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/kXStxFIS6RU?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/dc-_hKzb4J0?playsinline=1"),
                        answer: ["НК-33"],
                        answerButtons: "ЛНРК373",
                        score: 2),
                   
                    Question(
                        title: "За гранью возможного",
                        address: "Подшипники «СПЗ-ГРУПП»",
                        author: Authors.korolev,
                        questionText: "Вспомните названия пилотируемых кораблей, созданных под руководством С.П. Королева.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/YsshUKGTC_Y?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/Y3p4HJAQa8A?playsinline=1"),
                        answer: ["ВОСТОК", "ВОСХОД", "СОЮЗ"],
                        answerButtons: "СЗОВОСКХЮСОТОВОД",
                        score: 3),
                  
                    Question(
                        title: "Пешком вокруг земли",
                        address: "Центральная композиция аллеи",
                        author: Authors.artemiev,
                        questionText: "Скорость бега космонавтов на тренировках составляет примерно 7-14 км/ч. За 5 лет на беговой дорожке космонавты провели около 4000 часов и преодолели путь равный экватору Земли. Сколько километров пробежали космонавты по беговой дорожке БД-2?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/fL_N8bNBeaQ?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/hohri1xNzEA?playsinline=1"),
                        answer: ["40075"],
                        answerButtons: "0023457",
                        score: 3),
                  
                    Question(
                        title: "Упавшая звезда",
                        address: "Куйбышевкабель",
                        author: Authors.ren,
                        questionText: "Что делают в Центре подготовки космонавтов при подготовке к космическим полетам для того, чтобы члены экипажа сохранили жизнь и здоровье?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/VDAvGeSl76c?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/JBA_Z4e67LM?playsinline=1"),
                        answer: ["ТРЕНИРОВКИ", "ПО ВЫЖИВАНИЮ"],
                        answerButtons: "ТРИЫИЕОКПОРИИВЖВВАННЮ",
                        score: 1),
                  
                    Question(
                        title: "Трещин нет",
                        address: "Куйбышевский авиационный завод",
                        author: Authors.artemiev,
                        questionText: "Начало пути Юрия Алексеевича Гагарина в авиации тоже было связано с посадкой. Он был невысокого роста и во время обучения в летном училище оказался на грани отчисления, так как не мог корректно выполнить посадку. Заметив это, один из руководителей предложил Юрию положить на сидение самолета этот предмет. Назовите этот предмет.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/5ZMVn6dqFA8?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/yYWdTxiNrco?playsinline=1"),
                        answer: ["ПОДУШКА"],
                        answerButtons: "ПАОГИККУНДША",
                        score: 2),
                  
                    Question(
                        title: "Война и космос",
                        address: "Мемориал «Триумфальная арка»",
                        author: Authors.avdeev,
                        questionText: "Победители в Великой Отечественной стали и победителями в освоении космоса, среди них много конструкторов и рабочих. Кроме того, и в отряде космонавтов был человек, прошедший всю войну. И ставший единственным, кто удостоен первой звезды Героя за Великую Отечественную войну, а второй — за полёт в космос. Назовите фамилию этого человека.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/PeU5f2T-UKE?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/3HmbOv1m6YI?playsinline=1"),
                        answer: ["БЕРЕГОВОЙ"],
                        answerButtons: "БВЕКОРЗГЕУОЕНЙЦ",
                        score: 3),
                  
                    Question(
                        title: "Восточный",
                        address: "РКЦ «Прогресс»",
                        author: Authors.kikina,
                        questionText: "Назовите область, в которой расположен космодром Восточный и как называется наукоград при космодроме?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/DZAbvh2EZSs?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/DiXX00YnvVA?playsinline=1"),
                        answer: ["АМУРСКАЯ", "ЦИОЛКОВСКИЙ"],
                        answerButtons: "ЦВКРООУКААСЛЙСИИКМЯ",
                        score: 1),
                   
                    Question(
                        title: "Пункт назначения",
                        address: "Авиаагрегат",
                        author: Authors.stepanova,
                        questionText: "Транспортное сообщение между двумя этими пунктами налажено около 50 лет назад, но грузообмен явно неравномерен. В пункте Б на данный момент находится примерно 170 тонн различных грузов и материалов, доставленных из пункта А, в то время как пункт А за все это время получил всего 382 килограмма из пункта Б. Назовите пункты А и Б в правильном порядке.",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/nmCpguXTaA8?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/8692mPIK3Iw?playsinline=1"),
                        answer: ["ЗЕМЛЯ", "ЛУНА"],
                        answerButtons: "ЛЕЛРУМНЯМААЗС",
                        score: 3),
                   
                    Question(
                        title: "Космические посадки",
                        address: "Городской парк культуры и отдыха «Молодежный»",
                        author: Authors.lazarenko,
                        questionText: "За сколько часов происходит возвращение космонавтов с орбиты: от момента расстыковки корабля с МКС до посадки?",
                        questionVideoUrl: URL(string: "https://www.youtube.com/embed/Y_JK9ZhypaI?playsinline=1"),
                        answerVideoUrl: URL(string: "https://www.youtube.com/embed/ZVZmUfUp-sA?playsinline=1"),
                        answer: ["4"],
                        answerButtons: "1234567",
                        score: 2)
                  ],
                  variations: [
                    RouteVariation(length: 4, duration: 60, questionIndexes: Array(0...11))
            ])
         
    ]
}
