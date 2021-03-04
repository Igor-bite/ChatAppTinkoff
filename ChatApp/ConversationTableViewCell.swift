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
    
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var lastMessageLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    
    func configure(name: String, message: String?, date: Date, online: Bool, hasUnreadMessages: Bool) {
        self.name = name
        self.message = message
        self.date = date
        self.online = online
        self.hasUnreadMessages = hasUnreadMessages
        setLabels()
    }
    
    func setLabels() {
        nameLabel?.text = name
        if let message = message {
            lastMessageLabel?.text = message
        } else {
            lastMessageLabel?.text = noMessagesText
            lastMessageLabel?.font = UIFont(name:"AmericanTypewriter", size: 17)
        }
        
        if (hasUnreadMessages) {
            lastMessageLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        }
        let dateFormatter = DateFormatter()
        guard let date = date else { return }
        let calend = Calendar.current
        if (calend.isDateInYesterday(date)) {
            dateFormatter.dateFormat = "dd MMM"
        } else {
            dateFormatter.dateFormat = "HH:mm"
        }
        dateLabel?.text = dateFormatter.string(from: date)
    }
}
