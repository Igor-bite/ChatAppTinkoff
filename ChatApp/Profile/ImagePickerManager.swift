//
//  ImagePickerManager.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 26.03.2021.
//

import Foundation
import UIKit

extension ProfileViewController: UIImagePickerControllerDelegate,
                                 UINavigationControllerDelegate {
    @objc func userImageTapped(_ sender: UITapGestureRecognizer) {
        saveBackup()
        let alertControl = UIAlertController(title: "Where do you want to take a photo from?",
                                   message: "Choose from variants",
                                   preferredStyle: .actionSheet)
        alertControl.addAction(UIAlertAction(title: "Find in a gallery",
                                   style: .default,
                                   handler: { (_) in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        }))
        let cameraAction = UIAlertAction(title: "Take a photo",
                                         style: .default,
                                         handler: { (_) in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        })
        cameraAction.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        let generateAvatarAction = UIAlertAction(title: "Generated avatar",
                                                 style: .default,
                                                 handler: { [weak self] (_) in
            self?.imageToRecover = self?.userImage?.image
            self?.userImage?.image = nil
            self?.userImageLabel?.isHidden = false
            self?.isImageChanged = true
            self?.isAvatarGenerated = true
            self?.changeUserImageLabel()
        })
        generateAvatarAction.isEnabled = !isAvatarGenerated
        alertControl.addAction(generateAvatarAction)
        alertControl.addAction(cameraAction)
        alertControl.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertControl, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        userImageLabel?.isHidden = true
        imageToRecover = userImage?.image
        userImage?.image = image
        self.isAvatarGenerated = false
        isImageChanged = true
        dismiss(animated: true)
    }
}
