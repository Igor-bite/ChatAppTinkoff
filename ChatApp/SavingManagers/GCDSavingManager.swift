//
//  GCDSavingManager.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 16.03.2021.
//

import UIKit

class GCDSavingManager: ISavingManager {
    private let queue = DispatchQueue.global(qos: .utility)
    
    func saveUser(user: User, completion: @escaping (FileOperationError?) -> Void) {
        queue.async {
            saveUserData(user: user) { result in
                DispatchQueue.main.async { completion(result) }
            }
        }
    }
    
    func saveImage(of data: Data, completion: @escaping (FileOperationError?) -> Void) {
        queue.async {
            saveUserImageData(data: data) { result in
                DispatchQueue.main.async { completion(result) }
            }
        }
    }
    
    func saveTheme(theme: Theme, completion: @escaping (FileOperationError?) -> Void) {
        queue.async {
            saveUserTheme(theme: theme.rawValue) { result in
                DispatchQueue.main.async { completion(result) }
            }
        }
    }
    
    func getUserData(completion: @escaping (User?, Data?, FileOperationError?) -> Void) {
        queue.async {
            getAllUserData() { user, data, error in
                DispatchQueue.main.async { completion(user, data, error) }
            }
        }
    }
    
    func getUser(completion: @escaping (User?, FileOperationError?) -> Void) {
        queue.async {
            getUserOnly() { user, error in
                DispatchQueue.main.async { completion(user, error) }
            }
        }
    }
    
    func getImage(completion: @escaping (Data?, FileOperationError?) -> Void) {
        queue.async {
            getUserImage() { data, error in
                DispatchQueue.main.async { completion(data, error) }
            }
        }
    }
}
