//
//  PostUser.swift
//  Board
//
//  Created by 정호길 on 2023/01/18.
//

import Foundation

struct PostUser {
    var id: String
    var username: String
}

extension PostUser {
    static var `default` = PostUser(id: "", username: "")
}

extension PostUser: Codable {
    private enum PostUserCodingKeys: String, CodingKey {
        case id
        case username
    }
}
