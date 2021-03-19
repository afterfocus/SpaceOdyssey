//
//  AboutAppController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 14.02.2021.
//

import UIKit

// MARK: AboutAppController

final class AboutAppController: UIViewController {
    
    // MARK: IBActions
    
    @IBAction func yandexTermsOfUseButtonPressed(_ sender: UIButton) {
        if let url = URL(string: "https://yandex.ru/legal/maps_termsofuse/") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func audioAuthorsButtonPressed(_ sender: UIButton) {
        if let url = URL(string: "https://freesound.org") {
            UIApplication.shared.open(url)
        }
    }
}
