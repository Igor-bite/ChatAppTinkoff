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

extension FileManager {
    func documentDirectory() -> URL {
        return self.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

class SavingManager {
    private let appDirectoryName = "AppServiceData"
    private let userDataFileName = "userData.json"
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
        if (!isFileExists) {
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
            print(error.localizedDescription)
        }
        
    }
    
    func getUserData() -> User? {
        do {
            let jsonData = try Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            do {
                let user = try decoder.decode(User.self, from: jsonData)
//                print(user.name)
//                print(user.description)
//                print(user.themeRawValue)
                return user
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    private func makeAppDirectory() throws {
        if !fileManager.fileExists(atPath: appDirectory.absoluteString) {
            try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    private func makeFile() {
        fileManager.createFile(atPath: filePath.absoluteString, contents: nil, attributes: nil)
    }
}
