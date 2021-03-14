//
//  ConversationTableViewCell.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 04.03.2021.
//

import UIKit
 
protocol ConversationCellConfiguration : class {
    var name : String? {get set}
    var message : String? {get set}
    var date : Date? {get set}
    var online : Bool {get set}
    var hasUnreadMessages : Bool {get set}
}

let noMessagesText = "No messages yet"

class ConversationTableViewCell: UITableViewCell, ConversationCellConfiguration {
    var name: String?
    var message: String?
    var date: Date?
    var online: Bool = false
    var hasUnreadMessages: Bool = false
    
    @IBOutlet weak var userImageView: UIView?
    @IBOutlet weak var userInitialsLabel: UILabel?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var lastMessageLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    
    func configure(name: String?, message: String?, date: Date?, online: Bool, hasUnreadMessages: Bool) {
        self.name = name
        self.message = message
        self.date = date
        self.online = online
        self.hasUnreadMessages = hasUnreadMessages
        setLabels()
    }
    
    func setLabels() {
        let userNameData = name?.components(separatedBy: " ")
        guard let firstNameSymbol = userNameData?[0].first else { return }
        guard let firstSurnameSymbol = userNameData?[1].first else { return }
        userInitialsLabel?.text = "\(firstNameSymbol)\(firstSurnameSymbol)"
        
        nameLabel?.text = name
        if let message = message {
            lastMessageLabel?.text = message
        } else {
            lastMessageLabel?.text = noMessagesText
            lastMessageLabel?.font = UIFont(name:"AmericanTypewriter", size: 17)
        }
        
        if (hasUnreadMessages) {
            lastMessageLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        } else {
            lastMessageLabel?.font = UIFont.systemFont(ofSize: 17)
        }
        let dateFormatter = DateFormatter()
        guard let date = date else {
            dateLabel?.text = ""
            return
        }
        let yesterday = Date()-60*60*24
        if (date <= yesterday) {
            dateFormatter.dateFormat = "dd MMM"
        } else {
            dateFormatter.dateFormat = "HH:mm"
        }
        dateLabel?.text = dateFormatter.string(from: date)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let width = userImageView?.bounds.size.width else { return }
        userImageView?.layer.cornerRadius = 0.5 * width
        userImageView?.backgroundColor = .white
        userImageView?.clipsToBounds = true
        userImageView?.layer.borderWidth = 5
        userImageView?.layer.borderColor = self.online ? UIColor(red: 228/255, green: 232/255, blue: 43/255, alpha: 1).cgColor : UIColor.gray.cgColor // бледно жёлтый или серый
    }
}
