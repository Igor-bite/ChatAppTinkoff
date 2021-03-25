//
//  MessageModel.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 25.03.2021.
//

import Foundation
import UIKit

struct Message: Codable {
    let content: String
    let created: Date
    let senderId: String
    let senderName: String

    init(content: String, userName: String, created: Date, senderId: String) {
        self.content = content
        self.created = created
        self.senderId = senderId
        self.senderName = userName
    }

    init(content: String, userName: String) {
        self.content = content
        created = Date()
        senderId = UIDevice.current.identifierForVendor!.uuidString
        senderName = userName
    }
}
