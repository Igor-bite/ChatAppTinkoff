//
//  WebImageLoaderMock.swift
//  ChatAppTests
//
//  Created by Игорь Клюжев on 07.05.2021.
//

import UIKit
@testable import ChatApp

class WebImageLoaderMock: ImageLoader {
    var requestSender: IRequestSender = ImageListRequestSender()
    var config = RequestConfig<ImageListParser>(request: ImageListRequest(), parser: ImageListParser())

    var previewCountCalls = 0
    var largeCountCalls = 0
    var imageListCountCalls = 0
    var previewIndexes = [Int]()
    var largeIndexes = [Int]()
    var hasImageList = false

    func loadPreviewImage(for index: Int) -> UIImage? {
        previewCountCalls += 1
        previewIndexes.append(index)
        return nil
    }

    func loadLargeImage(for index: Int) -> UIImage? {
        largeCountCalls += 1
        largeIndexes.append(index)
        return nil
    }

    func getImageList() {
        hasImageList = true
    }
}
