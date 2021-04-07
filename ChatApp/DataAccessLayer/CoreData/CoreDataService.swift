//
//  CoreDataService.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 01.04.2021.
//

import UIKit
import CoreData

public enum CoreDataError: Error {
    case fetchProblem
    case saveProblem
    case dataError
}

class CoreDataService {
    private static let coreDataStack = CoreDataStack()
    weak var channelsDelegate: NSFetchedResultsControllerDelegate?
    weak var messagesDelegate: NSFetchedResultsControllerDelegate?
    
    func save(channel: Channel, message: Message? = nil) {
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
            
            guard let message = message else {
                do {
                    try context.obtainPermanentIDs(for: [channel_db])
                } catch {
                    print(error.localizedDescription)
                }
                return
            }
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
            do {
                try context.obtainPermanentIDs(for: [channel_db, message_db])
            } catch {
                print(error.localizedDescription)
            }
            channel_db.addToMessages(message_db)
        }
    }
    
    func delete(channel: Channel) {
        let fetchRequest: NSFetchRequest<Channel_db> = Channel_db.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", channel.getId())
        let context = CoreDataService.coreDataStack.mainContext
        let object = try? context.fetch(fetchRequest)
        if let object = object {
            if object.count == 1 {
                context.delete(object[0])
            } else if object.count == 0 {
                fatalError("There no channels with id: \(channel.getId()) and name \(channel.getName())")
            } else {
                fatalError("There more than 1 channels with id: \(channel.getId()) and name \(channel.getName())")
            }
        } else {
            print("There is no channel with name \(channel.getName()) and id \(channel.getId())")
        }
    }
    
    func delete(message: Message, in channel: Channel) {
        let fetchRequest: NSFetchRequest<Message_db> = Message_db.fetchRequest()
        guard let message_identifier = message.getIdentifier() else { return }
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", message_identifier)
        let context = CoreDataService.coreDataStack.mainContext
        let object = try? context.fetch(fetchRequest)
        if let object = object {
            if object.count == 1 {
                context.delete(object[0])
            } else {
                fatalError("There more than 1 messages with id: \(message_identifier)) and text \(message.getContent())")
            }
        } else {
            print("There is no message with id \(message_identifier)")
        }
    }
    
    func getChannels() -> [Channel]? {
        let request: NSFetchRequest<Channel_db> = Channel_db.fetchRequest()
        request.returnsObjectsAsFaults = true
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataService.coreDataStack.mainContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        try? frc.performFetch()
        let channels_db = frc.fetchedObjects
        let channels = try? channels_db?.map({ (channel_db) -> Channel in
            guard let name = channel_db.name, let id = channel_db.identifier else { throw CoreDataError.fetchProblem }
            return Channel(identifier: id, name: name, lastMessage: channel_db.lastMessage, lastActivity: channel_db.lastActivity)
        })
        return channels
    }
    
    func fetchMessages(for channel: Channel) -> [Message] {
        let fetchRequest: NSFetchRequest<Message_db> = Message_db.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "channel.identifier == %@", channel.getId())
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Message_db.created), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let context = CoreDataService.coreDataStack.mainContext
        guard let messages_db = try? context.fetch(fetchRequest) else { return [] }
        var result = [Message]()
        for message_db in messages_db {
            if let message = try? getMessage(for: message_db) {
                result.append(message)
            }
        }
        return result
    }

    func getChannelsTableViewDataSource(cellIdentifier: String, theme: Theme) -> UITableViewDataSource {
        let context = CoreDataService.coreDataStack.mainContext
        
        let request: NSFetchRequest<Channel_db> = Channel_db.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Channel_db.lastActivity), ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self.channelsDelegate
        return ChannelsTableViewDataSource(fetchedResultsController: frc, coreDataService: self, cellId: cellIdentifier, theme: theme)
    }
    
    func getConversationTableViewDataSource(cellIdentifier: String, theme: Theme, channel: Channel) -> UITableViewDataSource {
        let context = CoreDataService.coreDataStack.mainContext
        
        let request: NSFetchRequest<Message_db> = Message_db.fetchRequest()
        request.predicate = NSPredicate(format: "channel.identifier = %@", channel.getId())
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Message_db.created), ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self.messagesDelegate
        return ConversationTableViewDataSource(fetchedResultsController: frc, coreDataService: self, cellId: cellIdentifier, theme: theme)
    }
    
    func getChannel(for channel: Channel_db) throws -> Channel {
        guard let id = channel.identifier, let name = channel.name else { throw CoreDataError.dataError }
        return Channel(identifier: id,
                       name: name,
                       lastMessage: channel.lastMessage,
                       lastActivity: channel.lastActivity)
    }
    
    func getMessage(for message: Message_db) throws -> Message {
        guard let id = message.identifier,
              let text = message.content,
              let senderName = message.senderName,
              let created = message.created,
              let senderId = message.senderId else { throw CoreDataError.dataError }
        
        return Message(content: text, senderName: senderName, created: created, senderId: senderId, identifier: id)
    }
}
