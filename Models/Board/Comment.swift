//
//  Comment.swift
//  Board
//
//  Created by 정호길 on 2023/02/17.
//

import Foundation

struct Comment: Identifiable {
    var id: Int
    var user: User
    var content: String
    var updatedDate: Date
    var isBlocked: Bool = false
}

extension Comment: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case user
        case content
        case updatedDate = "updated_date"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawId = try? values.decode(Int.self, forKey: .id)
        let rawUser = try? values.decode(User.self, forKey: .user)
        let rawContent = try? values.decode(String.self, forKey: .content)
        let rawUpdatedDate = try? values.decode(Date.self, forKey: .updatedDate)
        
        guard let id = rawId,
              let user = rawUser,
              let content = rawContent,
              let updatedDate = rawUpdatedDate
        else {
            throw APIError.failedSignIn
        }
        
        self.id = id
        self.user = user
        self.content = content
        self.updatedDate = updatedDate
    }
}

extension Comment {
    var formmatedDate: String {
        let date = updatedDate.formatted(date: .numeric, time: .omitted)
        let time = updatedDate.formatted(date: .omitted, time: .shortened)
        return "\(date) \(time)"
    }
}


extension Comment {
    static var preview: Comment {
        return Comment(id: 1, user: User(id: "3f06af63-a93c-11e4-9797-00505690773f", username: "hogil"), content: "this is comment content", updatedDate: Date.init(timeIntervalSince1970: 10000000))
    }
    
    static var preview2: Comment {
        return Comment(id: 2, user: User(id: "3f06af63-a93c-11e4-9797-00505690773f", username: "suhun"), content: "this is comment content, too", updatedDate: Date.init(timeIntervalSince1970: 10000000))
    }
    
    static var previews: [Comment] {
        return [Comment.preview, Comment.preview2]
    }
}
