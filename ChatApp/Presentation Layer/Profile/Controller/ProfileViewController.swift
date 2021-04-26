//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 24.02.2021.
//

import UIKit

class ProfileViewController: UIViewController {
// MARK: - Outlets
    
    @IBOutlet weak var editButtonView: UIView?
    @IBOutlet weak var userNameTextField: UITextField?
    @IBOutlet weak var userDetailsTextView: UITextView?
    @IBOutlet var userDetailsHeightEquals: NSLayoutConstraint?
    @IBOutlet var userDetailsHeightGreater: NSLayoutConstraint?
    @IBOutlet weak var userImageView: UIView?
    @IBOutlet weak var userImage: UIImageView?
    @IBOutlet weak var userImageLabel: UILabel?
    @IBOutlet weak var profileLabel: UILabel?
    @IBOutlet weak var saveGCDButtonView: UIView?
    @IBOutlet weak var saveActivityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var saveImageCheckmark: UIImageView?
// MARK: - Variables

    private let buttonCornerRadius: CGFloat = 14
    private let userImageViewCornerRadius: CGFloat = 120
    var theme: Theme = .classic
    var isEditingUserData = false
    var isImageChanged = false {
        didSet {
            if isImageChanged == true && !isEditingUserData {
//                UIHelper.toggleSaveButtonAlpha()
//                saveImageCheckmark?.image = UIImage(named: "pencil")
//                UIHelper.changeButtonText(buttonView: editButtonView, text: "Cancel")
            }
        }
    }
    weak var delegate: ConversationsListViewController?
    var isAvatarGenerated = true
    var imageToRecover: UIImage?
    var userToRecover: User?
    var isSaving = false
    var isSavingCancelled = false
    private var themeChanger: ProfileThemeChanger = ProfileThemeChanger()

    let gcdSaver = GCDSavingManager()
    var dataService: IDataService?
    var alertPresenter: AlertPresenter?
    
    var state: State?
// MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        state = SavedState(profileVC: self)
        UIHelper.viewControl = self
        self.setUpUserData()
        self.alertPresenter = AlertPresenter(profileVC: self)

