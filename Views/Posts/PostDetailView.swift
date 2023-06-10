//
//  PostDetailView.swift
//  Board
//
//  Created by 정호길 on 2022/12/13.
//

import SwiftUI

struct PostDetailView: View {
    @ObservedObject var boardModel: BoardModel
    @EnvironmentObject var accountModel: AccountModel
    
    var post: Post
    @State private var content: PostContent? = nil
    @State private var isEditingSheetPresented = false
    @State private var isDeleteSheetPresented = false
    
    @State private var isLoading: Bool = false
    @State private var isReceived: Bool = false
    @State private var isReportCompleted: Bool = false
    
    @State private var isReportingSheetPresented = false
    @State private var isCommentReportingSheetPresented = false
    @State private var selectedReportReason: Policy?
    @State private var selectedCommentId: Int? = nil
    @State private var isUserBlocked: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    private let adUnitID = Bundle.main.infoDictionary?["PostDetailBannerID"] as! String
    
    var isOwner: Bool {
        if let user = accountModel.currentUser, let postContent = content {
           return user.id == postContent.userID
        } else {
            return false
        }
    }
    
    var filteredComments: [Comment] {
        boardModel.comments.filter {
            !$0.isBlocked
        }
    }

    var body: some View {
        ZStack {
            VStack {
                List {
                    VStack(alignment: .leading, spacing: 2) {
                        if let postContent = self.content {
                            Text(postContent.title)
                                .font(.title2)
                                .bold()
                            
                            Text(postContent.author)
                                .font(.subheadline)
                                .bold()
                            
                            Text(postContent.formmatedDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    BannerAd(adUnitID: adUnitID)
                        .frame(height:50)
                        .listRowSeparator(.hidden, edges: .bottom)
                        .listRowInsets(.init())
                    
                    VStack(alignment: .leading) {
                        if let postContent = self.content {
                            Text("\n\(postContent.content)\n")
                                .font(.body)
                        }
                    }
                    .listRowSeparator(.hidden, edges: .top)
                    
                    Section {
                        ForEach(filteredComments) { comment in
                            CommentRow(comment: comment)
                                .swipeActions {
                                    if let user = accountModel.currentUser {
                                        if comment.user.id == user.id {
                                            Button(role: .destructive, action: {
                                                Task {
                                                    await deleteComment(commentId: comment.id)
                                                }
                                            }, label: {
                                                Label("", systemImage: "trash")
                                            })
                                        } else {
                                            Button {
                                                selectedCommentId = comment.id
                                                isCommentReportingSheetPresented.toggle()
                                            } label: {
                                                Label("", systemImage: "exclamationmark.bubble")
                                            }
                                        }
                                    }
                                }
                        }
                    }
                    .listRowSeparator(.hidden, edges: .bottom)
                    .listSectionSeparator(.hidden, edges: .bottom)
                }
                .listStyle(.inset)
                .scrollDismissesKeyboard(.immediately)
                
                Divider()
                
                CommentWriteForm(writeComment: writeComment)
            }
            
            if isLoading {
                ProgressView()
            }
        }
        .toolbar {
            ToolbarItemGroup {
                toolbarItems
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isEditingSheetPresented) {
            PostEditView(boardModel: boardModel, postId: post.id, postContent: content)
        }
        .refreshable {
            Task {
                await loadPost(forceUpdate: true)
            }
        }
        .sheet(isPresented: $isReportingSheetPresented, onDismiss: {
            if selectedReportReason != nil { reportPost() }
            if isUserBlocked { addBlockedUser() }
            dismiss()
        }) {
            PostReportView(selection: $selectedReportReason, block: $isUserBlocked)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isCommentReportingSheetPresented, onDismiss: {
            if selectedReportReason != nil { reportComment() }
            if isUserBlocked { addBlockedUser() }
        }) {
            CommentReportView(selection: $selectedReportReason, block: $isUserBlocked)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .alert("Are you sure you want to delete?", isPresented: $isDeleteSheetPresented) {
            Button("Delete", role: .destructive) {
                Task {
                    await deletePost()
                }
                dismiss()
            }
        }
        .task {
            isLoading = true
            await loadPost()
            await loadComments()
            isLoading = false
        }
    }
    
    var toolbarItems: some View {
        Menu {
            if isOwner {
                Button {
                    isEditingSheetPresented = true
                } label: {
                    Label("Edit", systemImage: "pencil.tip.crop.circle.badge.plus")
                }
                
                Button {
                    isDeleteSheetPresented = true
                } label: {
                    Label("Delete", systemImage: "trash.circle")
                }
            } else {
                Button {
                    isReportingSheetPresented = true
                } label: {
                    Label("Report", systemImage: "flag")
                }
            }
        } label: {
            Label("Options", systemImage: "ellipsis.circle")
                .labelsHidden()
        }
    }
    
    private func loadPost(forceUpdate: Bool = false) async {
        do {
            if self.content == nil {
                if let content = post.content {
                    self.content = content
                } else {
                    self.content = try await boardModel.loadPostContent(postId: post.id)
                }
            } else if forceUpdate {
                self.content = try await boardModel.loadPostContent(postId: post.id, forceUpdate: forceUpdate)
            }
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    private func deletePost() async {
        do {
            if let user = accountModel.currentUser {
                try await boardModel.delete(user: user, post: post)
            }
        } catch let error {
            debugPrint("\(error.localizedDescription)")
        }
    }
    
    private func reportPost() {
        if accountModel.currentUser != nil {
            boardModel.addBlockedPostId(postId: post.id)
        }
    }
    
    private func reportComment() {
        guard let commentId = selectedCommentId else {
            return
        }
        if accountModel.currentUser != nil {
            boardModel.addBlockedComment(commentId: commentId)
        }
    }
    
    private func writeComment(content: String) async {
        do {
            if let user = accountModel.currentUser {
                try await boardModel.writeComment(user: user, postId: self.post.id, content: content)
                
                await loadComments()
            }
        } catch let error {
            debugPrint("\(error.localizedDescription)")
        }
    }
    
    private func loadComments() async {
        do {
            try await boardModel.loadComments(postId: post.id)
        } catch let error {
            debugPrint("\(error.localizedDescription)")
        }
    }
    
    private func deleteComment(commentId: Int) async {
        do {
            if let user = accountModel.currentUser {
                try await boardModel.deleteComment(commentId: commentId, userId: user.id)
            }
        } catch let error {
            debugPrint("\(error.localizedDescription)")
        }
    }
    
    private func addBlockedUser() {
        if accountModel.currentUser != nil {
            if selectedCommentId != nil {
                boardModel.addBlockedUser(commentId: selectedCommentId!)
                selectedCommentId = nil
            } else {
                boardModel.addBlockedUser(userId: post.user!.id)
            }
            isUserBlocked = false
        }
    }
}

struct PostDetail_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var boardModel = BoardModel.preview
        
        var body: some View {
            PostDetailView(boardModel: boardModel, post: boardModel.posts.first ?? Post.preview)
        }
    }
    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
