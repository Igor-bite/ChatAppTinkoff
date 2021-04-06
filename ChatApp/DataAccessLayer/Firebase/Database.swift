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

class Database {
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
                // ToDo: correct deleting only messages not whole channels
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
            
            completion(nil) // ToDo: correct!
        }
    }
    
    func addListenerForMessages(in channel: Channel, completion: @escaping (Result<QuerySnapshot, Error>) -> Void) {
        reference.document(channel.getId()).collection("messages").addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
            }
            guard let snap = snapshot else { return }
            completion(.success(snap))
        }
    }

    func getChannels(completion: @escaping (Result<QuerySnapshot, Error>) -> Void) {
        reference.getDocuments { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            }
            
            guard let snapshot = snap else { return }
            completion(.success(snapshot))
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

    func getMessagesFor(channel: Channel, completion: @escaping (Result<QuerySnapshot, Error>) -> Void) {
        reference.document(channel.getId()).collection("messages").getDocuments { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            }
            guard let snap = snap else { return }
            completion(.success(snap))
        }
    }

    func addMessageToChannel(message: Message, channel: Channel) {
        let newMessageRef = reference.document(channel.getId()).collection("messages").document()
        do {
            try newMessageRef.setData(message.asDictionary())
        } catch let error {
            print("Error writing to Firestore: \(error)")
        }
    }
    
    func delete(channel: Channel) {
        coreDataService?.delete(channel: channel)
        // ToDo: update firebase
    }
    
    func delete(message: Message) {
        coreDataService?.delete(message: message)
        // ToDo: update firebase
    }
}
