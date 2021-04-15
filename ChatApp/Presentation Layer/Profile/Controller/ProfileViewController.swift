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
    @IBOutlet weak var saveOperationsButtonView: UIView?
    @IBOutlet weak var saveActivityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var saveImageCheckmark: UIImageView?

// MARK: - Variables

    private let buttonCornerRadius: CGFloat = 14
    private let userImageViewCornerRadius: CGFloat = 120
    var theme: Theme = .classic
    private var isEditingUserData = false
    var isImageChanged = false {
        didSet {
            if isImageChanged == true && !isEditingUserData {
                UIHelper.toggleSaveButtonsAlpha()
                saveImageCheckmark?.image = UIImage(named: "pencil")
                UIHelper.changeButtonText(buttonView: editButtonView, text: "Cancel")
            }
        }
    }
    weak var delegate: ConversationsListViewController?
    var isAvatarGenerated = true
    var imageToRecover: UIImage?
    var userToRecover: User?
    var isGCD = true
    var isSaving = false
    var isSavingCancelled = false
    private var themeChanger: ProfileThemeChanger = ProfileThemeChanger()

    let gcdSaver = GCDSavingManager()
    let operationsSaver = OperationsSavingManager()
    let saveService = SavingService()
// MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        UIHelper.viewControl = self
        themeChanger.profileVC = self
        saveService.profileVC = self

        NSLog("\nView did load : \(#function)")
        editButtonView?.layer.cornerRadius = buttonCornerRadius
        saveGCDButtonView?.layer.cornerRadius = buttonCornerRadius
        saveOperationsButtonView?.layer.cornerRadius = buttonCornerRadius
        saveGCDButtonView?.isHidden = true
        saveOperationsButtonView?.isHidden = true
        userImageView?.layer.cornerRadius = userImageViewCornerRadius
        saveImageCheckmark?.image = UIImage(named: "checkmark")
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
        let saveOperationsRec = UITapGestureRecognizer(target: self, action: #selector(saveOperationsTapped))
        saveOperationsButtonView?.addGestureRecognizer(saveOperationsRec)
        UIHelper.putPlaceholder(to: userDetailsTextView, placeholder: "Bio")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        userDetailsHeightEquals?.isActive = false
        userDetailsHeightGreater?.isActive = true
    }
