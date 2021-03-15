//
//  AppDelegate.swift
//  SpaceQuest
//
//  Created by Максим Голов on 16.11.2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        DataModel.setYandexMapsAPIKey()
        
        if DataModel.isLoggedIn {
            DataModel.logIn()
        }
        
        // "TabBarController"
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controlledIdentifier = DataModel.isLoggedIn ? "LaunchController" : "LoginController"
        let initialViewController = storyboard.instantiateViewController(withIdentifier: controlledIdentifier)
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if DataModel.isLoggedIn {
            DataModel.current.saveToFile()
        }
    }
}

