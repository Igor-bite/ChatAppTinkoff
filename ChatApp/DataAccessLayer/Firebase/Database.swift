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
        reference.document(channel.getName()).collection("messages").addSnapshotListener { snapshot, error in
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
        reference.document(channel.getName()).collection("messages").getDocuments { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            }
            guard let snap = snap else { return }
            completion(.success(snap))
        }
    }

    func addMessageToChannel(message: Message, channel: Channel) {
        let newMessageRef = reference.document(channel.getName()).collection("messages").document()
        do {
            try newMessageRef.setData(message.asDictionary())
        } catch let error {
            print("Error writing to Firestore: \(error)")
        }
    }
}
