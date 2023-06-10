//
//  Post.swift
//  Board
//
//  Created by 정호길 on 2023/02/25.
//

import Foundation

struct Post: Identifiable, Hashable {
    var id: Int
    var title: String?
    var briefDescription: String?
    var content: PostContent?
    var createdDate: Date?
    var updatedDate: Date?
    var user: User?
    var commentCount: Int?
    var isBlocked: Bool = false
}

extension Post: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case briefDescription = "brief_description"
        case createdDate = "created_date"
        case updatedDate = "updated_date"
        case commentCount = "comment_count"
        case user
    }
}

extension Post {
    static let `default` = Post(id: 0, content: PostContent.default)
}

extension Post {
    var formmatedDate: String {
        if let updatedDate = updatedDate {
            let date = updatedDate.formatted(date: .numeric, time: .omitted)
            let time = updatedDate.formatted(date: .omitted, time: .shortened)
            return "\(date) \(time)"
        }
        return ""
    }
}


extension Post {
    static var preview: Post {
        var post = Post(
            id: 1,
            title: "Hi",
            briefDescription: "hello",
            createdDate: Date.init(timeIntervalSince1970: 10000000),
            updatedDate: Date.init(timeIntervalSince1970: 10000000),
            user: User(id: "3f06af63-a93c-11e4-9797-00505690773f", username:  "hogil"))
        post.content = PostContent(title: "hi", content: "hi my name is hogil.", updatedDate: Date.init(timeIntervalSince1970: 10000000), author: "hogil", userID: "3f06af63-a93c-11e4-9797-00505690773f", deleted: 0)
        
        return post
    }
    
    static var preview2: Post {
        var post = Post(
            id: 2,
            title: "HiHo",
            briefDescription: "hello hogil",
            createdDate: Date.init(timeIntervalSince1970: 10000000),
            updatedDate: Date.init(timeIntervalSince1970: 10000000),
            user: User(id: "3f06af63-a93c-11e4-9797-00505690773f", username:  "hogil"))
        post.content = PostContent(title: "hiho", content: "hi my name is hogil ~~~~.", updatedDate: Date.init(timeIntervalSince1970: 10000000), author: "hogil", userID: "3f06af63-a93c-11e4-9797-00505690773f", deleted: 0)
        
        return post
    }
    
    static var previews: [Post] {
        [preview, preview2]
    }
}
