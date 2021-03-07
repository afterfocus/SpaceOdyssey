//
//  ProfileController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 12.02.2021.
//

import UIKit
import MessageUI

// MARK: ProfileController

final class ProfileController: UIViewController {
    
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
        let (score, distance, calories) = DataModel.routes.reduce(into: (0, 0, 0)) {
            $0.0 += $1.score
            $0.1 += $1.distancePassed
            $0.2 += $1.caloriesBurned
        }
        scoreLabel.text = "\(score)"
        distanceLabel.text = "\(Double(distance) / 1000)"
        kcalLabel.text = "\(calories)"
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
    
    @IBAction func bonusButtonPressed(_ sender: UIButton) {
        guard let videoAnswerVC = storyboard!.instantiateViewController(withIdentifier: "VideoAnswerController") as? VideoAnswerController else { return }
        videoAnswerVC.videoURL = URL(string: "https://www.youtube.com/embed/Kk0GdMjRgQE?playsinline=1")
        videoAnswerVC.mode = .bonusVideo
        videoAnswerVC.modalPresentationStyle = .overFullScreen
        present(videoAnswerVC, animated: true)
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
            mail.setToRecipients(["info@odysseymars.com"])
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
            present(UIAlertController.cannotSendEmailAlert, animated: true)
        }
    }
    
    @IBAction func resendPrizesButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController.confirmResendPrizes {
            self.resendPrizes() { code in
                if code == 200 {
                    self.present(UIAlertController.resendPrizesSuccessful, animated: true)
                } else {
                    self.present(UIAlertController.routePrizesNotSend(errorCode: code), animated: true)
                }
            }
        }
        present(alert, animated: true)
    }
    
    @IBAction func exitButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController.confirmExitAlert {
            DataModel.logOut()
            guard let loginController = self.storyboard?.instantiateViewController(withIdentifier: "LoginController") else { return }
            loginController.modalPresentationStyle = .fullScreen
            loginController.modalTransitionStyle = .flipHorizontal
            self.present(loginController, animated: true)
        }
        present(alert, animated: true)
    }
    
    private func resendPrizes(completion: @escaping (Int) -> Void) {
        dataModel.sendRegistrationPrize { statusCode in
            completion(statusCode ?? 408)
            
            for route in DataModel.routes where route.isCompleted {
                self.dataModel.sendRoutePrize(route: route)
            }
        }
    }
}


// MARK: - LoginControllerEditingDelegate

extension ProfileController: LoginControllerEditingDelegate {
    
    func loginControllerDidEndEditing(_ controller: LoginController, userName: String, email: String) {
        if dataModel.editUser(newName: userName, newEmail: email) {
            userNameLabel.text = userName
            emailLabel.text = email
            present(UIAlertController.profileEditSuccessAlert, animated: true)
        } else {
            present(UIAlertController.profileEditFailedAlert, animated: true)
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
