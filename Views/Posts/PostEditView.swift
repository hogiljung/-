//
//  PostEditView.swift
//  Board
//
//  Created by 정호길 on 2022/10/08.
//

import SwiftUI

struct PostEditView: View {
    @ObservedObject var boardModel: BoardModel
    @EnvironmentObject var accountModel: AccountModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: FocusField?
    
    let postId: Int
    @State var postContent: PostContent?

    @State private var isUploading = false
    @State private var isLoading = false
    
    @State private var isCancelAlertPresented = false
    
    private let titlePlaceHolder: LocalizedStringKey = "Title"
    private let textAreaPlaceHolder: LocalizedStringKey = "Content"
    
    private enum FocusField: Hashable {
        case title
        case content
    }
    
    var body: some View {
        ScrollView {
            VStack {
                TextField(titlePlaceHolder,
                          text: Binding<String>(
                                get: { postContent?.title ?? "" },
                                set: { postContent?.title = $0 })
                )
                .focused($focusedField, equals: .title)
                .font(.headline)
                .padding(8)
                
                Divider()
                
                TextField(textAreaPlaceHolder, text: Binding<String>(
                    get: { postContent?.content ?? "" }, set: { postContent?.content = $0 }), axis: .vertical)
                .focused($focusedField, equals: .content)
                .padding(8)
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    if let postContent = postContent, !postContent.title.isEmpty || !postContent.content.isEmpty {
                        isCancelAlertPresented = true
                    } else {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    if let postContent = postContent {
                        if postContent.title.isEmpty {
                            focusedField = .title
                        } else if postContent.content.isEmpty {
                            focusedField = .content
                        } else {
                            saveBoard()
                        }
                    }
                } label: {
                    Text("Post")
                        .opacity(isUploading ? 0 : 1)
                        .overlay {
                            if isUploading {
                                ProgressView()
                            }
                        }
                }
                .disabled(!isValid)
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(isModify ? "Edit Post" : "New Post")
        .navigationBarBackButtonHidden(true)
        .alert(Text("Are you sure you want to cancel the edit?"), isPresented: $isCancelAlertPresented) {
            Button("Continue", role: .destructive) {
                dismiss()
            }
        }
    }
    
    private func saveBoard() {
        Task {
            do {
                if let user = accountModel.currentUser, let postContent = postContent {
                    isUploading = true
                    if isModify {
                        try await boardModel.modify(user: user, postId: postId, postContent: postContent)
                    } else {
                        try await boardModel.save(user: user, title: postContent.title, content: postContent.content)
                    }
                    isUploading = false
                    
                    dismiss()
                }
            } catch {
                debugPrint("Save Post Error:\(error.localizedDescription)")
            }
        }
    }
    
    private var isValid: Bool {
        if let postContent = postContent {
            return !postContent.title.isEmpty && !postContent.content.isEmpty
        }
        return false
    }
    
    private var isModify: Bool {
        return postId != 0
    }
}

struct PostEditView_Previews: PreviewProvider {
    struct PreviewEdit: View {
        @StateObject private var boardModel = BoardModel.preview
        @State private var post: Post = Post.preview
        
        var body: some View {
            PostEditView(boardModel: boardModel, postId: post.id, postContent: post.content)
        }
    }
    
    struct PreviewCreate: View {
        @StateObject private var boardModel = BoardModel.preview
        @State private var post: Post = Post.default
        var body: some View {
            PostEditView(boardModel: boardModel, postId: post.id, postContent: post.content)
        }
    }
    static var previews: some View {
        Group {
            NavigationStack {
                PreviewCreate()
            }
            
            NavigationStack {
                PreviewEdit()
            }
        }
        
    }
}
