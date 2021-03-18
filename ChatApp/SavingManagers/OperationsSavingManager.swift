//
//  OperationsSavingManager.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 16.03.2021.
//

import UIKit

class OperationsSavingManager: ISavingManager {
    private let queue = OperationQueue()
    var saveUserOperation: SaveUserOperation?
    var saveImageOperation: SaveImageDataOperation?
    
    func saveUser(user: User, completion: @escaping (FileOperationError?) -> Void) {
        saveUserOperation = SaveUserOperation(user: user)
        
        saveUserOperation?.completionBlock = {
            OperationQueue.main.addOperation {
                if let result = self.saveUserOperation?.result {
                    completion(result)
                } else {
                    completion(nil)
                }
            }
        }
        guard let saveUserOperation = saveUserOperation else { return }
        queue.addOperations([saveUserOperation], waitUntilFinished: false)
    }
    
    func saveImage(of data: Data, completion: @escaping (FileOperationError?) -> Void) {
        saveImageOperation = SaveImageDataOperation(data: data)
        
        saveImageOperation?.completionBlock = {
            OperationQueue.main.addOperation {
                if let result = self.saveImageOperation?.result {
                    completion(result)
                } else {
                    completion(nil)
                }
            }
        }
        guard let saveImageOperation = saveImageOperation else { return }
        queue.addOperations([saveImageOperation], waitUntilFinished: false)
    }
    
    func cancel() {
        saveUserOperation?.cancel()
        saveImageOperation?.cancel()
    }
}

// MARK: - AsyncOperation

class AsyncOperation: Operation {
    
    enum State: String {
        case ready, executing, finished, cancelled
        
        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }
    
    var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
}

extension AsyncOperation {
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override var isCancelled: Bool {
        return state == .cancelled
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        main()
        state = .executing
    }
    
    override func cancel() {
        state = .cancelled
    }
}

protocol IDataSaveOperation {
    var result: FileOperationError? { get }
}

// MARK: - SaveUserOperation

class SaveUserOperation: AsyncOperation, IDataSaveOperation {
    private let user: User
    private(set) var result: FileOperationError?
    
    init(user: User) {
        self.user = user
        super.init()
    }
    
    override func main() {
        if isCancelled {
            state = .finished
            return
        }
        saveUserData(user: user, completion: { [weak self] result in
            self?.result = result
            self?.state = .finished
        })
    }
}

// MARK: - SaveUserOperation

class SaveImageDataOperation: AsyncOperation, IDataSaveOperation {
    private let data: Data
    private(set) var result: FileOperationError?
    
    init(data: Data) {
        self.data = data
        super.init()
    }
    
    override func main() {
        if isCancelled {
            state = .finished
            return
        }
        
        saveUserImageData(data: data) { [weak self] (result) in
            self?.result = result
            self?.state = .finished
        }
    }
}
