//
//  RequestSender.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 23.04.2021.
//

import UIKit

protocol IRequestSender {
    func send<ImageListParser>(config: RequestConfig<ImageListParser>,
                               completionHandler: @escaping (Result<ImageListParser.Model, Error>) -> Void)
}

struct ImageListRequestSender: IRequestSender {
    let session = URLSession.shared
    
    func send<ImageListParser>(config: RequestConfig<ImageListParser>,
                               completionHandler: @escaping (Result<ImageListParser.Model, Error>) -> Void) where ImageListParser: IParser {
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(.failure(NetworkError.badURL()))
            return
        }
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.failure(NetworkError.noResponse()))
                return
            }
            guard let data = data else {
                completionHandler(.failure(NetworkError.noData()))
                return
            }
            if httpResponse.statusCode != 200 {
                let errorDescription = String(data: data, encoding: .utf8)
                if let errorDescription = errorDescription {
                    let index = errorDescription.firstIndex(of: "]") ?? errorDescription.endIndex
                    var description = errorDescription.suffix(from: index)
                    description = description.suffix(description.count - 2)
                    completionHandler(.failure(NetworkError.apiError(String(description))))
                    return
                }
            }
            
            guard let parsedModel: ImageListParser.Model = config.parser.parse(data: data) else {
                completionHandler(.failure(ParsingError.error))
                return
            }
            completionHandler(.success(parsedModel))
        }
        task.resume()
    }
}
