//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 15.02.2021.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        NSLog("\nApplication moved from active to inactive state: \(#function)")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        NSLog("\nApplication moved from active to background state: \(#function)")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        NSLog("\nApplication moved from background to active state: \(#function)")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        NSLog("\nApplication moved from inactive to active state: \(#function)")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        NSLog("\nApplication moved from active to inactive state: \(#function)")
    }
}
