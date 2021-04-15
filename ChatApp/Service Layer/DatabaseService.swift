//
//  DatabaseService.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 16.04.2021.
//

import Foundation
import UIKit

protocol IDataService {
    var database: IDatabase { get }
    var coreDataService: ICoreDataService { get set }
    func listenToChannels(completion: @escaping (Error?) -> Void)
    func listenToMessages(in channel: Channel, completion: @escaping (Error?) -> Void)
    func makeNewChannel(with name: String)
    func addMessageToChannel(message: Message, channel: Channel)
    func delete(channel: Channel)
    func delete(message: Message, in channel: Channel)
}

class DataService: IDataService {
    var coreDataService: ICoreDataService
    var database: IDatabase
    
    init(database: IDatabase, coreDataService: ICoreDataService) {
        self.database = database
        self.coreDataService = coreDataService
    }
    
    func listenToMessages(in channel: Channel, completion: @escaping (Error?) -> Void) {
        database.addListenerForMessages(in: channel) { (error) in
            completion(error)
        }
    }
    
    func listenToChannels(completion: @escaping (Error?) -> Void) {
        database.addListenerForChannels { (err) in
            completion(err)
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
}
