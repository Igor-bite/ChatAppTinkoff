//
//  MessageTableViewCell.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 05.03.2021.
//

import UIKit

protocol MessageCellConfiguration: class {
    var text1: String? {get set}
}

class MessageTableViewCell: UITableViewCell, MessageCellConfiguration {
    @IBOutlet weak var messageView: UIView?
    @IBOutlet weak var messageLabel: UILabel?
    var text1: String?
    
    func configure(text: String, isFromMe: Bool) {
        messageLabel?.text = text
        messageLabel?.textColor = .white
        if isFromMe {
            messageView?.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        } else {
            messageView?.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        }
        messageView?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        messageView?.backgroundColor = UIColor(red: 0, green: 0, blue: 150/255, alpha: 0.7)
        
        messageView?.layer.cornerRadius = 15
        
    }
}
