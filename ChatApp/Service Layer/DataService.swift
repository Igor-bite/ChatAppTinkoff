//
//  DatabaseService.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 16.04.2021.
//

import Foundation
import Firebase

protocol DatabaseSaveManager {
    var database: IDatabase { get }
    
    func listenToChannels(completion: @escaping (Error?) -> Void)
    func listenToMessages(in channel: Channel, completion: @escaping (Error?) -> Void)
    func makeNewChannel(with name: String)
    func addMessageToChannel(message: Message, channel: Channel)
    func delete(channel: Channel)
    func delete(message: Message, in channel: Channel)
}

protocol FileSaveManager {
    var gcdSaver: GCDSavingManager { get }
    var operationsSaver: OperationsSavingManager { get }
    var concurrentSaveQueue: DispatchQueue { get }
    
    func saveUser(user: User, completion: @escaping (FileOperationError?) -> Void)
    func saveImage(imageData: Data, completion: @escaping (FileOperationError?) -> Void)
}

protocol CoreDataSaveManager {
    var coreDataService: ICoreDataService { get set }
}

protocol IDataService: DatabaseSaveManager, FileSaveManager, CoreDataSaveManager {}

class DataService: IDataService {
    internal let gcdSaver = GCDSavingManager()
    internal let operationsSaver = OperationsSavingManager()
    internal let concurrentSaveQueue = DispatchQueue(label: "ru.tinkoff.save", attributes: .concurrent)
    var coreDataService: ICoreDataService
    var database: IDatabase
    
    init(database: IDatabase, coreDataService: ICoreDataService) {
        self.database = database
        self.coreDataService = coreDataService
    }
    
    func listenToChannels(completion: @escaping (Error?) -> Void) {
        database.addListenerForChannels { (res) in
            switch res {
            case .failure(let error):
                completion(error)
            case .success(let snap):
                let changes = snap.documentChanges
                
                changes.forEach { (change) in
                    let jsonData = change.document.data()
                    guard let name = jsonData["name"] as? String else { return }
                    let identifier = change.document.documentID
                    let lastMessage = jsonData["lastMessage"] as? String
                    let timestamp = jsonData["lastActivity"] as? Timestamp
                    let lastActivity = timestamp?.dateValue()
                    let channel = Channel(identifier: identifier,
                                          name: name,
                                          lastMessage: lastMessage,
                                          lastActivity: lastActivity)
                    switch change.type {
                    case .added:
                        self.coreDataService.save(channel: channel)
                    case .modified:
                        self.coreDataService.save(channel: channel)
                    case .removed:
                        self.coreDataService.delete(channel: channel)
                    default:
                        print("Unsupported type")
                    }
                }
                completion(nil)
            }
        }
    }
    
    func listenToMessages(in channel: Channel, completion: @escaping (Error?) -> Void) {
        database.addListenerForMessages(in: channel) { (res) in
            switch res {
            case .failure(let error):
                completion(error)
            case .success(let snap):
                let changes = snap.documentChanges
                
                changes.forEach { (change) in
                    let jsonData = change.document.data()
                    guard let content = jsonData["content"] as? String,
                          let senderId = jsonData["senderId"] as? String,
                          let senderName = jsonData["senderName"] as? String,
                          let timestamp = jsonData["created"] as? Timestamp
                    else {
                        completion(CoreDataError.dataError)
                        return
                    }
                    let identifier = change.document.documentID
                    let created = timestamp.dateValue()
                    let message = Message(content: content,
                                          senderName: senderName,
                                          created: created,
                                          senderId: senderId,
                                          identifier: identifier)
                    switch change.type {
                    case .added:
                        self.coreDataService.save(channel: channel, message: message)
                    case .modified:
                        self.coreDataService.save(channel: channel, message: message)
                    case .removed:
                        self.coreDataService.delete(message: message, in: channel)
                    default:
                        print("Unsupported type")
                    }
                }
                print("Success in getting message")
                completion(nil)
            }
        }
    }
    
    func makeNewChannel(with name: String) {
        database.makeNewChannel(with: name)
    }
    
    func addMessageToChannel(message: Message, channel: Channel) {
        database.addMessageToChannel(message: message, channel: channel)
    }
    
    func delete(channel: Channel) {
        database.delete(channel: channel)
    }
    
    func delete(message: Message, in channel: Channel) {
        database.delete(message: message, in: channel)
    }
    
    func saveUser(user: User, completion: @escaping (FileOperationError?) -> Void) {
        gcdSaver.saveUser(user: user) { error in
            completion(error)
        }
    }
    
    func saveImage(imageData: Data, completion: @escaping (FileOperationError?) -> Void) {
        gcdSaver.saveImage(of: imageData) { error in
            completion(error)
        }
    }
}
