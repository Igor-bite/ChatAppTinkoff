//
//  SavingManager.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 16.03.2021.
//

import Foundation

protocol ISaver {
    func saveUser(user: User, completion: @escaping (FileOperationError?) -> Void)

    func saveImage(of data: Data, completion: @escaping (FileOperationError?) -> Void)
}
