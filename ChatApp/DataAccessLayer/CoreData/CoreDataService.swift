//
//  CoreDataService.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 01.04.2021.
//

import Foundation

class CoreDataService {
    private static let coreDataStack = CoreDataStack()
    
    func save(channel: Channel, messages: [Message]) {
        CoreDataService.coreDataStack.didUpdateDataBase = { stack in
            stack.printDatabaseStatistice()
        }
        CoreDataService.coreDataStack.enableObservers()
        
        CoreDataService.coreDataStack.performSave { context in
            let channel_db = Channel_db(name: channel.getName(),
                                        identifier: channel.getId(),
                                        lastActivity: channel.getLastActivity(),
                                        lastMessage: channel.getLastMessage(),
                                        in: context)
            for message in messages {
                guard let identifier = message.getIdentifier() else {
                    assertionFailure("There is no document id of message from firestore")
                    return
                }
                let message_db = Message_db(content: message.getContent(),
                                            created: message.getCreationDate(),
                                            identifier: identifier,
                                            senderId: message.getSenderId(),
                                            senderName: message.getSenderName(),
                                            in: context)
                channel_db.addToMessages(message_db)
            }
        }
    }
}
