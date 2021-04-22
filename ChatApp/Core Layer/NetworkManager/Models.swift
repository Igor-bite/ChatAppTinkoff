//
//  Models.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 22.04.2021.
//

import Foundation

struct ImageList: Codable {
    var total: Int?
    var totalHits: Int?
    var hits: [Hit]?
}

struct Hit: Codable {
    var id: Int?
    var pageURL: String?
    var previewURL: String?
    var largeImageURL: String?
}
