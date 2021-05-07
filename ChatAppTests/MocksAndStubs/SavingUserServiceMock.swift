//
//  SavingUserServiceMock.swift
//  ChatAppTests
//
//  Created by Игорь Клюжев on 07.05.2021.
//

import Foundation
@testable import ChatApp

class SavingUserServiceMock: ISavingService {
    var userSaved: User?
    var dataSaved: Data?
    var themeSaved: String?

    var saveCountCalls = 0
    var getDataCountCalls = 0

    var isSuccess: Bool

    let stubbedUser = User(name: "User", description: "Desctiption", isOnline: true)

    init(isSuccess: Bool = true) {
        self.isSuccess = isSuccess
    }

    func saveUserData(user: User, completion: @escaping (FileOperationError?) -> Void) {
        if isSuccess {
            self.saveCountCalls += 1
            self.userSaved = user
            completion(nil)
        } else {
            completion(FileOperationError.unspecified)
        }

    }

    func saveUserImageData(data: Data, completion: @escaping (FileOperationError?) -> Void) {
        if isSuccess {
            self.saveCountCalls += 1
            self.dataSaved = data
            completion(nil)
        } else {
            completion(FileOperationError.unspecified)
        }

    }

    func getAllUserData(completion: @escaping (User?, Data?, FileOperationError?) -> Void) {
        if isSuccess {
            getDataCountCalls += 1
            completion(self.stubbedUser, Data(), nil)
        } else {
            completion(nil, nil, FileOperationError.unspecified)
        }
    }

    func saveUserTheme(theme: String, completion: @escaping (FileOperationError?) -> Void) {
        if isSuccess {
            saveCountCalls += 1
            themeSaved = theme
            completion(nil)
        } else {
            completion(FileOperationError.unspecified)
        }
    }

    func getUserOnly(completion: @escaping (User?, FileOperationError?) -> Void) {
        if isSuccess {
            getDataCountCalls += 1
            completion(self.stubbedUser, nil)
        } else {
            completion(nil, FileOperationError.unspecified)
        }
    }

    func getUserImage(completion: @escaping (Data?, FileOperationError?) -> Void) {
        if isSuccess {
            getDataCountCalls += 1
            completion(Data(), nil)
        } else {
            completion(nil, FileOperationError.unspecified)
        }
    }
}
