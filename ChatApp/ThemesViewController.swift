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
    weak var conversationsVC: ConversationsListViewController? // Если не прописать weak у delegate, то у нас появится цикл. Делегат ссылается на предущий экран, а тот на нынешний.
//    ConversationsListViewController создает ThemesViewController, а затем устанавливает себя в качестве делегата ThemesViewController.
    var handler: ((Theme) -> ())? // Если не прописать weak self в замыкании, то у нас будет сильная ссылка на предыдущий контроллер в этом контроллере (замыкании), а в предыдущем ссылка на замыкание
    
    @IBOutlet weak var classicThemeView: UIView?
    @IBOutlet weak var classicMessagesView: UIView?
    @IBOutlet weak var dayThemeView: UIView?
    @IBOutlet weak var dayMessagesView: UIView?
    @IBOutlet weak var nightThemeView: UIView?
    @IBOutlet weak var nightMessagesView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(restoreSettings))
        
        makeRoundCorners(for: classicMessagesView)
        makeRoundCorners(for: dayMessagesView)
        makeRoundCorners(for: nightMessagesView)
        
        let gestureRecognizerClassic = UITapGestureRecognizer(target: self, action: #selector(changeToClassic))
        classicThemeView?.addGestureRecognizer(gestureRecognizerClassic)
        
        let gestureRecognizerDay = UITapGestureRecognizer(target: self, action: #selector(changeToDay))
        dayThemeView?.addGestureRecognizer(gestureRecognizerDay)
        
        let gestureRecognizerNight = UITapGestureRecognizer(target: self, action: #selector(changeToNight))
        nightThemeView?.addGestureRecognizer(gestureRecognizerNight)
        
        selectThemeView(theme: lastTheme)
    }
    
    func makeRoundCorners(for view: UIView?) {
        if let view = view {
            view.layer.cornerRadius = 14
            for subview in view.subviews {
                subview.layer.cornerRadius = 7
            }
        }
    }
    
    @objc func restoreSettings() {
        switch lastTheme {
        case .classic:
            changeToClassic()
        case .day:
            changeToDay()
        case .night:
            changeToNight()
        }
        saveSettings()
        navigationController?.popViewController(animated: true)
        changeDelegateTheme()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        changeDelegateTheme()
//        handler!(currentTheme)
    }
    
    func saveSettings() {
        userDefaultsManager.setValue(currentTheme.rawValue, forKey: themeKeyIdentifier)
    }
    
    func selectThemeView(theme: Theme) {
        deselectAllThemeViews()
        let themeView: UIView?
        switch theme {
        case .classic:
            themeView = classicMessagesView
        case .day:
            themeView = dayMessagesView
        case .night:
            themeView = nightMessagesView
        }
        guard let view = themeView else { return }
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1).cgColor
    }
    
    func deselectAllThemeViews() {
        classicMessagesView?.layer.borderWidth = 0
        dayMessagesView?.layer.borderWidth = 0
        nightMessagesView?.layer.borderWidth = 0
    }
    
    @objc func changeToClassic() {
        self.view.backgroundColor = UIColor(named: "classicColor")
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        selectThemeView(theme: .classic)
        currentTheme = .classic
        saveSettings()
    }
    
    @objc func changeToDay() {
        self.view.backgroundColor = UIColor(named: "dayColor")
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        selectThemeView(theme: .day)
        currentTheme = .day
        saveSettings()
    }
    
    @objc func changeToNight() {
        self.view.backgroundColor = UIColor(named: "nightColor")
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        selectThemeView(theme: .night)
        currentTheme = .night
        saveSettings()
    }
    
    func changeDelegateTheme() {
        switch currentTheme {
        case .classic:
            conversationsVC?.changeToClassic()
        case .day:
            conversationsVC?.changeToDay()
        case .night:
            conversationsVC?.changeToNight()
        }
    }
}
