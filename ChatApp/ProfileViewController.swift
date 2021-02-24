//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 24.02.2021.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var editButtonView: UIView?
    @IBOutlet weak var userNameLabel: UILabel?
    @IBOutlet weak var userDetailsLabel: UILabel?
    @IBOutlet weak var userImageView: UIView?
    @IBOutlet weak var userImage: UIImageView?
    @IBOutlet weak var userImageLabel: UILabel?
    
    /*
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print(editButtonView.frame)
     // мы не можем здесь переопределить init, так как у нас нет данных о storyboard для загрузка нужного ViewController'а. Соответственно и распечатать editButtonView.frame мы не можем  
    }
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("\nView did load : \(#function)")

        editButtonView?.layer.cornerRadius = 14
        
        userImageView?.layer.cornerRadius = 120
        
        let userImageRec = UITapGestureRecognizer(target: self, action: #selector(userImageTapped))
        userImageView?.addGestureRecognizer(userImageRec)
        
        guard let frame = editButtonView?.frame else { return }
        print(frame)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("\nView did appear : \(#function)")
        guard let frame = editButtonView?.frame else { return }
        print(frame) // frame отличается, так как изначально во время метода viewDidLoad создаётся интерфейс для iPhoneSE(2nd generation), так как он указан в storyboard, но симулятор запускается на iPhone 11 Pro с другим разрешением экрана, соответственно мы получаем новое значение origin для сохранения констрейнтов и положения кнопки. То есть на момент вызова метода viewDidLoad наш view еще не добавлен на UIWindow, соответственно корректной информации по размерам получить мы не можем.
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



