//
//  LoginController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 16.02.2021.
//

import UIKit

protocol LoginControllerEditingDelegate: class {
    func loginControllerDidEndEditing(_ controller: LoginController, userName: String, email: String)
}

class LoginController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var isInEditingMode = false
    var editingDelegate: LoginControllerEditingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.layer.dropShadow(opacity: 0.3, radius: 7)
        titleLabel.layer.dropShadow(opacity: 0.7, radius: 10)
        nameTextField.setLeftImage(UIImage(systemName: "person"), imageWidth: 30, padding: 7)
        emailTextField.setLeftImage(UIImage(systemName: "envelope"), imageWidth: 30, padding: 7)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapRecognizer)
        
        loginButton.setTitle(isInEditingMode ? "Сохранить" : "Войти", for: .normal)
        cancelButton.isHidden = !isInEditingMode
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameTextField.text = isInEditingMode ? DataModel.current.userName : ""
        emailTextField.text = isInEditingMode ? DataModel.current.email : ""
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard checkUserName(),
              checkEmail(),
              let name = nameTextField.text,
              let email = emailTextField.text
        else { return }

        if isInEditingMode {
            editingDelegate?.loginControllerDidEndEditing(self, userName: name, email: email)
            dismiss(animated: true)
        } else {
            DataModel.logIn(userName: name, email: email)
            guard let tabBarController = storyboard?.instantiateViewController(withIdentifier: "TabBarController") else { return }
            tabBarController.modalPresentationStyle = .fullScreen
            tabBarController.modalTransitionStyle = .flipHorizontal
            present(tabBarController, animated: true)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Private Functions
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func trimCharacters(in textField: UITextField) {
        textField.text = textField.text!.trimmingCharacters(in: [" "]).trimmingCharacters(in: [" "])
    }
    
    private func checkUserName() -> Bool {
        trimCharacters(in: nameTextField)
        guard nameTextField.text!.count < 2 else { return true }
        showAlert(title: "Name Validation Error", message: "User name is invalid.\nPlease provide correct user name.")
        return false
    }
    
    private func checkEmail() -> Bool {
        trimCharacters(in: emailTextField)
        guard emailTextField.text!.count < 2 else { return true }
        showAlert(title: "Email Validation Error", message: "Email is invalid.\nPlease provide correct email.")
        return false
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

extension LoginController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nameTextField {
            emailTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
}
