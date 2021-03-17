//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 24.02.2021.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

//    MARK: - Outlets
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
    /*
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print(editButtonView.frame)
     // мы не можем здесь переопределить init, так как у нас нет данных о storyboard для загрузка нужного ViewController'а. Соответственно и распечатать editButtonView.frame мы не можем  
    }
     */
    
//    MARK: - Variables
    
    private let buttonCornerRadius: CGFloat = 14
    private let userImageViewCornerRadius: CGFloat = 120
    var theme: Theme = .classic
    private var isEditingUserData = false
    private var isImageChanged = false {
        didSet {
            if isImageChanged == true && !isEditingUserData {
                toggleSaveButtonsAlpha()
                changeButtonText(buttonView: editButtonView, text: "Cancel")
            }
        }
    }
    private var isAvatarGenerated = false
    private var imageToRecover: UIImage?
    private var userToRecover: User?
    
//    MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("\nView did load : \(#function)")

        editButtonView?.layer.cornerRadius = buttonCornerRadius
        saveGCDButtonView?.layer.cornerRadius = buttonCornerRadius
        saveOperationsButtonView?.layer.cornerRadius = buttonCornerRadius
        saveGCDButtonView?.isHidden = true
        saveOperationsButtonView?.isHidden = true
        userImageView?.layer.cornerRadius = userImageViewCornerRadius
        
        let userImageRec = UITapGestureRecognizer(target: self, action: #selector(userImageTapped))
        userImageView?.addGestureRecognizer(userImageRec)
        
        switch theme {
        case .classic:
            changeToClassic()
        case .day:
            changeToDay()
        case .night:
            changeToNight()
        }
        
        let editRec = UITapGestureRecognizer(target: self, action: #selector(editButtonTapped))
        editButtonView?.addGestureRecognizer(editRec)
        let saveGCDRec = UITapGestureRecognizer(target: self, action: #selector(saveGCDTapped))
        saveGCDButtonView?.addGestureRecognizer(saveGCDRec)
        let saveOperationsRec = UITapGestureRecognizer(target: self, action: #selector(saveOperationsTapped))
        saveOperationsButtonView?.addGestureRecognizer(saveOperationsRec)
        
        putPlaceholder(to: userDetailsTextView, placeholder: "Bio")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        userDetailsHeightEquals?.isActive = false
        userDetailsHeightGreater?.isActive = true
        
        saveActivityIndicator?.hidesWhenStopped = true
                        
//        guard let frame = editButtonView?.frame else { return }
//        print(frame)
    }
    
//    MARK: - OnTapFunctions
    
    @objc func saveGCDTapped() {
        toggleSaveButtonsAlpha()
        saveActivityIndicator?.startAnimating()
        
        let saver = GCDSavingManager()
        
        if isEditingUserData || isAvatarGenerated {
            if isEditingUserData {
                toggleUserDetailsHeight()
                userDetailsTextView?.isEditable = false
                userNameTextField?.isUserInteractionEnabled = false
                isEditingUserData = false
                changeUserImageLabel()
            }
            
            guard let name = userNameTextField?.text else { return }
            guard let description = userDetailsTextView?.text else { return }
            let curUser: User = User(name: name, description: description, isOnline: true, prefersGeneratedAvatar: isAvatarGenerated)
            
            saver.saveUser(user: curUser) { [weak self] (error) in
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
                print("success")
                self?.isImageChanged = false
                self?.changeButtonText(buttonView: self?.editButtonView, text: "Edit")
                self?.saveActivityIndicator?.stopAnimating()
            }
        }
        
        if isImageChanged && !isAvatarGenerated {
            if let image = userImage?.image {
                if let imageData = image.jpegData(compressionQuality: 1) {
                    saver.saveImage(of: imageData, completion: { [weak self] error in
                        if let error = error {
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
                        } else {
                            print("done with saving image")
                            self?.isImageChanged = false
                            self?.changeButtonText(buttonView: self?.editButtonView, text: "Edit")
                            self?.saveActivityIndicator?.stopAnimating()
                        }
                    })
                }
            }
        }
    }
    
    @objc func saveOperationsTapped() {
        toggleSaveButtonsAlpha()
        saveActivityIndicator?.startAnimating()
        
        let saver = GCDSavingManager()
        
        if isEditingUserData || isAvatarGenerated {
            if isEditingUserData {
                toggleUserDetailsHeight()
                userDetailsTextView?.isEditable = false
                userNameTextField?.isUserInteractionEnabled = false
                isEditingUserData = false
                changeUserImageLabel()
            }
            
            guard let name = userNameTextField?.text else { return }
            guard let description = userDetailsTextView?.text else { return }
            let curUser: User = User(name: name, description: description, isOnline: true, prefersGeneratedAvatar: isAvatarGenerated)
            
            let saver = OperationsSavingManager()
            saver.saveUser(user: curUser) { [weak self] (result) in
                if let result = result {
                    switch result {
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
                } else {
                    print("done")
                }
                
                self?.saveActivityIndicator?.stopAnimating()
            }
        }
            
        if isImageChanged && !isAvatarGenerated {
            if let image = userImage?.image {
                if let imageData = image.jpegData(compressionQuality: 1) {
                    saver.saveImage(of: imageData, completion: { [weak self] error in
                        if let error = error {
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
                        } else {
                            print("done with saving image")
                            self?.isImageChanged = false
                            self?.changeButtonText(buttonView: self?.editButtonView, text: "Edit")
                            self?.saveActivityIndicator?.stopAnimating()
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func closeProfile(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func editButtonTapped() {
        if !isEditingUserData && !isImageChanged {
            toggleUserDetailsHeight()
            saveBackup()
            isEditingUserData = true
            changeButtonText(buttonView: editButtonView, text: "Cancel")
            userDetailsTextView?.isEditable = true
            toggleSaveButtonsAlpha()
            
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
            changeButtonText(buttonView: editButtonView, text: "Edit")
            toggleSaveButtonsAlpha()
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
            toggleUserDetailsHeight()
            isEditingUserData = false
            isImageChanged = false
            toggleSaveButtonsAlpha()
            changeButtonText(buttonView: editButtonView, text: "Edit")
            userDetailsTextView?.isEditable = false
            userNameTextField?.isUserInteractionEnabled = false
            recoverUserData()
        }
    }
    
    @objc func userImageTapped(_ sender: UITapGestureRecognizer) {
        saveBackup()
        let ac = UIAlertController(title: "Where do you want to take a photo from?", message: "Choose from variants", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Find in a gallery", style: .default, handler: { (action) in
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        }))
        let cameraAction = UIAlertAction(title: "Take a photo", style: .default, handler: { (action) in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        })
        cameraAction.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        let generateAvatarAction = UIAlertAction(title: "Generated avatar", style: .default, handler: { [weak self] (action) in
            self?.imageToRecover = self?.userImage?.image
            self?.userImage?.image = nil
            self?.userImageLabel?.isHidden = false
            self?.isImageChanged = true
            self?.isAvatarGenerated = true
            self?.changeUserImageLabel()
        })
        generateAvatarAction.isEnabled = !isAvatarGenerated
        
        ac.addAction(generateAvatarAction)
        ac.addAction(cameraAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        userImageLabel?.isHidden = true
        imageToRecover = userImage?.image
        userImage?.image = image
        isImageChanged = true
        self.isAvatarGenerated = false
        
        dismiss(animated: true)
    }
    
//    MARK: - Theme change
    
    func changeToClassic() {
        self.view.backgroundColor = .white
        userNameTextField?.textColor = .black
        userDetailsTextView?.textColor = .black
        userDetailsTextView?.backgroundColor = .white
        profileLabel?.textColor = .black
        editButtonView?.backgroundColor = .lightGray
        saveGCDButtonView?.backgroundColor = .lightGray
        saveOperationsButtonView?.backgroundColor = .lightGray
    }
    
    func changeToDay() {
        self.view.backgroundColor = .white
        userNameTextField?.textColor = .black
        userDetailsTextView?.textColor = .black
        userDetailsTextView?.backgroundColor = .white
        profileLabel?.textColor = .black
        editButtonView?.backgroundColor = .lightGray
        saveGCDButtonView?.backgroundColor = .lightGray
        saveOperationsButtonView?.backgroundColor = .lightGray
    }
    
    func changeToNight() {
        self.view.backgroundColor = .black
        userNameTextField?.textColor = .white
        userDetailsTextView?.textColor = .white
        userDetailsTextView?.backgroundColor = .black
        profileLabel?.textColor = .white
        editButtonView?.backgroundColor = .darkGray
        saveGCDButtonView?.backgroundColor = .darkGray
        saveOperationsButtonView?.backgroundColor = .darkGray
    }
    
//    MARK: - Helping Functions
    func saveBackup() {
        guard let name = userNameTextField?.text else { return }
        guard let description = userDetailsTextView?.text else { return }
        userToRecover = User(name: name, description: description, isOnline: true, prefersGeneratedAvatar: isAvatarGenerated)
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
    
    func toggleUserDetailsHeight() {
        userDetailsHeightEquals?.isActive.toggle()
        userDetailsHeightGreater?.isActive.toggle()
    }
    
    func changeButtonText(buttonView: UIView?, text: String) {
        guard let subviews = buttonView?.subviews else { return }
        for subview in subviews {
            if subview.tag == 1 {
                guard let label: UILabel = subview as? UILabel else { return }
                label.text = text
            }
        }
    }
    
    func putPlaceholder(to textView: UITextView?, placeholder: String) {
        textView?.textColor = .lightGray
        textView?.text = placeholder
    }
    
    func toggleSaveButtonsAlpha() {
        saveGCDButtonView?.isHidden.toggle()
        saveOperationsButtonView?.isHidden.toggle()
    }
    
    func setDefault() {
        saveActivityIndicator?.stopAnimating()
        userImageLabel?.isHidden = false
        userImageView?.isHidden = false
        userNameTextField?.isHidden = false
        userDetailsTextView?.isHidden = false
        userImageLabel?.text = "HI"
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
    
//    MARK: - RestoringData
    
    func getUserData() {
        let saver = GCDSavingManager()
//        let saver = OperationsSavingManager()
        
        saver.getUserData { [weak self] (user, data, error) in
            if let error = error {
                print(error.localizedDescription)
                self?.setDefault()
            } else {
                DispatchQueue.main.async {
                    self?.userNameTextField?.text = user?.getName()
                    self?.userDetailsTextView?.text = user?.getDescription()
                    guard let data = data else { return }
                    self?.userImage?.image = UIImage(data: data)
//                    sleep(3)
                    self?.saveActivityIndicator?.stopAnimating()
                    self?.userImageView?.isHidden = false
                    self?.userNameTextField?.isHidden = false
                    self?.userDetailsTextView?.isHidden = false
                    guard let generatedAva = user?.getPrefersGeneratedAvatar() else { return }
                    self?.isAvatarGenerated = generatedAva
                    if generatedAva {
                        self?.userImage?.image = nil
                        self?.userImageLabel?.isHidden = false
                        self?.changeUserImageLabel()
                    } else {
                        self?.userImageLabel?.isHidden = true
                    }
                }
            }
        }
    }
    
//    MARK: - ViewController LifeCycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("\nView did appear : \(#function)")
//        guard let frame = editButtonView?.frame else { return }
        //print(frame) // frame отличается, так как изначально во время метода viewDidLoad создаётся интерфейс для iPhoneSE(2nd generation), так как он указан в storyboard, но симулятор запускается на iPhone 11 Pro с другим разрешением экрана, соответственно мы получаем новое значение origin для сохранения констрейнтов и положения кнопки. То есть на момент вызова метода viewDidLoad наш view еще не добавлен на UIWindow, соответственно корректной информации по размерам получить мы не можем.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("\nView will appear : \(#function)")
        
        saveActivityIndicator?.startAnimating()
        userImageView?.isHidden = true
        userNameTextField?.isHidden = true
        userDetailsTextView?.isHidden = true
        getUserData()
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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NSLog("\nView did disappear : \(#function)")
    }
}

// MARK: - Extensions

extension ProfileViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            putPlaceholder(to: textView, placeholder: "Bio")
        }
    }
}

extension ProfileViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
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
