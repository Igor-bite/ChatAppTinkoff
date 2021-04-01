//
//  Common.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 16.03.2021.
//

import UIKit

public enum FileOperationError: Error {
    case badDirCreation
    case badFileCreation
    case badWritingOperation
    case badReadingOperation
    case unspecified
}

func saveUserData(user: User, completion: @escaping (FileOperationError?) -> Void) {
    let manager = SavingManager()
    do {
        try manager.saveUserData(user: user)
        sleep(3)
        completion(nil)
    } catch {
        completion(FileOperationError.unspecified) // fix catching specific errors
    }
}

func saveUserImageData(data: Data, completion: @escaping (FileOperationError?) -> Void) {
    let manager = SavingManager()
    do {
        try manager.saveData(data: data)
        completion(nil)
    } catch {
        completion(error as? FileOperationError)
    }
}

func getAllUserData(completion: @escaping (User?, Data?, FileOperationError?) -> Void) {
    let manager = SavingManager()
    do {
        let user = try manager.getUserData()
        let imageData = try manager.getImageData()
        completion(user, imageData, nil)
    } catch {
        completion(nil, nil, error as? FileOperationError)
    }
}

func saveUserTheme(theme: String, completion: @escaping (FileOperationError?) -> Void) {
    let manager = SavingManager()
    do {
        let user = try manager.getUserData()
        user?.changeUserTheme(theme: theme)
        guard let userUnwrapped = user else { return }
        try manager.saveUserData(user: userUnwrapped)
        completion(nil)
    } catch {
        completion(error as? FileOperationError)
    }
}

func getUserOnly(completion: @escaping (User?, FileOperationError?) -> Void) {
    let manager = SavingManager()
    do {
        let user = try manager.getUserData()
        completion(user, nil)
    } catch {
        completion(nil, error as? FileOperationError)
    }
}

func getUserImage(completion: @escaping (Data?, FileOperationError?) -> Void) {
    let manager = SavingManager()
    do {
        let imageData = try manager.getImageData()
        completion(imageData, nil)
    } catch {
        completion(nil, error as? FileOperationError)
    }
}

extension FileManager {
    func documentDirectory() -> URL {
        return self.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

class SavingManager {
    private let appDirectoryName = "AppServiceData"
    private let userDataFileName = "userData.json"
    private let userAvatarImage = "userImage"
    private let fileManager = FileManager.default
    private let docDirectory: URL
    private let filePath: URL
    private let appDirectory: URL
    private var isFileExists = false
    private var isDirExists = false

    init() {
        docDirectory = fileManager.documentDirectory()
        appDirectory = docDirectory.appendingPathComponent(appDirectoryName, isDirectory: true)
        filePath = appDirectory.appendingPathComponent(userDataFileName)
        isDirExists = fileManager.fileExists(atPath: appDirectory.absoluteString)
        isFileExists = fileManager.fileExists(atPath: filePath.absoluteString)
    }

    func saveUserData(user: User) throws {
        if !isFileExists {
            if !isDirExists {
                try makeAppDirectory()
            }
            makeFile()
        }
        guard let jsonData: Data = try? JSONEncoder().encode(user) else {
            print("error")
            throw FileOperationError.unspecified
        }
        let jsonString = String(data: jsonData, encoding: .utf8)
        do {
            guard let json = jsonString else { throw FileOperationError.unspecified}
            try json.write(to: filePath, atomically: true, encoding: .utf8)
        } catch {
            throw FileOperationError.unspecified
        }
    }

    func getUserData() throws -> User? {
        do {
            let jsonData = try Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            let user = try decoder.decode(User.self, from: jsonData)
            return user
        } catch {
            throw FileOperationError.unspecified // fix
        }
    }

    func getImageData() throws -> Data {
        do {
            let data = try Data(contentsOf: appDirectory.appendingPathComponent(userAvatarImage))
            return data
        } catch {
            throw FileOperationError.badReadingOperation
        }
    }

    private func makeAppDirectory() throws {
        if !fileManager.fileExists(atPath: appDirectory.absoluteString) {
            try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }

    private func makeFile() {
        fileManager.createFile(atPath: filePath.absoluteString, contents: nil, attributes: nil)
    }

    func saveData(data: Data) throws {
        do {
            try data.write(to: appDirectory.appendingPathComponent(userAvatarImage))
        } catch {
            throw FileOperationError.badWritingOperation
        }
    }
}
