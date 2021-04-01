//
//  MessageModel.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 25.03.2021.
//

import Foundation
import UIKit

struct Message: Codable {
    private let content: String
    private let created: Date
    private let senderId: String
    private let senderName: String
    private let identifier: String?

    init(content: String, senderName: String, created: Date, senderId: String, identifier: String) {
        self.content = content
        self.created = created
        self.senderId = senderId
        self.senderName = senderName
        self.identifier = identifier
    }

    init(content: String, userName: String) {
        self.content = content
        created = Date()
        senderId = UIDevice.current.identifierForVendor!.uuidString
        senderName = userName
        identifier = nil
    }
    
    func getContent() -> String {
        return content
    }
    
    func getCreationDate() -> Date {
        return created
    }
    
    func getSenderId() -> String {
        return senderId
    }
    
    func getSenderName() -> String {
        return senderName
    }
    
    func getIdentifier() -> String? {
        return identifier
    }
}
