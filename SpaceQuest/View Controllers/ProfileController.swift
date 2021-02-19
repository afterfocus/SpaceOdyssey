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
                                Версия приложения: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Undefined")

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
                                      message: "\nВесь прогресс пользователя будет сохранен и восстановлен при следующем входе",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let exitAction = UIAlertAction(title: "Выход", style: .default) { _ in
            DataModel.current.exit()
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
        dataModel.editUserData(newName: userName, newEmail: email)
        userNameLabel.text = userName
        emailLabel.text = email
    }
}


// MARK: - MFMailComposeViewControllerDelegate

extension ProfileController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
