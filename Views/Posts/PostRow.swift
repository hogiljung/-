//
//  BoardRow.swift
//  Board
//
//  Created by 정호길 on 2022/12/13.
//

import SwiftUI

struct PostRow: View {
    @Environment(\.colorScheme) var colorScheme
    var post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(post.title ?? "")
                    .font(.body)
                
                Text("[\((post.commentCount ?? 0))]")
                    .font(.footnote)
                    .fixedSize(horizontal: true, vertical: true)
            }
            
            HStack {
                Text(post.user?.username ?? "")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(post.formmatedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
        PostRow(post: Post.preview)
    }
}
