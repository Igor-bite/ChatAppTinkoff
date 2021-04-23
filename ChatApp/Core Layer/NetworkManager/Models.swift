//
//  Models.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 22.04.2021.
//

import Foundation

struct ImageList: Codable {
    var hits: [Hit]?
}

struct Hit: Codable {
    var previewURL: String?
    var largeImageURL: String?
}
