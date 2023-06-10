//
//  PostsView.swift
//  Board
//
//  Created by 정호길 on 2022/11/04.
//

import SwiftUI
import AppTrackingTransparency

struct PostsView: View {
    @EnvironmentObject var accountModel: AccountModel
    @ObservedObject var boardModel: BoardModel
    @EnvironmentObject var permissionModel: PermissionsModel

    @State private var hasError = false

    @State private var isLoading = false
    
    @State private var isReceived = false
    
    private let adUnitID = Bundle.main.infoDictionary?["PostsBannerID"] as! String

    var filteredPosts: [Post] {
        boardModel.posts.filter { post in
            !post.isBlocked
        }
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(filteredPosts) { post in
                    NavigationLink(value: post.id) {
                        PostRow(post: post)
                    }
                }
            }
            .listStyle(.plain)
        }
        .task {
            await fetchPosts()
        }
        .refreshable {
            await fetchPosts()
        }
        .safeAreaInset(edge: .top) {
            BannerAd(adUnitID: adUnitID)
                .frame(height:50)
        }
        .navigationDestination(for: Post.ID.self) { id in
            PostDetailView(boardModel: boardModel, post: boardModel.post(for: id))
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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

struct PostListView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var boardModel = BoardModel.preview
        @StateObject private var accoutModel = AccountModel()
        
        var body: some View {
            PostsView(boardModel: boardModel)
                .environmentObject(accoutModel)
        }
    }
    static var previews: some View {
        NavigationStack {
            Preview()
        }
    }
}
