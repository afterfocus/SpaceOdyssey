//
//  LaunchViewController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 16.03.2021.
//

import UIKit

final class LaunchViewController: UIViewController {
    
    @IBOutlet private var dogImageView: UIImageView!
    @IBOutlet private var greetingsLabel: UILabel!
    
    @IBOutlet private var dogXConstraint: NSLayoutConstraint!
    @IBOutlet private var dogYConstraint: NSLayoutConstraint!
    @IBOutlet private var labelYConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dogImageView.alpha = 0
        greetingsLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        dogXConstraint.constant = 50
        dogYConstraint.constant = -70
        labelYConstraint.constant = 70
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut) {
            self.dogImageView.alpha = 1
            self.greetingsLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 1.4, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
            let window = UIApplication.shared.windows[0]
            window.rootViewController = viewController
            UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
        }
    }
}
