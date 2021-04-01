//
//  ObjectsExtension.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 30.03.2021.
//

import Foundation
import CoreData

extension Channel_db {
    convenience init(name: String,
                     identifier: String,
                     lastActivity: Date?,
                     lastMessage: String?,
                     in context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
        self.identifier = identifier
        self.lastActivity = lastActivity
        self.lastMessage = lastMessage
    }
    var about: String {
        let description = "\(String(describing: name)), lastMessage: \(String(describing: lastMessage)) \n"
        let messages = self.messages?.allObjects
            .compactMap { $0 as? Message_db }
            .map { "\t\t\t\($0.about)" }
            .joined(separator: "\n") ?? ""
        
        return description + messages
    }
}

extension Message_db {
    convenience init(content: String,
                     created: Date,
                     identifier: String,
                     senderId: String,
                     senderName: String,
                     in context: NSManagedObjectContext) {
        self.init(context: context)
        self.content = content
        self.created = created
        self.identifier = identifier
        self.senderId = senderId
        self.senderName = senderName
    }
    
    var about: String {
        return "Message: \(String(describing: content)) created by \(String(describing: senderName))"
    }
}
