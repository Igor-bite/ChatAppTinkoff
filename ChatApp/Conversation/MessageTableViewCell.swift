//
//  MessageTableViewCell.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 05.03.2021.
//

import UIKit

protocol MessageCellConfiguration: class {
    var text: String? {get set}
    var userName: String? {get set}
}

class MessageTableViewCell: UITableViewCell {
    @IBOutlet weak var messageView: UIView?
    @IBOutlet weak var messageLabel: UILabel?
    var isFromMe: Bool?
    @IBOutlet var cellLeadingConstraint: NSLayoutConstraint?
    @IBOutlet var cellTrailingConstraint: NSLayoutConstraint?
    @IBOutlet weak var userName: UILabel?
    
    func configure(text: String, userName: String?, isFromMe: Bool) {
        messageLabel?.text = text
        messageLabel?.textColor = .black
        self.isFromMe = isFromMe
        if !isFromMe {
            if let userName = userName {
                self.userName?.text = userName
                self.userName?.isHidden = false
            }
        } else {
            self.userName?.isHidden = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        messageView?.layer.cornerRadius = 15
        guard let isFromMe = self.isFromMe else { return }
        if !isFromMe {
            cellLeadingConstraint?.isActive = true
            cellTrailingConstraint?.isActive = false
        } else {
            cellLeadingConstraint?.isActive = false
            cellTrailingConstraint?.isActive = true
        }
        messageView?.translatesAutoresizingMaskIntoConstraints = false
    }
}
