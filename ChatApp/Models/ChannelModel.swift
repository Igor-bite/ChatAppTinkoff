//
//  ChannelModel.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 25.03.2021.
//

import Foundation
import UIKit

struct Channel: Codable {
    private let identifier: String
    private let name: String
    private let lastMessage: String?
    private let lastActivity: Date?

    init(name: String, identifier: String) {
        lastMessage = nil
        self.identifier = identifier
        lastActivity = nil
        self.name = name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKey: .name)
        let identifier = try container.decode(String.self, forKey: .identifier)
        let lastMessage = try container.decode(String.self, forKey: .lastMessage)
        let lastActivity = try container.decode(Date.self, forKey: .lastActivity)
        self.name = name
        self.identifier = identifier
        self.lastActivity = lastActivity
        self.lastMessage = lastMessage
    }

    init(identifier: String, name: String, lastMessage: String?, lastActivity: Date?) {
        self.name = name
        self.identifier = identifier
        self.lastActivity = lastActivity
        self.lastMessage = lastMessage
    }

    func getName() -> String {
        return name
    }

    func getLastMessage() -> String? {
        return lastMessage
    }

    func getId() -> String? {
        return identifier
    }

    func getLastActivity() -> Date? {
        return lastActivity
    }

    enum CodingKeys: String, CodingKey {
        case identifier
        case name
        case lastMessage
        case lastActivity
    }
}
