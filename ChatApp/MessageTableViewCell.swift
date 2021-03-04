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
//        guard let view = messageView else { return }
//        let constraintMessageViewLeading: NSLayoutConstraint
        if isFromMe {
            messageView?.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
//            constraintMessageViewLeading = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 5)
        } else {
            messageView?.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
//            constraintMessageViewLeading = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 5)
        }
        messageView?.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([constraintMessageViewLeading])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        messageView?.backgroundColor = UIColor(red: 0, green: 0, blue: 150/255, alpha: 0.7)
        
        messageView?.layer.cornerRadius = 20
        
    }
}
