//
//  ProfileController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 12.02.2021.
//

import UIKit
import MessageUI

// MARK: ProfileController

class ProfileController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var isMapInNightModeSwitch: UISwitch!
    @IBOutlet weak var isRoutingDisabledSwitch: UISwitch!
    @IBOutlet weak var versionLabel: UILabel!
    
    // MARK: - Private Properties
    
    private var dataModel: DataModel {
        return DataModel.current
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        containerView.layer.cornerRadius = 30
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageBackgroundView.layer.borderWidth = 3.5
        imageBackgroundView.layer.borderColor = .lightAccent
        
        userNameLabel.text = dataModel.userName
        emailLabel.text = dataModel.email
        
        isMapInNightModeSwitch.isOn = dataModel.isMapNightModeEnabled
        isRoutingDisabledSwitch.isOn = dataModel.isRoutingDisabled
        
        versionLabel.text = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Undefined")"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scoreLabel.text = "\( DataModel.routes.reduce(into: 0) { $0 += $1.score } )"
    }
    
    // MARK: - IBActions
    
    @IBAction func mapModeSwitched(_ sender: UISwitch) {
        dataModel.isMapNightModeEnabled = sender.isOn
    }
    
    @IBAction func routingModeSwitched(_ sender: UISwitch) {
        dataModel.isRoutingDisabled = sender.isOn
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        guard let loginController = storyboard?.instantiateViewController(withIdentifier: "LoginController") as? LoginController else { return }
        loginController.isInEditingMode = true
        loginController.editingDelegate = self
        present(loginController, animated: true)
    }
    
    @IBAction func youtubeButtonPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://youtube.com/c/AleksandraDanilenko")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func instagramButtonPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://instagram.com/zhadina.space/")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func tiktokButtonPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://www.tiktok.com/@zhadina.space")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func emailUsButtonPressed(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["afterfocus@icloud.com", "aerotaksimaksim@gmail.com"])
            mail.setSubject("Одиссея Марса")
            mail.setMessageBody("""
                                Одиссея Марса - iOS

                                Пользователь: \(DataModel.current.userName)
                                Устройство: \(UIDevice.modelName)
                                Версия iOS: \(UIDevice.current.systemVersion)
                                Версия приложения: \(versionLabel.text ?? "Undefined")

                                Ваш вопрос:

                                """, isHTML: false)
            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "Отправка E-mail недоступа.",
                                          message: "\nОтправка E-mail невозможна в связи с настройками Вашего устройства.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .cancel)
            alert.addAction(okAction)
            present(alert, animated: true)
        }
    }
    
    @IBAction func exitButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Вы действительно хотите выйти?",
                                      message: "\nВесь прогресс пользователя будет сохранен и восстановлен при следующем входе.",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let exitAction = UIAlertAction(title: "Выход", style: .default) { _ in
            DataModel.logOut()
            guard let loginController = self.storyboard?.instantiateViewController(withIdentifier: "LoginController") else { return }
            loginController.modalPresentationStyle = .fullScreen
            loginController.modalTransitionStyle = .flipHorizontal
            self.present(loginController, animated: true)
        }
        alert.addAction(exitAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}


// MARK: - LoginControllerEditingDelegate

extension ProfileController: LoginControllerEditingDelegate {
    
    func loginControllerDidEndEditing(_ controller: LoginController, userName: String, email: String) {
        if dataModel.editUser(newName: userName, newEmail: email) {
            userNameLabel.text = userName
            emailLabel.text = email
            let alert = UIAlertController(title: "Данные изменены",
                                          message: "Для повторного входа необходимо использовать новое имя пользователя и электронную почту.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .cancel)
            alert.addAction(okAction)
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Ошибка изменения данных",
                                          message: "Пользователь с таким именем и электронной почтой уже зарегистрирован на устройстве.\nПожалуйста, осуществите вход в профиль данного пользователя или укажите другую комбинацию имени и электронной почты.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .cancel)
            alert.addAction(okAction)
            present(alert, animated: true)
        }
    }
}


// MARK: - MFMailComposeViewControllerDelegate

extension ProfileController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
