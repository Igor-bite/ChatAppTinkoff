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
    @IBOutlet var messageTextCentering: NSLayoutConstraint?
    @IBOutlet weak var userName: UILabel?
    
    func configure(text: String, userName: String?, isFromMe: Bool) {
        messageLabel?.text = text
        messageLabel?.textColor = .black
        self.isFromMe = isFromMe
        if !isFromMe {
            if let userName = userName {
                self.userName?.text = userName
                self.userName?.isHidden = false
                self.messageTextCentering?.isActive = false
            }
        } else {
            self.userName?.isHidden = true
            self.messageTextCentering?.isActive = true
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
    
    func changeTheme(theme: Theme) {
        guard let isFromMe = self.isFromMe else { return }
        if isFromMe {
            switch theme {
            case .classic:
                self.messageView?.backgroundColor = UIColor(named: "classicMessageOut")
                self.backgroundColor = .white
                let color = UIColor.black
                self.messageLabel?.textColor = color
            case .day:
                self.messageView?.backgroundColor = UIColor(named: "dayMessageOut")
                self.backgroundColor = .white
                let color = UIColor.black
                self.messageLabel?.textColor = color
            case .night:
                self.messageView?.backgroundColor = UIColor(named: "nightMessageOut")
                self.backgroundColor = .black
                let color = UIColor.white
                self.messageLabel?.textColor = color
            }
        } else {
            switch theme {
            case .classic:
                self.messageView?.backgroundColor = UIColor(named: "classicMessageIn")
                self.backgroundColor = .white
                let color = UIColor.black
                self.messageLabel?.textColor = color
            case .day:
                self.messageView?.backgroundColor = UIColor(named: "dayMessageIn")
                self.backgroundColor = .white
                let color = UIColor.black
                self.messageLabel?.textColor = color
            case .night:
                self.messageView?.backgroundColor = UIColor(named: "nightMessageIn")
                self.backgroundColor = .black
                let color = UIColor.white
                self.messageLabel?.textColor = color
            }
        }
    }
}
