//
//  Request.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 22.04.2021.
//

import Foundation

protocol IRequest {
    var urlRequest: URLRequest? { get }
}

struct ImageListRequest: IRequest {
    var urlRequest: URLRequest?
    
    init() {
        guard
            let token = getApiToken(),
            let url = URL(string:
                            "https://pixabay.com/api/?key=\(token)&q=cars&image_type=photo&pretty=true&per_page=\(AvatarPickerDataSource.numberOfImages)")
        else { return }
        urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5)
    }
    
    private func getApiToken() -> String? {
        var resourceFileDictionary: NSDictionary?
            
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            resourceFileDictionary = NSDictionary(contentsOfFile: path)
        }
        
        if let resourceFileDictionaryContent = resourceFileDictionary {
            return resourceFileDictionaryContent.object(forKey: "PixabayToken") as? String
        } else { return nil }
    }
}
