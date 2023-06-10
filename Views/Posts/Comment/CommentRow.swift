//
//  CommentRow.swift
//  Board
//
//  Created by 정호길 on 2023/02/17.
//

import SwiftUI

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(comment.user.username ?? "")
                .font(.subheadline)
                .bold()
            Text(comment.content)
                .font(.body)
            Text(comment.formmatedDate)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct CommentRow_Previews: PreviewProvider {

    static var previews: some View {
        CommentRow(comment: .preview)
    }
}
