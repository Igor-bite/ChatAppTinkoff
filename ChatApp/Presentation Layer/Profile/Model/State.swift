//
//  State.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 26.04.2021.
//

import UIKit

protocol State {
    var profileVC: ProfileViewController? { get }
    func editTapped()
    func saveTapped()
}

class EditingState: State {
    weak var profileVC: ProfileViewController?
    
    init(profileVC: ProfileViewController) {
        self.profileVC = profileVC
    }
    
    func saveTapped() {
        print("saved in editing")
        guard let profileVC = profileVC else { return }
        profileVC.state = SavedState(profileVC: profileVC)
    }
    
    func editTapped() {
        print("edit in editing")
        guard let profileVC = profileVC else { return }
        profileVC.state = SavedState(profileVC: profileVC)
    }
}

class SavedState: State {
    weak var profileVC: ProfileViewController?
    
    init(profileVC: ProfileViewController) {
        self.profileVC = profileVC
    }
    
    func saveTapped() {
        print("saved in saving")
        guard let profileVC = profileVC else { return }
        profileVC.state = EditingState(profileVC: profileVC)
    }
    
    func editTapped() {
        print("edit in saving")
        guard let profileVC = profileVC else { return }
        profileVC.state = EditingState(profileVC: profileVC)
    }
}
