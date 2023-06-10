//
//  PostContent.swift
//  Board
//
//  Created by 정호길 on 2023/01/18.
//

import Foundation

struct PostContent: Hashable {
    var title: String
    var content: String
    var updatedDate: Date
    var author: String
    var userID: String
    var deleted: Int8
}

extension PostContent: Codable {
    private enum CodingKeys: String, CodingKey {
        case title
        case content
        case updatedDate = "updated_date"
        case author
        case userID = "user_id"
        case deleted
    }
}

extension PostContent {
    static let `default` = PostContent(title: "", content: "", updatedDate: .now, author: "", userID: "", deleted: 0)
}

extension PostContent {
    var formmatedDate: String {
        let date = updatedDate.formatted(date: .numeric, time: .omitted)
        let time = updatedDate.formatted(date: .omitted, time: .shortened)
        return "\(date) \(time)"
    }
}
