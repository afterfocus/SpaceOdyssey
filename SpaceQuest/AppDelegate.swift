//
//  AppDelegate.swift
//  SpaceQuest
//
//  Created by Максим Голов on 16.11.2020.
//

import UIKit
import YandexMapsMobile

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        YMKMapKit.setApiKey("7ab269af-7c79-4c99-bb21-9afad48c1db9")
        
        UserDefaults.standard.register(defaults: [ "isFirstTimeLaunched": true,
                                                   "isMapNightModeEnabled": true ])
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
}

