//
//  SavingService.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 26.03.2021.
//

import Foundation
import UIKit

class SavingService {
    private let gcdSaver = GCDSavingManager()
    private let operationsSaver = OperationsSavingManager()
    private let concurrentSaveQueue = DispatchQueue(label: "ru.tinkoff.save", attributes: .concurrent)
    weak var profileVC: ProfileViewController?
    
    func saveUser(user: User) {
        gcdSaver.saveUser(user: user) { [weak profileVC] (error) in
            if let error = error {
                profileVC?.showFailureAlert()
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
            self.concurrentSaveQueue.async { [weak profileVC] in
                guard let isImageChanged = profileVC?.isImageChanged else { return }
                guard let isAvatarGenerated = profileVC?.isAvatarGenerated else { return }
                if !isImageChanged && !isAvatarGenerated {
                    DispatchQueue.main.async {
                        profileVC?.saveImageCheckmark?.isHidden = false
                        profileVC?.saveActivityIndicator?.stopAnimating()
                        profileVC?.showSuccessAlert()
                        profileVC?.saveImageCheckmark?.image = UIImage(named: "checkmark")
                        profileVC?.changeButtonText(buttonView: profileVC?.editButtonView, text: "Edit")
                    }
                } else if isAvatarGenerated {
                    DispatchQueue.main.async {
                        profileVC?.saveImageCheckmark?.isHidden = false
                        profileVC?.saveActivityIndicator?.stopAnimating()
                        profileVC?.showSuccessAlert()
                        profileVC?.saveImageCheckmark?.image = UIImage(named: "checkmark")
                        profileVC?.changeButtonText(buttonView: profileVC?.editButtonView, text: "Edit")
                    }
                } else {
                    profileVC?.isImageChanged = false
                }
            }
        }
    }
    
    func saveImage(imageData: Data) {
        gcdSaver.saveImage(of: imageData, completion: { [weak profileVC] error in
            if let error = error {
                profileVC?.showFailureAlert()
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
                self.concurrentSaveQueue.async { [weak self] in
                    guard let isImageChanged = self?.profileVC?.isImageChanged else { return }
                    if !isImageChanged {
                        DispatchQueue.main.async {
                            profileVC?.saveImageCheckmark?.isHidden = false
                            profileVC?.saveActivityIndicator?.stopAnimating()
                            profileVC?.showSuccessAlert()
                            profileVC?.saveImageCheckmark?.image = UIImage(named: "checkmark")
                            profileVC?.changeButtonText(buttonView: profileVC?.editButtonView, text: "Edit")
                        }
                    } else {
                        profileVC?.isImageChanged = false
                    }
                }
            }
        })
    }
}
