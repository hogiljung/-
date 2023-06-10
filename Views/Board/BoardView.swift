//
//  BoardView.swift
//  Board
//
//  Created by 정호길 on 2023/01/09.
//

import SwiftUI

struct BoardView: View {
    @EnvironmentObject var accountModel: AccountModel
    @ObservedObject var boardModel: BoardModel
    @EnvironmentObject var navigationModel: NavigationModel
    @EnvironmentObject var permissionModel: PermissionsModel

    @State private var showSettingSheetPresented = false
    @State private var showWritingSheetPresented = false

    @State private var post: Post = Post.default
    
    @State private var hasError = false
    @State private var isLoading = false
        
    var body: some View {
        NavigationStack(path: $navigationModel.path) {
            /*
            if boardModel.isUploadingPost {
                Label {
                    Text("Uploading Post")
                } icon: {
                    ProgressView()
                }
            }
            */
            PostsView(boardModel: boardModel)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettingSheetPresented.toggle()
                    } label: {
                        Label("", systemImage: "person.circle")
                    }
                }
                
                ToolbarItem() {
                    Button {
                        showWritingSheetPresented.toggle()
                    } label: {
                        Label("", systemImage: "square.and.pencil")
                    }
                }
            }
            .navigationDestination(isPresented: $showSettingSheetPresented) {
                SettingsView()
            }
            .navigationDestination(isPresented: $showWritingSheetPresented) {
                PostEditView(boardModel: boardModel, postId: post.id, postContent: post.content)
            }
        }
        .task {
            await boardModel.loadBlockedUserIds()
            await boardModel.loadBlockedPostIds()
            await boardModel.loadBlockedCommentIds()
        }
        .onReceive(permissionModel.$notificationPermissionGranted) { _ in
            Task {
                await permissionModel.requestATTPermission()
            }
        }
    }
    
    private func fetchPosts() async {
        isLoading = true
        do {
            try await boardModel.loadPosts()
        } catch {
            hasError = true
        }
        isLoading = false
    }
}

struct BoardView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var boardModel = BoardModel.preview
        
        var body: some View {
            BoardView(boardModel: boardModel)
        }
    }
    static var previews: some View {
        Preview()
    }
}
