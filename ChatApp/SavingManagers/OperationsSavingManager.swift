//
//  OperationsSavingManager.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 16.03.2021.
//

import UIKit

class OperationsSavingManager: ISavingManager {
    func saveUser(user: User, completion: @escaping (FileOperationError?) -> Void) {
        print("OperationsSaving user with name: \(user.getName())")
    }
    
    func saveImage(of data: Data) {
        print("OperationsSaving image")
    }
    
    func saveTheme(theme: Theme) {
        print("OperationsSaving theme")
    }
    
}
