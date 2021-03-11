//
//  MessageTableViewCell.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 05.03.2021.
//

import UIKit

protocol MessageCellConfiguration: class {
    var text: String? {get set}
}

class MessageTableViewCell: UITableViewCell {
    @IBOutlet weak var messageView: UIView?
    @IBOutlet weak var messageLabel: UILabel?
    var isFromMe: Bool?
    @IBOutlet var cellLeadingConstraint: NSLayoutConstraint?
    @IBOutlet var cellTrailingConstraint: NSLayoutConstraint?
    
    func configure(text: String, isFromMe: Bool) {
        messageLabel?.text = text
        messageLabel?.textColor = .black
        self.isFromMe = isFromMe
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        messageView?.layer.cornerRadius = 15
        
        guard let isFromMe = self.isFromMe else { return }
        if !isFromMe {
            cellLeadingConstraint?.isActive = true
            cellTrailingConstraint?.isActive = false
            messageView?.backgroundColor = UIColor(displayP3Red: 223/255, green: 223/255, blue: 223/255, alpha: 1)
        } else {
            cellLeadingConstraint?.isActive = false
            cellTrailingConstraint?.isActive = true
            messageView?.backgroundColor = UIColor(displayP3Red: 220/255, green: 247/255, blue: 197/255, alpha: 1)
        }
        
        messageView?.translatesAutoresizingMaskIntoConstraints = false
    }
}
