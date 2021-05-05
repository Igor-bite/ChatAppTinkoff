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
    func addListenerForChannels(completion: @escaping (Result<QuerySnapshot, Error>) -> Void)
    func addListenerForMessages(in channel: Channel, completion: @escaping (Result<QuerySnapshot, Error>) -> Void)
    func makeNewChannel(with name: String)
    func addMessageToChannel(message: Message, channel: Channel)
    func delete(channel: Channel)
    func delete(message: Message, in channel: Channel)
}

class FirestoreDatabase: IDatabase {
    lazy var dbInstance = Firestore.firestore()
    lazy var reference = dbInstance.collection("channels")

    func addListenerForChannels(completion: @escaping (Result<QuerySnapshot, Error>) -> Void) {
        reference.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let snap = snapshot else { return }
            completion(.success(snap))
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
