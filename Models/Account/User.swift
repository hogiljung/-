//
//  User.swift
//  Board
//
//  Created by 정호길 on 2022/11/03.
//

import Foundation

struct User: Identifiable, Hashable {
    var id: String
    var username: String?
    var createdDate: Date?
}

extension User: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case createdDate = "created_date"
    }
}
