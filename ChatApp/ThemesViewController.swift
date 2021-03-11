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

let themeKeyIdentifier = "theme"

let userDefaultsManager = UserDefaults.standard

func getSavedTheme() -> Theme {
    return Theme(rawValue: userDefaultsManager.string(forKey: themeKeyIdentifier) ?? "classic") ?? Theme.classic
}

class ThemesViewController: UIViewController {
    let lastTheme: Theme = getSavedTheme()
    var currentTheme: Theme = getSavedTheme()
    
    @IBOutlet weak var classicThemeView: UIView?
    @IBOutlet weak var dayThemeView: UIView?
    @IBOutlet weak var nightThemeView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(restoreSettings))
        
        makeRoundCorners(for: classicThemeView)
        makeRoundCorners(for: dayThemeView)
        makeRoundCorners(for: nightThemeView)
        
        let gestureRecognizerClassic = UITapGestureRecognizer(target: self, action: #selector(changeToClassic))
        classicThemeView?.addGestureRecognizer(gestureRecognizerClassic)
        
        let gestureRecognizerDay = UITapGestureRecognizer(target: self, action: #selector(changeToDay))
        dayThemeView?.addGestureRecognizer(gestureRecognizerDay)
        
        let gestureRecognizerNight = UITapGestureRecognizer(target: self, action: #selector(changeToNight))
        nightThemeView?.addGestureRecognizer(gestureRecognizerNight)
    }
    
    func makeRoundCorners(for view: UIView?) {
        if let subviews = view?.subviews {
            for subview in subviews {
                if subview.tag == 1 {
                    subview.layer.cornerRadius = 14
                    for sub in subview.subviews {
                        sub.layer.cornerRadius = 10
                    }
                }
            }
        }
    }
    
    @objc func restoreSettings() {
        switch lastTheme {
        case .classic:
            print("classic theme chosen")
        case .day:
            print("day theme chosen")
        case .night:
            print("night theme chosen")
        }
        navigationController?.popViewController(animated: true)
    }
    
    func saveSettings() {
        userDefaultsManager.setValue(currentTheme, forKey: themeKeyIdentifier)
    }
    
    @objc func changeToClassic() {
        print("classic theme chosen")
    }
    
    @objc func changeToDay() {
        print("day theme chosen")
    }
    
    @objc func changeToNight() {
        print("night theme chosen")
    }
}
