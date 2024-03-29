//
//  Alerts.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 16.04.2021.
//

import UIKit

class AlertPresenter {
    weak var profileVC: ProfileViewController?
    
    init(profileVC: ProfileViewController) {
        self.profileVC = profileVC
    }
    
    func showSuccessAlert() {
        let alertControl = UIAlertController(title: "Данные сохранены",
                                   message: nil,
                                   preferredStyle: .alert)
        alertControl.addAction(UIAlertAction(title: "Ок", style: .default, handler: {_ in }))
        profileVC?.isSaving = false
        guard let isSavingCancelled = profileVC?.isSavingCancelled else { return }
        if !isSavingCancelled {
            profileVC?.isSavingCancelled = false
            profileVC?.present(alertControl, animated: true)
            profileVC?.delegate?.userImage = profileVC?.userImage?.image
        }
    }

    func showCancelAlert() {
        let alertControl = UIAlertController(title: "Изменения профиля отменены",
                                   message: nil,
                                   preferredStyle: .alert)
        alertControl.addAction(UIAlertAction(title: "Ок",
                                   style: .default,
                                   handler: {_ in }))
        profileVC?.present(alertControl, animated: true)
    }

    func showFailureAlert() {
        let alertControl = UIAlertController(title: "Ошибка",
                                   message: "Не удалось сохранить данные",
                                   preferredStyle: .alert)
        alertControl.addAction(UIAlertAction(title: "Ок",
                                   style: .default,
                                   handler: { [weak self] _ in
                                    guard let profileVC = self?.profileVC else { return }
                                    profileVC.setUpUserData()
                                    
                                    profileVC.state = SavedState(profileVC: profileVC)
        }))
        alertControl.addAction(UIAlertAction(title: "Повторить",
                                             style: .default,
                                             handler: { [weak self] _ in
                                                guard let profileVC = self?.profileVC else { return }
                                                profileVC.isImageChanged = true
                                                profileVC.isUserDetailsChanged = true
                                                profileVC.setUpUserData()
                                                profileVC.state = SavedState(profileVC: profileVC)
                                                profileVC.saveGCDTapped()
        }))
        guard let isSavingCancelled = profileVC?.isSavingCancelled else { return }
        if !isSavingCancelled {
            profileVC?.isSavingCancelled = false
            profileVC?.present(alertControl, animated: true)
        }
    }
}
