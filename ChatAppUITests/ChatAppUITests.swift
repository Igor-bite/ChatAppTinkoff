//
//  ChatAppUITests.swift
//  ChatAppUITests
//
//  Created by Игорь Клюжев on 06.05.2021.
//

import XCTest

class ChatAppUITests: XCTestCase {

    func testTextFieldsExistence() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        app.buttons["Edit"].tap()
        XCTAssertEqual(app.staticTexts["My Profile"].label, "My Profile")
        XCTAssertEqual(app.textViews.count, 1)
        XCTAssertEqual(app.textFields.count, 1)
    }
}
