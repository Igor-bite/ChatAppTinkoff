//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 24.02.2021.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var editButtonView: UIView?
    @IBOutlet weak var userNameTextField: UITextField?
    @IBOutlet weak var userDetailsTextView: UITextView?
    @IBOutlet weak var userImageView: UIView?
    @IBOutlet weak var userImage: UIImageView?
    @IBOutlet weak var userImageLabel: UILabel?
    @IBOutlet weak var profileLabel: UILabel?
    
    /*
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print(editButtonView.frame)
     // мы не можем здесь переопределить init, так как у нас нет данных о storyboard для загрузка нужного ViewController'а. Соответственно и распечатать editButtonView.frame мы не можем  
    }
     */
    
    let editButtonCornerRadius: CGFloat = 14
    let userImageViewCornerRadius: CGFloat = 120
    var theme: Theme = .classic
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("\nView did load : \(#function)")

        editButtonView?.layer.cornerRadius = editButtonCornerRadius
        
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
        
        putPlaceholder(to: userDetailsTextView, placeholder: "Bio")
                
//        guard let frame = editButtonView?.frame else { return }
//        print(frame)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("\nView did appear : \(#function)")
//        guard let frame = editButtonView?.frame else { return }
        //print(frame) // frame отличается, так как изначально во время метода viewDidLoad создаётся интерфейс для iPhoneSE(2nd generation), так как он указан в storyboard, но симулятор запускается на iPhone 11 Pro с другим разрешением экрана, соответственно мы получаем новое значение origin для сохранения констрейнтов и положения кнопки. То есть на момент вызова метода viewDidLoad наш view еще не добавлен на UIWindow, соответственно корректной информации по размерам получить мы не можем.
    }
    
    @IBAction func closeProfile(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func userImageTapped(_ sender: UITapGestureRecognizer) {
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

        ac.addAction(cameraAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        userImageLabel?.isHidden = true
        userImage?.image = image

        dismiss(animated: true)
    }
    
    func changeToClassic() {
        self.view.backgroundColor = .white
        userNameTextField?.textColor = .black
        userDetailsTextView?.textColor = .black
        userDetailsTextView?.backgroundColor = .white
        profileLabel?.textColor = .black
        editButtonView?.backgroundColor = .lightGray
    }
    
    func changeToDay() {
        self.view.backgroundColor = .white
        userNameTextField?.textColor = .black
        userDetailsTextView?.textColor = .black
        userDetailsTextView?.backgroundColor = .white
        profileLabel?.textColor = .black
        editButtonView?.backgroundColor = .lightGray
    }
    
    func changeToNight() {
        self.view.backgroundColor = .black
        userNameTextField?.textColor = .white
        userDetailsTextView?.textColor = .white
        userDetailsTextView?.backgroundColor = .black
        profileLabel?.textColor = .white
        editButtonView?.backgroundColor = .darkGray
    }

    @objc func editButtonTapped() {
        userDetailsTextView?.isEditable = true
        userDetailsTextView?.textColor = .black
        userDetailsTextView?.text = ""
        
        userNameTextField?.isUserInteractionEnabled = true
        userNameTextField?.becomeFirstResponder()
        guard let end = userNameTextField?.endOfDocument else { return }
        userNameTextField?.selectedTextRange = userNameTextField?.textRange(from: end, to: end)
    }
    
    func putPlaceholder(to textView: UITextView?, placeholder: String) {
        textView?.textColor = .lightGray
        textView?.text = placeholder
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("\nView will appear : \(#function)")
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

extension ProfileViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            putPlaceholder(to: textView, placeholder: "Bio")
        }
    }
}
