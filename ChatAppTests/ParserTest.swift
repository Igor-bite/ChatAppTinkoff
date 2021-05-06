//
//  ParserTest.swift
//  ChatAppTests
//
//  Created by Игорь Клюжев on 06.05.2021.
//

import XCTest
@testable import ChatApp

class ParserTest: XCTestCase {
    var parser: ImageListParser?
    let expectedPreviewURL = getValue(for: "expectedPreviewURL")
    let expectedLargeImageURL = getValue(for: "expectedLargeImageURL")

    override func setUp() {
        parser = ImageListParser()
    }

    override func tearDown() {
        parser = nil
    }

    func testParsing() throws {
        let json = Bundle(for: ChatAppTests.self).url(forResource: "PixabayJson",
                                                      withExtension: "json")
        // , subdirectory: "SupportingFiles")
        XCTAssertNotNil(json, "There is no file with pixabay json")
        guard let json = json else { fatalError() }

        let response = try? String(contentsOf: json, encoding: .utf8)
        XCTAssertNotNil(response)
        guard let response = response else { fatalError() }

        let imageList = parser?.parse(data: Data(response.utf8))
        XCTAssertEqual((imageList?.hits?.count)!, 3)
        XCTAssertEqual((imageList?.hits?.first?.previewURL)!, expectedPreviewURL)
        XCTAssertEqual((imageList?.hits?.first?.largeImageURL)!, expectedLargeImageURL)
    }
}

private func getValue(for key: String) -> String? {
    var resourceFileDictionary: NSDictionary?

    if let path = Bundle(for: ChatAppTests.self).path(forResource: "Info", ofType: "plist") {
        resourceFileDictionary = NSDictionary(contentsOfFile: path)
    }

    if let resourceFileDictionaryContent = resourceFileDictionary {
        return resourceFileDictionaryContent.object(forKey: key) as? String
    } else { return nil }
}
