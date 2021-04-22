//
//  Parser.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 22.04.2021.
//

import Foundation

enum ParsingError: Error {
    case error
}

protocol IParser {
    associatedtype Model
    func parse(data: Data) -> Model?
}

struct ImageListParser: IParser {
    typealias Model = ImageList
    
    func parse(data: Data) -> Model? {
        return try? JSONDecoder().decode(ImageList.self, from: data)
    }
}
