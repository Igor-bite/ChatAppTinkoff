//
//  RequestConfig.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 22.04.2021.
//

import Foundation

enum NetworkError: Error {
    case badURL
}

struct RequestConfig<Parser> where Parser: IParser {
    let request: IRequest
    let parser: Parser
}

protocol IRequestSender {
    func send<ImageListParser>(config: RequestConfig<ImageListParser>,
                               completionHandler: @escaping (Result<ImageListParser.Model, Error>) -> Void)
}

struct ImageListRequestSender: IRequestSender {
    let session = URLSession.shared
    
    func send<ImageListParser>(config: RequestConfig<ImageListParser>,
                               completionHandler: @escaping (Result<ImageListParser.Model, Error>) -> Void) where ImageListParser: IParser {
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(.failure(NetworkError.badURL))
            return
        }
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            
            guard
            let data = data,
            let parsedModel: ImageListParser.Model = config.parser.parse(data: data) else {
                completionHandler(.failure(ParsingError.error))
                return
            }
            completionHandler(.success(parsedModel))
        }
        task.resume()
    }
}
