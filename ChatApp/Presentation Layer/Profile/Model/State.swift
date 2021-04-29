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
        if show {
            var topSafeArea: CGFloat?
            if #available(iOS 13.0, *) {
                let window = UIApplication.shared.windows[0]
                topSafeArea = window.safeAreaInsets.top
            }
            
            let originalTransform = self.profileVC?.userImageView?.transform
            let scaledTransform = originalTransform?.scaledBy(x: 0.7, y: 0.7)
            guard let heightParent = profileVC?.delegate?.view.frame.height,
                  let height = profileVC?.view.frame.height,
                  let userImageHeight = profileVC?.userImageView?.frame.height
            else { return }
            var gap: CGFloat = heightParent - height + userImageHeight * 0.7 + 5
            if let topSafeArea = topSafeArea {
                gap += topSafeArea * 2
            }
            guard let scaledAndTranslatedTransform = scaledTransform?.translatedBy(x: 0.0, y: gap) else { return }
            
            let originalDetailsView = self.profileVC?.userDetailsTextView?.transform
            let scaledDetailsView = originalDetailsView?.scaledBy(x: 1, y: 0.9)
            let textFieldsOffset = gap / 2.0
            guard let scaledAndTranslatedDetailsView = scaledDetailsView?.translatedBy(x: 0.0, y: textFieldsOffset + 5) else { return }
            UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                self.profileVC?.userImageView?.transform = scaledAndTranslatedTransform
                self.profileVC?.userNameTextField?.transform = CGAffineTransform(translationX: 0, y: textFieldsOffset + 10)
                self.profileVC?.userDetailsTextView?.transform = scaledAndTranslatedDetailsView
            })
        } else {
            UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                self.profileVC?.userImageView?.transform = CGAffineTransform.identity
                self.profileVC?.userNameTextField?.transform = CGAffineTransform.identity
                self.profileVC?.userDetailsTextView?.transform = CGAffineTransform.identity
            })
        }
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
        profileVC.buttonAnimator?.animate()
    }
    
    func saveTapped() {
        profileVC?.buttonAnimator?.stop {
            guard let profileVC = self.profileVC else { return }
            profileVC.state = SavingState(profileVC: profileVC)
            self.keyboardWill(show: false)
        }
    }
    
    // cancel tapped
    func editTapped() {
        profileVC?.buttonAnimator?.stop {
            guard let profileVC = self.profileVC else { return }
            profileVC.state = SavedState(profileVC: profileVC)
            self.keyboardWill(show: false)
        }
    }
}

class SavingState: State {
    weak var profileVC: ProfileViewController?
    
    init(profileVC: ProfileViewController) {
        self.profileVC = profileVC
        
        profileVC.changeUserImageLabel()
        profileVC.saveActivityIndicator?.startAnimating()
        profileVC.isSaving = true
        profileVC.saveGCDButtonView?.isHidden = true
        profileVC.saveImageCheckmark?.isHidden = true
        UIHelper.changeButtonText(buttonView: profileVC.editButtonView, text: "Cancel")
        makeFields(enabled: false)
        profileVC.saveData()
    }
    
    func saveTapped() {
        fatalError("There should be no save button on profileVC")
    }
    
    // cancel tapped
    func editTapped() {
        guard let profileVC = profileVC else { return }
        
        if profileVC.isSaving {
            profileVC.cancelGCDSaving()
            profileVC.showCancelAlert()
            profileVC.state = SavedState(profileVC: profileVC)
            return
        }
        profileVC.state = SavedState(profileVC: profileVC)
        profileVC.state?.editTapped()
    }
}

class SavedState: State {
    weak var profileVC: ProfileViewController?
    
    init(profileVC: ProfileViewController) {
        self.profileVC = profileVC
        profileVC.isSaving = false
        profileVC.saveImageCheckmark?.isHidden = false
        profileVC.saveImageCheckmark?.image = UIImage(named: "checkmark")
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
