//
//  ThemesViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 11.03.2021.
//

import UIKit

enum Theme: String {
    case classic = "classic"
    case day = "day"
    case night = "night"
}

class ThemesViewController: UIViewController {
    let lastTheme: Theme = Theme(rawValue: UserDefaults.standard.string(forKey: "theme") ?? "classic") ?? Theme.classic
    var currentTheme: Theme = Theme(rawValue: UserDefaults.standard.string(forKey: "theme") ?? "classic") ?? Theme.classic

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(restoreSettings))
    }
    
    @objc func restoreSettings() {
        changeTheme(to: lastTheme)
        navigationController?.popViewController(animated: true)
    }
    
    func saveSettings() {
        
    }
    
    func changeTheme(to newTheme: Theme) {
        currentTheme = newTheme
        switch newTheme {
        case .classic:
            print("classic theme chosen")
        case .day:
            print("day theme chosen")
        case .night:
            print("night theme chosen")
        }
        saveSettings()
    }
}
