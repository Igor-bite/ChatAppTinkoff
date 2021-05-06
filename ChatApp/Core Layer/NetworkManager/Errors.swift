//
//  Errors.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 23.04.2021.
//

import UIKit

enum NetworkError: Error, Equatable {
    case badURL(String = "No URLRequest")
    case noResponse(String = "There is no response from api")
    case noData(String = "There is no data from api")
    case apiError(String)
    case unspecified
}
