//
//  AvatarServiceTest.swift
//  ChatAppTests
//
//  Created by Игорь Клюжев on 07.05.2021.
//

import XCTest
@testable import ChatApp

class AvatarServiceTest: XCTestCase {
    var service: AvatarService?

    func testWebImageRequest() throws {
//        Arrange
        let loader = WebImageLoaderMock()
        service = AvatarImageService(loader: loader)

//        Act
        service?.getImageList()
        _ = service?.getDataSource()
        _ = service?.getPreviewImage(for: IndexPath(row: 0, section: 1))
        _ = service?.getPreviewImage(for: IndexPath(row: 1, section: 1))
        _ = service?.getLargeImage(for: IndexPath(row: 1, section: 0))

//        Assert
        XCTAssertEqual(loader.largeCountCalls, 1)
        XCTAssertEqual(loader.previewCountCalls, 2)
        XCTAssertTrue(loader.hasImageList)
        XCTAssertEqual(loader.largeIndexes, [1])
        XCTAssertEqual(loader.previewIndexes, [0, 1])
    }
}
