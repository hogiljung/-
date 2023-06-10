//
//  Comments.swift
//  Board
//
//  Created by 정호길 on 2023/02/17.
//

import SwiftUI

struct CommentsView: View {
    let comments: [Comment]
    
    var body: some View {
        List {
            ForEach(comments) { comment in
                CommentRow(comment: comment)
            }
        }
    }
}

struct Comments_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView(comments: Comment.previews)
    }
}
