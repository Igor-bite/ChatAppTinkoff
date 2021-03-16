//
//  SavingManager.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 16.03.2021.
//

import Foundation

protocol ISavingManager {
    func saveUser(user: User, completion: @escaping (FileOperationError?) -> Void)
    
    func saveImage(of data: Data, completion: @escaping (FileOperationError?) -> Void)
    
    func saveTheme(theme: Theme, completion: @escaping (FileOperationError?) -> Void)
}
