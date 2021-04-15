//
//  Database.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 25.03.2021.
//

import Foundation
import FirebaseFirestore
import UIKit

// MARK: - Firebase/Firestore

protocol IDatabase {
    func addListenerForChannels(completion: @escaping (Error?) -> Void)
    func addListenerForMessages(in channel: Channel, completion: @escaping (Error?) -> Void)
    func makeNewChannel(with name: String)
    func addMessageToChannel(message: Message, channel: Channel)
    func delete(channel: Channel)
    func delete(message: Message, in channel: Channel)
}

class FirestoreDatabase: IDatabase {
    lazy var dbInstance = Firestore.firestore()
    lazy var reference = dbInstance.collection("channels")
    weak var coreDataService: CoreDataService?

    func addListenerForChannels(completion: @escaping (Error?) -> Void) {
        reference.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(error)
            }
            guard let snap = snapshot else { return }
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
                    self.coreDataService?.save(channel: channel)
                case .modified:
                    self.coreDataService?.save(channel: channel)
                case .removed:
                    self.coreDataService?.delete(channel: channel)
                default:
                    print("Unsupported type")
                }
            }
            
            completion(nil)
        }
    }
    
    func addListenerForMessages(in channel: Channel, completion: @escaping (Error?) -> Void) {
        reference.document(channel.getId()).collection("messages").addSnapshotListener { snapshot, error in
            if let error = error {
                completion(error)
            }
            guard let snap = snapshot else { return }
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
                    self.coreDataService?.save(channel: channel, message: message)
                case .modified:
                    self.coreDataService?.save(channel: channel, message: message)
                case .removed:
                    self.coreDataService?.delete(message: message, in: channel)
                default:
                    print("Unsupported type")
                }
            }
            
            completion(nil)
        }
    }
    
    func makeNewChannel(with name: String) {
        let newChannelRef = reference.document()
        let channel = Channel(name: name, identifier: newChannelRef.documentID)
        do {
            try newChannelRef.setData(channel.asDictionary())
        } catch let error {
            print("Error writing to Firestore: \(error)")
        }
    }

    func addMessageToChannel(message: Message, channel: Channel) {
        let newMessageRef = reference.document(channel.getId()).collection("messages").document()
        do {
            try newMessageRef.setData(message.asDictionary())
            print("added new message with text: \(message.getContent()) to channel: \(channel.getName())")
        } catch let error {
            print("Error writing to Firestore: \(error)")
        }
    }
    
    func delete(channel: Channel) {
        reference.document(channel.getId()).delete { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    func delete(message: Message, in channel: Channel) {
        guard let id = message.getIdentifier() else { return }
        reference.document(channel.getId()).collection("messages").document(id).delete { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
}
