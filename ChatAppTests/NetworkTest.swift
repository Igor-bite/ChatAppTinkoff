//
//  SavingServiceTest.swift
//  ChatAppTests
//
//  Created by Игорь Клюжев on 05.05.2021.
//

import XCTest
@testable import ChatApp

class ImageListRequestSenderTest: XCTestCase {
    var imageListRequestSender: ImageListRequestSender?
    let expectedPreviewURL = getValue(for: "expectedPreviewURL")
    let expectedLargeImageURL = getValue(for: "expectedLargeImageURL")

    override func setUp() {
        let urlString = "https://pixabay.com/api/?key=token&q=cars&image_type=photo&pretty=true&per_page=3"
        guard let url = URL(string: urlString) else { assertionFailure("Check urlString...")
            return
        }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        imageListRequestSender = ImageListRequestSender(
            session: URLSessionStub(data: nil,
                                    response: response,
                                    error: nil)
        )
    }

    override func tearDown() {
        imageListRequestSender = nil
    }

    func testNoDataFailure() {
        let config = RequestConfig<ImageListParser>(request: ImageListRequest(), parser: ImageListParser())
        imageListRequestSender?.send(config: config, completionHandler: { res in
            switch res {
            case .failure(let error):
                let networkError = error as? NetworkError
                XCTAssertEqual(networkError, NetworkError.noData(), "Not correct erorr i returned")
            case .success(_):
                XCTFail("There is no data, result must be failure")
            }
        })
    }

    func testNoResponseFailure() {
        imageListRequestSender = ImageListRequestSender(
            session: URLSessionStub(data: Data(),
                                    response: nil,
                                    error: nil))
        let config = RequestConfig<ImageListParser>(request: ImageListRequest(), parser: ImageListParser())
        imageListRequestSender?.send(config: config, completionHandler: { res in
            switch res {
            case .failure(let error):
                let networkError = error as? NetworkError
                XCTAssertEqual(networkError, NetworkError.noResponse(), "Not correct erorr i returned")
            case .success(_):
                XCTFail("There is no data, result must be failure")
            }
        })
    }

    func testParsing() {
        let urlString = "https://pixabay.com/api/?key=token&q=cars&image_type=photo&pretty=true&per_page=3"
        guard let url = URL(string: urlString) else { assertionFailure("Check urlString...")
            return
        }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

        let json = Bundle(for: ChatAppTests.self).url(forResource: "PixabayJson",
                                                      withExtension: "json")
        XCTAssertNotNil(json, "There is no file with pixabay json")
        guard let json = json else { fatalError() }

        let dataString = try? String(contentsOf: json, encoding: .utf8)
        XCTAssertNotNil(dataString)
        guard let dataString = dataString else { fatalError() }

        imageListRequestSender = ImageListRequestSender(
            session: URLSessionStub(data: Data(dataString.utf8),
                                    response: response,
                                    error: nil)
        )
        let config = RequestConfig<ImageListParser>(request: ImageListRequest(), parser: ImageListParser())
        imageListRequestSender?.send(config: config, completionHandler: { res in
            switch res {
            case .success(let imageList):
                XCTAssertEqual((imageList.hits?.count)!, 3)
                XCTAssertEqual((imageList.hits?.first?.previewURL)!, self.expectedPreviewURL)
                XCTAssertEqual((imageList.hits?.first?.largeImageURL)!, self.expectedLargeImageURL)
            case .failure(let error):
                XCTFail("Shouldn't be error, \(error.localizedDescription)")
            }

        })
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
