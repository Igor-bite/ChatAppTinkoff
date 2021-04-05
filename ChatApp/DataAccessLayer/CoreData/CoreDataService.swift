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
}

class CoreDataService {
    private static let coreDataStack = CoreDataStack()
    weak var delegate: NSFetchedResultsControllerDelegate?
    
    init(delegate: NSFetchedResultsControllerDelegate) {
        self.delegate = delegate
    }
    
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
            var messages_db = [Message_db]()
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
    
    func fetchChannels() {
        CoreDataService.coreDataStack.performSave { (context) in
            let request: NSFetchRequest<Channel_db> = Channel_db.fetchRequest()
            request.returnsObjectsAsFaults = true
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            let frc = NSFetchedResultsController(fetchRequest: request,
                                                 managedObjectContext: CoreDataService.coreDataStack.mainContext, // is it Ok to use main context here????
                                                 sectionNameKeyPath: nil,
                                                 cacheName: nil)
            frc.delegate = self.delegate
            try? frc.performFetch()
            _ = frc.fetchedObjects
//                let channels = try channels_db?.map({ (channel_db) -> Channel in
//                    guard let name = channel_db.name, let id = channel_db.identifier else { throw CoreDataError.fetchProblem }
//                    return Channel(identifier: id, name: name, lastMessage: channel_db.lastMessage, lastActivity: channel_db.lastActivity)
//                })
//                guard let channelsUnwrapped = channels else { throw CoreDataError.fetchProblem }
        }
    }
    
    func getTableViewDataSource(cellIdentifier: String) -> UITableViewDataSource {
        let context = CoreDataService.coreDataStack.mainContext
        
        let request: NSFetchRequest<Channel_db> = Channel_db.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context, // is it Ok to use main context here????
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        
        frc.delegate = self.delegate
        return TableViewDataSource(fetchedResultsController: frc, cellId: cellIdentifier)
    }
}