// MARK: - OnTapFunctions

    fileprivate func saveUser(with saver: ISaver) {
        if isEditingUserData || isImageChanged {
            if isEditingUserData {
                UIHelper.toggleUserDetailsHeight()
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
            saveService.saveUser(user: curUser)
        }
    }

    fileprivate func saveImage(with saver: ISaver) {
        if isImageChanged && !isAvatarGenerated {
            if let image = userImage?.image {
                if let imageData = image.jpegData(compressionQuality: 1) {
                    saveService.saveImage(imageData: imageData)
                }
            }
        }
    }

    @objc func saveGCDTapped() {
        isSaving = true
        isGCD = true
        UIHelper.toggleSaveButtonsAlpha()
        saveImageCheckmark?.isHidden = true
        saveActivityIndicator?.startAnimating()
        saveUser(with: gcdSaver)
        saveImage(with: gcdSaver)
    }

    @objc func saveOperationsTapped() {
        isSaving = true
        isGCD = false
        UIHelper.toggleSaveButtonsAlpha()
        saveImageCheckmark?.isHidden = true
        saveActivityIndicator?.startAnimating()
        saveUser(with: operationsSaver)
        saveImage(with: operationsSaver)
    }

    @IBAction func closeProfile(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc func editButtonTapped() {
        if isSaving {
            cancelSaving()
            return
        }
        if !isEditingUserData && !isImageChanged {
            UIHelper.toggleUserDetailsHeight()
            saveBackup()
            isEditingUserData = true
            saveImageCheckmark?.image = UIImage(named: "pencil")
            UIHelper.changeButtonText(buttonView: editButtonView, text: "Cancel")
            userDetailsTextView?.isEditable = true
            UIHelper.toggleSaveButtonsAlpha()
            switch theme {
            case .classic:
                userDetailsTextView?.textColor = .black
            case .day:
                userDetailsTextView?.textColor = .black
            case .night:
                userDetailsTextView?.textColor = .white
            }
            userNameTextField?.isUserInteractionEnabled = true
            userNameTextField?.becomeFirstResponder()
            guard let end = userNameTextField?.endOfDocument else { return }
            userNameTextField?.selectedTextRange = userNameTextField?.textRange(from: end, to: end)
        } else if !isEditingUserData && isImageChanged {
            saveImageCheckmark?.image = UIImage(named: "checkmark")
            UIHelper.changeButtonText(buttonView: editButtonView, text: "Edit")
            UIHelper.toggleSaveButtonsAlpha()
            userImage?.image = imageToRecover
            userImageLabel?.isHidden = true
            isImageChanged = false
            isAvatarGenerated = userToRecover?.getPrefersGeneratedAvatar() ?? true
            if isAvatarGenerated {
                userImageLabel?.isHidden = false
            } else {
                userImageLabel?.isHidden = true
            }
            recoverUserData()
        } else {
            UIHelper.toggleUserDetailsHeight()
            isEditingUserData = false
            isImageChanged = false
            UIHelper.toggleSaveButtonsAlpha()
            saveImageCheckmark?.image = UIImage(named: "checkmark")
            UIHelper.changeButtonText(buttonView: editButtonView, text: "Edit")
            userDetailsTextView?.isEditable = false
            userNameTextField?.isUserInteractionEnabled = false
            recoverUserData()
        }
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

    func cancelSaving() {
        isSavingCancelled = true
        if isGCD {
            cancelGCDSaving()
        } else {
            cancelOperationsSaving()
        }
        setUpUserData()
        showCancelAlert()
    }

    func cancelGCDSaving() {
        guard let userToRecover = userToRecover else { return }
        gcdSaver.saveUser(user: userToRecover) { _ in }
        guard let data = imageToRecover?.jpegData(compressionQuality: 1) else { return }
        gcdSaver.saveImage(of: data) { _ in }
    }

    func cancelOperationsSaving() {
        operationsSaver.cancel()
        guard let userToRecover = userToRecover else { return }
        operationsSaver.saveUser(user: userToRecover) { _ in }
        guard let data = imageToRecover?.jpegData(compressionQuality: 1) else { return }
        operationsSaver.saveImage(of: data) { _ in }
    }

// MARK: - RestoringData
    func setUpUserData() {
        saveImageCheckmark?.image = UIImage(named: "checkmark")
        saveImageCheckmark?.isHidden = false
        UIHelper.changeButtonText(buttonView: editButtonView, text: "Edit")
        userImageView?.isHidden = true
        userNameTextField?.text = userToRecover?.getName()
        userDetailsTextView?.text = userToRecover?.getDescription()
        isAvatarGenerated = userToRecover?.getPrefersGeneratedAvatar() ?? true
        userImageView?.isHidden = false
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
//                let manager = OperationsSavingManager()
                manager.getImage { [weak self] (data, error) in
                    if let data = data {
                        self?.userImage?.image = UIImage(data: data)
                        self?.userImageView?.isHidden = false
                        self?.saveImageCheckmark?.isHidden = false
                        self?.saveImageCheckmark?.image = UIImage(named: "checkmark")
                        UIHelper.changeButtonText(buttonView: self?.editButtonView, text: "Edit")
                        self?.saveActivityIndicator?.stopAnimating()
                        self?.showSuccessAlert()
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

    func showSuccessAlert() {
        let alertControl = UIAlertController(title: "Данные сохранены",
                                   message: nil,
                                   preferredStyle: .alert)
        alertControl.addAction(UIAlertAction(title: "Ок", style: .default, handler: {_ in }))
        isSaving = false
        if !isSavingCancelled {
            isSavingCancelled = false
            present(alertControl, animated: true)
            delegate?.userImage = userImage?.image
        }
    }

    func showCancelAlert() {
        let alertControl = UIAlertController(title: "Изменения профиля отменены",
                                   message: nil,
                                   preferredStyle: .alert)
        alertControl.addAction(UIAlertAction(title: "Ок",
                                   style: .default,
                                   handler: {_ in }))
        present(alertControl, animated: true)
    }

    func showFailureAlert() {
        let alertControl = UIAlertController(title: "Ошибка",
                                   message: "Не удалось сохранить данные",
                                   preferredStyle: .alert)
        alertControl.addAction(UIAlertAction(title: "Ок",
                                   style: .default,
                                   handler: {[weak self] _ in
            self?.isSaving = false
            self?.saveActivityIndicator?.stopAnimating()
            self?.setUpUserData()
        }))
        alertControl.addAction(UIAlertAction(title: "Повторить",
                                             style: .default,
                                             handler: {[weak self] _ in
            guard let isGCD = self?.isGCD else { return }
            self?.isImageChanged = true
            self?.isEditingUserData = true
            if isGCD {
                self?.saveGCDTapped()
            } else {
                self?.saveOperationsTapped()
            }
            UIHelper.toggleUserDetailsHeight()
        }))
        if !isSavingCancelled {
            isSavingCancelled = false
            present(alertControl, animated: true)
        }
    }
}

private class UIHelper {
    static weak var viewControl: ProfileViewController?

    static func toggleUserDetailsHeight() {
        viewControl?.userDetailsHeightEquals?.isActive.toggle()
        viewControl?.userDetailsHeightGreater?.isActive.toggle()
    }

    static func changeButtonText(buttonView: UIView?, text: String) {
        guard let subviews = buttonView?.subviews else { return }
        for subview in subviews where subview.tag == 1 {
            guard let label: UILabel = subview as? UILabel else { return }
            label.text = text
        }
    }

    static func putPlaceholder(to textView: UITextView?, placeholder: String) {
        textView?.textColor = .lightGray
        textView?.text = placeholder
    }

    static func toggleSaveButtonsAlpha() {
        viewControl?.saveGCDButtonView?.isHidden.toggle()
        viewControl?.saveOperationsButtonView?.isHidden.toggle()
    }

    static func setDefault() {
        viewControl?.saveImageCheckmark?.isHidden = false
        viewControl?.saveImageCheckmark?.image = UIImage(named: "checkmark")
        changeButtonText(buttonView: viewControl?.editButtonView, text: "Edit")
        viewControl?.saveActivityIndicator?.stopAnimating()
        viewControl?.showSuccessAlert()
        viewControl?.userImageLabel?.isHidden = false
        viewControl?.userImageView?.isHidden = false
        viewControl?.userNameTextField?.isHidden = false
        viewControl?.userDetailsTextView?.isHidden = false
        viewControl?.userImageLabel?.text = "HI"
    }
}

extension ProfileViewController {
// MARK: - ViewController LifeCycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("\nView did appear : \(#function)")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("\nView will appear : \(#function)")
        setUpUserData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        NSLog("\nView will layout subviews : \(#function)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLog("\nView did layout subviews : \(#function)")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NSLog("\nView will disappear : \(#function)")
        guard let isAnimating = saveActivityIndicator?.isAnimating else { return }
        if isAnimating {
            cancelSaving()
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NSLog("\nView did disappear : \(#function)")
    }
}
