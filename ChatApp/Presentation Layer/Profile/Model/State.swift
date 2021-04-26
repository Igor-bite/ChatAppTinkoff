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

extension State {
    fileprivate func makeFields(enabled: Bool) {
        guard let profileVC = profileVC else { return }
        profileVC.userNameTextField?.isUserInteractionEnabled = enabled
        profileVC.userDetailsTextView?.isEditable = enabled
        profileVC.userImageView?.isUserInteractionEnabled = enabled
        if enabled {
            profileVC.userNameTextField?.becomeFirstResponder()
            guard let end = profileVC.userNameTextField?.endOfDocument else { return }
            profileVC.userNameTextField?.selectedTextRange = profileVC.userNameTextField?.textRange(from: end, to: end)
        }
    }
    
    fileprivate func keyboardWill(show: Bool) {
        guard let profileVC = profileVC else { return }
        UIView.animateKeyframes(withDuration: 1, delay: .zero, options: .calculationModeCubicPaced, animations: {
            guard let userImageViewY = profileVC.userImageView?.layer.position.y,
                  let userNameTextFieldY = profileVC.userNameTextField?.layer.position.y,
                  let userDetailsTextViewY = profileVC.userDetailsTextView?.layer.position.y
            else { return }
//            profileVC.userImageView?.layer.position.y = userImageViewY - 1000
//            profileVC.userNameTextField?.layer.position.y = userNameTextFieldY - 1000
//            profileVC.userDetailsTextView?.layer.position.y = userDetailsTextViewY - 1000
            profileVC.userDetailsHeightEquals?.isActive = show
            profileVC.userDetailsHeightGreater?.isActive = !show
        })
    }
}

class EditingState: State {
    weak var profileVC: ProfileViewController?
    
    init(profileVC: ProfileViewController) {
        self.profileVC = profileVC
        
        profileVC.saveImageCheckmark?.image = UIImage(named: "pencil")
        profileVC.saveGCDButtonView?.isHidden = false
        UIHelper.changeButtonText(buttonView: profileVC.editButtonView, text: "Cancel")
        keyboardWill(show: true)
        makeFields(enabled: true)
        profileVC.saveBackup()
    }
    
    func saveTapped() {
        print("saved in editing")
        guard let profileVC = profileVC else { return }
        profileVC.state = SavingState(profileVC: profileVC)
    }
    
    // cancel tapped
    func editTapped() {
        guard let profileVC = profileVC else { return }
        profileVC.state = SavedState(profileVC: profileVC)
    }
}

class SavingState: State {
    weak var profileVC: ProfileViewController?
    
    init(profileVC: ProfileViewController) {
        self.profileVC = profileVC
        
        profileVC.saveActivityIndicator?.startAnimating()
        profileVC.isSaving = true
        profileVC.saveGCDButtonView?.isHidden = true
        profileVC.saveImageCheckmark?.isHidden = true
        UIHelper.changeButtonText(buttonView: profileVC.editButtonView, text: "Cancel")
        keyboardWill(show: false)
        makeFields(enabled: false)
        profileVC.saveBackup()
        profileVC.saveData()
    }
    
    func saveTapped() {
        fatalError("There should be no save button on profileVC")
    }
    
    // cancel tapped
    func editTapped() {
        print("edit in saving")
        guard let profileVC = profileVC else { return }
        profileVC.state = SavedState(profileVC: profileVC)
        profileVC.showCancelAlert()
    }
}

class SavedState: State {
    weak var profileVC: ProfileViewController?
    
    init(profileVC: ProfileViewController) {
        self.profileVC = profileVC
        profileVC.isSaving = false
        profileVC.saveImageCheckmark?.isHidden = false
        profileVC.saveImageCheckmark?.image = UIImage(named: "checkmark")
        keyboardWill(show: false)
        profileVC.saveGCDButtonView?.isHidden = true
        UIHelper.changeButtonText(buttonView: profileVC.editButtonView, text: "Edit")
        makeFields(enabled: false)
        profileVC.saveActivityIndicator?.stopAnimating()
    }
    
    func saveTapped() {
        fatalError("There should be no save button on profileVC")
    }
    
    func editTapped() {
        guard let profileVC = profileVC else { return }
        profileVC.state = EditingState(profileVC: profileVC)
    }
}

/*private*/class UIHelper {
    static weak var viewControl: ProfileViewController?

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
