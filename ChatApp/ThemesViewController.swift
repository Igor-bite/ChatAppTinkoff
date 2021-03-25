//
//  ThemesViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 11.03.2021.
//

import UIKit

enum Theme: String {
    case classic
    case day
    case night
}

class ThemesViewController: UIViewController {
    var lastTheme: Theme?
    var currentTheme: Theme = .classic {
        didSet {
            if currentTheme != lastTheme {
                isThemeChanged = true
            } else {
                isThemeChanged = false
            }
        }
    }
    weak var conversationsVC: ConversationsListViewController?
    var handler: ((Theme) -> Void)?
    var isThemeChanged = false
    @IBOutlet weak var classicThemeView: UIView?
    @IBOutlet weak var classicMessagesView: UIView?
    @IBOutlet weak var dayThemeView: UIView?
    @IBOutlet weak var dayMessagesView: UIView?
    @IBOutlet weak var nightThemeView: UIView?
    @IBOutlet weak var nightMessagesView: UIView?
    @IBOutlet weak var saveButtonView: UIView?
    @IBOutlet weak var saveIndicator: UIActivityIndicatorView?
    @IBOutlet weak var isSavedImage: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                            target: self,
                                                            action: #selector(restoreSettings))
        makeRoundCorners(for: classicMessagesView)
        makeRoundCorners(for: dayMessagesView)
        makeRoundCorners(for: nightMessagesView)
        makeRoundCorners(for: saveButtonView)
        saveIndicator?.hidesWhenStopped = true
        saveIndicator?.stopAnimating()
        isSavedImage?.image = UIImage(named: "checkmark")
        let gestureRecognizerClassic = UITapGestureRecognizer(target: self, action: #selector(changeToClassic))
        classicThemeView?.addGestureRecognizer(gestureRecognizerClassic)
        let gestureRecognizerDay = UITapGestureRecognizer(target: self, action: #selector(changeToDay))
        dayThemeView?.addGestureRecognizer(gestureRecognizerDay)
        let gestureRecognizerNight = UITapGestureRecognizer(target: self, action: #selector(changeToNight))
        nightThemeView?.addGestureRecognizer(gestureRecognizerNight)
        let saveGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(saveUserTheme))
        saveButtonView?.addGestureRecognizer(saveGestureRecognizer)
        guard let lastTheme = lastTheme else { return }
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
        isThemeChanged = false
        guard let lastTheme = lastTheme else { return }
        switch lastTheme {
        case .classic:
            changeToClassic()
        case .day:
            changeToDay()
        case .night:
            changeToNight()
        }
        saveUserTheme()
        navigationController?.popViewController(animated: true)
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
        view.layer.borderColor = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1).cgColor
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
    }

    @objc func changeToDay() {
        self.view.backgroundColor = UIColor(named: "dayColor")
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        selectThemeView(theme: .day)
        currentTheme = .day
    }

    @objc func changeToNight() {
        self.view.backgroundColor = UIColor(named: "nightColor")
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        selectThemeView(theme: .night)
        currentTheme = .night
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

    @objc func saveUserTheme() {
        changeDelegateTheme()
//        handler?(currentTheme)
        let saver = GCDSavingManager()
//        let saver = OperationsSavingManager()
        saveIndicator?.startAnimating()
        isSavedImage?.isHidden = true
        saver.saveTheme(theme: currentTheme) { [weak self] (error) in
            if let error = error {
                switch error {
                case .badDirCreation:
                    print("dir creation problems")
                    return
                case .badFileCreation:
                    print("file creation problems")
                    return
                case .unspecified:
                    print("unspecified problem")
                    return
                case .badWritingOperation:
                    print("badWritingOperation")
                    return
                case .badReadingOperation:
                    print("badReadingOperation")
                    return
                }
            }
            sleep(3)
            self?.isSavedImage?.isHidden = false
            self?.saveIndicator?.stopAnimating()
        }
    }
}
