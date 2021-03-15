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

final class LoginController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - Internal Properties
    
    var isInEditingMode = false
    var editingDelegate: LoginControllerEditingDelegate?
    
    // MARK: - View Life Cycle
    
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
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameTextField.text = isInEditingMode ? DataModel.current.userName : ""
        emailTextField.text = isInEditingMode ? DataModel.current.email : ""
    }
    
    // MARK: - IBAction
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard validateNameAndEmail(),
              let name = nameTextField.text,
              let email = emailTextField.text
        else { return }

        if isInEditingMode {
            dismiss(animated: true) {
                self.editingDelegate?.loginControllerDidEndEditing(self, userName: name, email: email)
            }
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
    
    @objc private func keyboardWillShow() {
        view.frame.origin.y = min(0, UIScreen.main.bounds.height - loginButton.frame.maxY - 240)
    }
    
    @objc private func keyboardWillHide() {
        view.frame.origin.y = 0
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func trimCharacters(in textField: UITextField) {
        textField.text = textField.text!.trimmingCharacters(in: [" "]).trimmingCharacters(in: [" "])
    }
    
    private func validateNameAndEmail() -> Bool {
        trimCharacters(in: nameTextField)
        trimCharacters(in: emailTextField)
        
        if nameTextField.text!.count < 2 {
            present(UIAlertController.incorrentNameAlert, animated: true)
            return false
        }
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        if !predicate.evaluate(with: emailTextField.text!) {
            present(UIAlertController.incorrentEmailAlert, animated: true)
            return false
        }
        return true
    }
}

// MARK: - UITextFieldDelegate

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
