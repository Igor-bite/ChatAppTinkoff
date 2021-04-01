//
//  ProfileThemeChanger.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 25.03.2021.
//

import Foundation
import UIKit

class ProfileThemeChanger {
    weak var profileVC: ProfileViewController?
// MARK: - Theme change

    func changeToClassic() {
        profileVC?.view.backgroundColor = .white
        profileVC?.userNameTextField?.textColor = .black
        profileVC?.userDetailsTextView?.textColor = .black
        profileVC?.userDetailsTextView?.backgroundColor = .white
        profileVC?.profileLabel?.textColor = .black
        profileVC?.editButtonView?.backgroundColor = .lightGray
        profileVC?.saveGCDButtonView?.backgroundColor = .lightGray
        profileVC?.saveOperationsButtonView?.backgroundColor = .lightGray
    }

    func changeToDay() {
        profileVC?.view.backgroundColor = .white
        profileVC?.userNameTextField?.textColor = .black
        profileVC?.userDetailsTextView?.textColor = .black
        profileVC?.userDetailsTextView?.backgroundColor = .white
        profileVC?.profileLabel?.textColor = .black
        profileVC?.editButtonView?.backgroundColor = .lightGray
        profileVC?.saveGCDButtonView?.backgroundColor = .lightGray
        profileVC?.saveOperationsButtonView?.backgroundColor = .lightGray
    }

    func changeToNight() {
        profileVC?.view.backgroundColor = .black
        profileVC?.userNameTextField?.textColor = .white
        profileVC?.userDetailsTextView?.textColor = .white
        profileVC?.userDetailsTextView?.backgroundColor = .black
        profileVC?.profileLabel?.textColor = .white
        profileVC?.editButtonView?.backgroundColor = .darkGray
        profileVC?.saveGCDButtonView?.backgroundColor = .darkGray
        profileVC?.saveOperationsButtonView?.backgroundColor = .darkGray
    }
}
