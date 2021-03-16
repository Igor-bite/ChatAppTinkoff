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
    
    func saveImage(of data: Data) {
        print("GCDSaving image")
    }
    
    func saveTheme(theme: Theme) {
        print("GCDSaving theme")
    }
}