        NSLog("\nView did load : \(#function)")
        editButtonView?.layer.cornerRadius = buttonCornerRadius
        saveGCDButtonView?.layer.cornerRadius = buttonCornerRadius
        userImageView?.layer.cornerRadius = userImageViewCornerRadius
        let userImageRec = UITapGestureRecognizer(target: self, action: #selector(userImageTapped))
        userImageView?.addGestureRecognizer(userImageRec)
        switch theme {
        case .classic:
            themeChanger.changeToClassic()
        case .day:
            themeChanger.changeToDay()
        case .night:
            themeChanger.changeToNight()
        }
        let editRec = UITapGestureRecognizer(target: self, action: #selector(editButtonTapped))
        editButtonView?.addGestureRecognizer(editRec)
        let saveGCDRec = UITapGestureRecognizer(target: self, action: #selector(saveGCDTapped))
        saveGCDButtonView?.addGestureRecognizer(saveGCDRec)
        if userDetailsTextView?.text == "" {
            UIHelper.putPlaceholder(to: userDetailsTextView, placeholder: "Bio")
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        self.userImage?.contentMode = .scaleAspectFill
    }
// MARK: - OnTapFunctions
    
    private let concurrentSaveQueue = DispatchQueue(label: "ru.tinkoff.save", attributes: .concurrent)

    fileprivate func saveUser() {
        if isEditingUserData || isImageChanged {
            if isEditingUserData {
                userDetailsTextView?.isEditable = false
                userNameTextField?.isUserInteractionEnabled = false
                isEditingUserData = false
                changeUserImageLabel()
            }
            guard let name = userNameTextField?.text else { return }
            guard let description = userDetailsTextView?.text else { return }
            let curUser: User = User(name: name,
                                     description: description,
                                     isOnline: true,
                                     prefersGeneratedAvatar: isAvatarGenerated)
            dataService?.saveUser(user: curUser) { [weak self] (error) in
                if let error = error {
                    self?.showFailureAlert()
                    self?.processError(error: error)
                }
                self?.saveSuccessfullyCompleted()
            }
        }
        
        func saveImage(imageData: Data) {
            dataService?.saveImage(imageData: imageData, completion: { [weak self] error in
                if let error = error {
                    self?.showFailureAlert()
                    self?.processError(error: error)
                }
                self?.saveImageInConcurrent()
            })
        }
    }
    
    private func processError(error: FileOperationError) {
        switch error {
        case .unspecified:
            print("unspecified")
        case .badDirCreation:
            print("badDirCreation")
        case .badFileCreation:
            print("badFileCreation")
        case .badWritingOperation:
            print("badWritingOperation")
        case .badReadingOperation:
            print("badReadingOperation")
        }
    }
    
    private func saveUserInConcurrent() {
        self.concurrentSaveQueue.async { [weak self] in
            guard let isImageChanged = self?.isImageChanged else { return }
            guard let isAvatarGenerated = self?.isAvatarGenerated else { return }
            if !isImageChanged && !isAvatarGenerated {
                self?.saveSuccessfullyCompleted()
            } else if isAvatarGenerated {
                self?.saveSuccessfullyCompleted()
            } else {
                self?.isImageChanged = false
            }
        }
    }
    
    private func saveImageInConcurrent() {
        concurrentSaveQueue.async {
            if self.isImageChanged {
                self.saveSuccessfullyCompleted()
            } else {
                self.isImageChanged = false
            }
        }
    }

    fileprivate func saveImage() {
        if isImageChanged && !isAvatarGenerated {
            if let image = userImage?.image {
                if let imageData = image.jpegData(compressionQuality: 1) {
                    dataService?.saveImage(imageData: imageData) { [weak self] error in
                        if error != nil {
                            if let vc = self {
                                vc.state = EditingState(profileVC: vc)
                                vc.showFailureAlert()
                            }
                            
                        }
                        if let vc = self {
                            vc.state = SavedState(profileVC: vc)
                            self?.saveSuccessfullyCompleted()
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func saveSuccessfullyCompleted() {
        DispatchQueue.main.async { [weak self] in
            if let vc = self {
                vc.state = SavedState(profileVC: vc)
                vc.showSuccessAlert()
            }
        }
    }

    @objc func saveGCDTapped() {
        state?.saveTapped()
    }
    
    func saveData() {
        saveUser()
        saveImage()
    }
    
    @IBAction func closeProfile(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc func editButtonTapped() {
        state?.editTapped()
    }
// MARK: - Helping Functions
    
    func changeButtonText(buttonView: UIView?, text: String) {
        UIHelper.changeButtonText(buttonView: buttonView, text: text)
    }

    func saveBackup() {
        guard let name = userNameTextField?.text else { return }
        guard let description = userDetailsTextView?.text else { return }
        userToRecover = User(name: name,
                             description: description,
                             isOnline: true,
                             prefersGeneratedAvatar: isAvatarGenerated)
    }

    func recoverUserData() {
        isAvatarGenerated = userToRecover?.getPrefersGeneratedAvatar() ?? true
        if isImageChanged || !isAvatarGenerated {
            userImage?.image = imageToRecover
        }
        userNameTextField?.text = userToRecover?.getName()
        userDetailsTextView?.text = userToRecover?.getDescription()
        if isAvatarGenerated {
            userImageLabel?.isHidden = false
            changeUserImageLabel()
        } else {
            userImageLabel?.isHidden = true
        }
    }

    func changeUserImageLabel() {
        if let userNameData = userNameTextField?.text?.components(separatedBy: " ") {
            if userNameData.count >= 2 {
                guard let firstNameSymbol = userNameData[0].capitalized.first else { return }
                guard let firstSurnameSymbol = userNameData[1].capitalized.first else { return }
                userImageLabel?.text = "\(firstNameSymbol)\(firstSurnameSymbol)"
            } else if userNameData.count == 1 {
                guard let firstNameSymbol = userNameData[0].capitalized.first else { return }
                userImageLabel?.text = "\(firstNameSymbol)"
            }
        }
    }
    
    func cancelGCDSaving() {
        guard let userToRecover = userToRecover else { return }
        gcdSaver.saveUser(user: userToRecover) { _ in }
        guard let data = imageToRecover?.jpegData(compressionQuality: 1) else { return }
        gcdSaver.saveImage(of: data) { _ in }
    }
    
    func showSuccessAlert() {
        self.alertPresenter?.showSuccessAlert()
    }

    func showCancelAlert() {
        self.alertPresenter?.showCancelAlert()
    }

    func showFailureAlert() {
        self.alertPresenter?.showFailureAlert()
    }
// MARK: - RestoringData
    
    func setUpUserData() {
        userNameTextField?.text = userToRecover?.getName()
        userDetailsTextView?.text = userToRecover?.getDescription()
        isAvatarGenerated = userToRecover?.getPrefersGeneratedAvatar() ?? true
        if isAvatarGenerated {
            userImage?.isHidden = false
            userImageLabel?.isHidden = false
            changeUserImageLabel()
        } else {
            userImage?.isHidden = false
            userImageLabel?.isHidden = true
            if let imageToRecover = imageToRecover {
                userImage?.image = imageToRecover
            } else {
                saveImageCheckmark?.isHidden = true
                saveActivityIndicator?.startAnimating()
                userImageView?.isHidden = true
                let manager = GCDSavingManager()
                manager.getImage { [weak self] (data, error) in
                    if let data = data {
                        self?.userImage?.image = UIImage(data: data)
                        self?.userImageView?.isHidden = false
                        self?.saveSuccessfullyCompleted()
                    } else {
                        self?.showFailureAlert()
                        print(error?.localizedDescription as Any)
                    }
                }
            }
        }
    }
}
// MARK: - Extensions

extension ProfileViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            UIHelper.putPlaceholder(to: textView, placeholder: "Bio")
        }
    }
}

extension ProfileViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                                as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

extension ProfileViewController {
// MARK: - ViewController LifeCycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NSLog("\nView will disappear : \(#function)")
        guard let isAnimating = saveActivityIndicator?.isAnimating else { return }
        if isAnimating {
            cancelGCDSaving()
            setUpUserData()
            delegate?.showCancelAlert()
        }
        guard let name = userNameTextField?.text else { return }
        guard let description = userDetailsTextView?.text else { return }
        delegate?.currentUser = User(name: name,
                                     description: description,
                                     isOnline: true,
                                     prefersGeneratedAvatar: isAvatarGenerated,
                                     theme: theme.rawValue)
    }
}
