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
//        CoreDataService.coreDataStack.didUpdateDataBase = { stack in
//            stack.printDatabaseStatistice()
//        }
//        CoreDataService.coreDataStack.enableObservers()
        
        let context = CoreDataService.coreDataStack.container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        let channel_db = Channel_db(name: channel.getName(),
                                    identifier: channel.getId(),
                                    lastActivity: channel.getLastActivity(),
                                    lastMessage: channel.getLastMessage(),
                                    in: context)

        guard let message = message else {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
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
        channel_db.addToMessages(message_db)
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func delete(channel: Channel) {
        let fetchRequest: NSFetchRequest<Channel_db> = Channel_db.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", channel.getId())
        let context = CoreDataService.coreDataStack.container.newBackgroundContext()
        let object = try? context.fetch(fetchRequest)
        if let object = object {
            if object.count == 1 {
                context.delete(object[0])
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch {
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                }
            } else if object.count == 0 {
                fatalError("There are no channels with id: \(channel.getId()) and name \(channel.getName())")
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
        let context = CoreDataService.coreDataStack.container.newBackgroundContext()
        let object = try? context.fetch(fetchRequest)
        if let object = object {
            if object.count == 1 {
                context.delete(object[0])
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch {
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                }
            } else {
                fatalError("There more than 1 messages with id: \(message_identifier)) and text \(message.getContent())")
            }
        } else {
            print("There is no message with id \(message_identifier)")
        }
    }
    
    func getChannelsTableViewDataSource(cellIdentifier: String, theme: Theme, delegate: ConversationsListViewController) -> UITableViewDataSource {
        let context = CoreDataService.coreDataStack.container.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        let request: NSFetchRequest<Channel_db> = Channel_db.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "lastActivity", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self.channelsDelegate
        return ChannelsTableViewDataSource(fetchedResultsController: frc, coreDataService: self, cellId: cellIdentifier, theme: theme, delegate: delegate)
    }
    
    func getConversationTableViewDataSource(cellIdentifier: String, theme: Theme, channel: Channel, delegate: ConversationViewController) -> UITableViewDataSource {
        let context = CoreDataService.coreDataStack.container.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        let request: NSFetchRequest<Message_db> = Message_db.fetchRequest()
        request.predicate = NSPredicate(format: "channel.identifier = %@", channel.getId())
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self.messagesDelegate
        return ConversationTableViewDataSource(fetchedResultsController: frc, coreDataService: self, cellId: cellIdentifier, theme: theme, delegate: delegate)
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
