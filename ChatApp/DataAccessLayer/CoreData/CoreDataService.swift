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
}

class CoreDataService {
    private static let coreDataStack = CoreDataStack()
    weak var delegate: NSFetchedResultsControllerDelegate?
    
    init(delegate: NSFetchedResultsControllerDelegate) {
        self.delegate = delegate
    }
    
    func save(channel: Channel, messages: [Message]? = nil) {
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
            var messages_db = [Message_db]()
            guard let messages = messages else { return }
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
                messages_db.append(message_db)
            }
            
            channel_db.addToMessages(NSSet(array: messages_db))
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
            } else {
                fatalError("There more than 1 channels with id: \(channel.getId()) and name \(channel.getName())")
            }
        } else {
            print("There is no channel with name \(channel.getName())")
        }
    }
    
    func delete(message: Message) {
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

    func getChannelsTableViewDataSource(cellIdentifier: String, theme: Theme) -> UITableViewDataSource {
        let context = CoreDataService.coreDataStack.mainContext
        
        let request: NSFetchRequest<Channel_db> = Channel_db.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self.delegate
        return ChannelsTableViewDataSource(fetchedResultsController: frc, coreDataService: self, cellId: cellIdentifier, theme: theme)
    }
}
