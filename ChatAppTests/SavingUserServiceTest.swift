//
//  SavingUserServiceTest.swift
//  ChatAppTests
//
//  Created by Игорь Клюжев on 07.05.2021.
//

import XCTest
@testable import ChatApp

class SavingUserManagerTest: XCTestCase {
    var error: FileOperationError?
    var savingService: SavingUserServiceMock?
    var savingManager: GCDSavingManager?

    override func setUp() {
        self.savingService = SavingUserServiceMock()
        guard let savingService = self.savingService else { fatalError() }
        self.savingManager = GCDSavingManager(saveService: savingService)
    }

    override func tearDown() {
        savingService = nil
        savingManager = nil
    }

    func testSavingUser() throws {
//        Arrange
        let userToSave = User(name: "User", description: "Description", isOnline: true)
        let promise = expectation(description: "Saved User")
//        Act
        savingManager?.saveUser(user: userToSave) { error in
            self.error = error
            promise.fulfill()
        }

//        Assert
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNil(self.error)
        XCTAssertEqual(self.savingService?.userSaved, userToSave)
        XCTAssertEqual(self.savingService?.saveCountCalls, 1)
    }

    func testSavingUserImage() throws {
    //        Arrange
        let imageData = UIImage(named: "Crest")?.pngData()
        XCTAssertNotNil(imageData)
        guard let imageData = imageData else { fatalError() }
        let promise = expectation(description: "Saved Image")

    //        Act
        savingManager?.saveImage(of: imageData) { error in
            self.error = error
            promise.fulfill()
        }

    //        Assert
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNil(self.error)
        XCTAssertEqual(self.savingService?.dataSaved, imageData)
        XCTAssertEqual(self.savingService?.saveCountCalls, 1)
    }
}
