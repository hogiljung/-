//
//  BoardModel.swift
//  Board
//
//  Created by 정호길 on 2022/12/09.
//

import Foundation
import SwiftUI
import Alamofire

@MainActor
public class BoardModel: ObservableObject {
    private let postCache: NSCache<NSString, CacheEntryObject> = NSCache()
    private let store = Store()
    
    @Published private(set) var posts: [Post] = []
    private(set) var blockedPostIds: Set<Int> = []
    
    @Published private(set) var isUploadingPost: Bool = false
    
    @Published private(set) var comments: [Comment] = []
    private(set) var blockedCommentIds: Set<Int> = []
    
    private(set) var blockedUserIds: Set<String> = []
    
    func loadPosts(forceUpdate: Bool = false) async throws {
        if let allPost = try await store.loadPosts() {
            var updatedPosts = allPost
            if !blockedPostIds.isEmpty {
                for index in updatedPosts.startIndex..<updatedPosts.count {
                    updatedPosts[index].isBlocked = blockedPostIds.contains(updatedPosts[index].id)
                }
            }
            
            if !blockedUserIds.isEmpty {
                for index in updatedPosts.startIndex..<updatedPosts.count {
                    updatedPosts[index].isBlocked = blockedUserIds.contains(updatedPosts[index].user!.id)
                }
            }
            
            /*
            //let indexRange = (updatedPosts.index(updatedPosts.endIndex, offsetBy: -5, limitedBy: 0) ?? 0)..<updatedPosts.endIndex
            let indexRange = updatedPosts.startIndex..<(updatedPosts.index(updatedPosts.startIndex, offsetBy: 10, limitedBy: updatedPosts.endIndex) ?? updatedPosts.endIndex)
            try await withThrowingTaskGroup(of: (Int, PostContent?).self) { group in
                for index in indexRange {
                    debugPrint("cached index: \(index)")
                    if !updatedPosts[index].isBlocked {
                        group.addTask {
                            let content = try await self.loadPostContent(postId: allPost[index].id)
                            return (index, content)
                        }
                    }
                }
                
                while let result = await group.nextResult() {
                    switch result {
                    case .failure(let error):
                        throw error
                    case .success(let (index, content)):
                        updatedPosts[index].content = content
                    }
                }
            }
            */
            self.posts = updatedPosts
        }
    }
    
    func loadPostContent(postId: Int, forceUpdate: Bool = false) async throws -> PostContent? {
        if !forceUpdate, let cached = postCache[postId] {
            switch cached {
            case .ready(let content):
                return content
            case .inProgress(let task):
                return try await task.value
            }
        }
        let task = Task<PostContent?, Error> {
            let content = try await store.loadPostContent(postId: postId)
            return content
        }
        postCache[postId] = .inProgress(task)
        do {
            let content = try await task.value
            postCache[postId] = .ready(content)
            return content
        } catch {
            postCache[postId] = nil
            throw error
        }
    }
    
    func save(user: User, title: String, content: String) async throws {
        isUploadingPost = true
        try await store.save(title: title, content: content, userId: user.id)
        isUploadingPost = false
        /*
         Task(priority: .background) {
             do {
                 try await store.save(title: title, content: content, userId: user.id)
                 isUploadingPost = false
             } catch let error {
                 throw error
             }
         }
         */
    }
    
    func modify(user: User, postId: Int, postContent: PostContent) async throws {
        isUploadingPost = true
        postCache[postId] = .ready(postContent)
        try await store.modify(postId: postId, postContent: postContent, userId: user.id)
        isUploadingPost = false
    }
    
    func delete(user: User, post: Post) async throws {
        guard let index = self.posts.firstIndex(where: { $0.id == post.id }) else {
            fatalError()
        }
        self.posts.remove(at: index)
        
        try await store.delete(postId: post.id, userId: user.id)
    }
    
    func writeComment(user: User, postId: Int, content: String) async throws {
        try await store.writeComment(userId: user.id, postId: postId, content: content)
    }
    
    func postBinding(for id: Post.ID) -> Binding<Post> {
        Binding<Post> {
            guard let index = self.posts.firstIndex(where: { $0.id == id }) else {
                fatalError()
            }
            return self.posts[index]
        } set: { newValue in
            guard let index = self.posts.firstIndex(where: { $0.id == id }) else {
                fatalError()
            }
            return self.posts[index] = newValue
        }
    }
    
    func loadComments(postId: Int) async throws {
        if let allComment = try await store.loadComments(postId: postId) {
            var comments = allComment
            if !blockedCommentIds.isEmpty {
                for index in comments.startIndex..<comments.count {
                    comments[index].isBlocked = blockedCommentIds.contains(comments[index].id)
                }
            }
            
            if !blockedUserIds.isEmpty {
                for index in comments.startIndex..<comments.count {
                    comments[index].isBlocked = blockedUserIds.contains(comments[index].user.id)
                }
            }
            
            self.comments = comments
        }
    }
    
    func deleteComment(commentId: Int, userId: String) async throws {
        guard let index = self.comments.firstIndex(where: { $0.id == commentId }) else {
            fatalError()
        }
        self.comments.remove(at: index)
        
        try await store.deleteComment(commentId: commentId, userId: userId)
    }
    
    // MARK: For Blocked Post
    func addBlockedPostId(postId: Int) {
        guard let index = self.posts.firstIndex(where: { $0.id == postId }) else {
            fatalError()
        }
        self.posts[index].isBlocked = true
        
        blockedPostIds.insert(postId)
        debugPrint("added: \(postId)")
        debugPrint("blockedPostsIds: \(blockedPostIds)")
        
        Task.detached {
            await self.saveBlockedPostIds()
        }
    }
    
    func saveBlockedPostIds() async {
        await store.saveBlockedPostIds(blockedPostIds)
    }
    
    func loadBlockedPostIds() async {
        self.blockedPostIds = await store.loadBlockedPostIds()
    }
    
    // MARK: For Blocked Comment
    func addBlockedComment(commentId: Int) {
        guard let index = self.comments.firstIndex(where: { $0.id == commentId }) else {
            fatalError()
        }
        self.comments[index].isBlocked = true
        debugPrint(comments[index])
        
        blockedCommentIds.insert(commentId)
        debugPrint(blockedCommentIds)
        Task.detached {
            await self.saveBlockedCommentIds()
        }
    }
    
    func saveBlockedCommentIds() async {
        await store.saveBlockedCommentIds(blockedCommentIds)
    }
    
    func loadBlockedCommentIds() async {
        blockedCommentIds = await store.loadBlockedCommentIds()
        debugPrint("blocked Comment: \(blockedCommentIds)")
    }
    
    // MARK: For Blocked User
    func addBlockedUser(userId: String) {
        self.blockedUserIds.insert(userId)
        
        debugPrint("added: \(userId)")
        debugPrint("blockedUserIds: \(blockedUserIds)")
        Task.detached {
            await self.saveBlockedUserIds()
        }
    }
    
    func addBlockedUser(commentId: Int) {
        guard let index = self.comments.firstIndex(where: { $0.id == commentId }) else {
            fatalError()
        }
        addBlockedUser(userId: comments[index].user.id)
    }
    
    func saveBlockedUserIds() async {
        await store.saveBlockedUserIds(blockedUserIds)
    }
    
    func loadBlockedUserIds() async {
        blockedUserIds = await store.loadBlockedUserIds()
    }
    
    func post(for postId: Post.ID) -> Post {
        if let index = self.posts.firstIndex(where: { $0.id == postId }){
            return posts[index]
        } else {
            return Post(id: postId, content: nil)
        }
    }
    
    // MARK: - Private
}

extension BoardModel {
    private actor Store {
        func loadPosts() async throws -> [Post]? {
            do {
                let apiResponse: APIResponse = try await self.loadPosts()
                
                if apiResponse.isSucceeded {
                    return apiResponse.result
                } else {
                    throw APIError.networkError
                }
            } catch {
                print("*** An error occured while loading value \(error.localizedDescription) ***")
                throw error
            }
        }
        
        private func loadPosts() async throws -> APIResponse<[Post]> {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .customISO8601
                
                return try await AF.request(APIRouter.titleview).serializingDecodable(APIResponse<[Post]>.self, decoder: decoder).value
            } catch {
                // TODO: seperate errors
                print("*** An error occured while loading value \(error.localizedDescription) ***")
                throw error
            }
        }
        
        func loadPostContent(postId: Int) async throws -> PostContent? {
            do {
                let postContentResponse: APIResponse<PostContent> = try await self.loadPostContent(postId: postId)

                if !postContentResponse.isSucceeded {
                    throw APIError.networkError
                }
                
                return postContentResponse.result
            } catch {
                // TODO: seperate errors
                print("*** An error occured while loading value \(error.localizedDescription) ***")
                throw error
            }
        }
        
        private func loadPostContent(postId: Int) async throws -> APIResponse<PostContent> {
            do {
                let parameters = [
                    "post_id": String(postId)
                ]
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .customISO8601
                
                return try await AF.request(APIRouter.contentview(parameters)).serializingDecodable(APIResponse<PostContent>.self, decoder: decoder).value
            } catch {
                // TODO: seperate errors
                print("*** An error occured while loading value \(error.localizedDescription) ***")
                throw error
            }
        }
        
        @discardableResult
        func save(title: String, content: String, userId: String) async throws -> Post? {
            do {
                let apiResponse: APIResponse = try await self.save(title: title, content: content, userId: userId)
                
                if apiResponse.isSucceeded {
                    return apiResponse.result
                } else {
                    throw APIError.networkError
                }
            } catch {
                // TODO: seperate errors
                print("*** An error occured while saving value \(error.localizedDescription) ***")
                throw error
            }
        }
        
        private func save(title: String, content: String, userId: String) async throws -> APIResponse<Post> {
            do {
                let parameters = [
                    "title": title,
                    "content": content,
                    "user_id": userId
                ]
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .customISO8601
                
                return try await AF.request(APIRouter.post(parameters)).serializingDecodable(APIResponse<Post>.self, decoder: decoder).value
                
            } catch {
                // TODO: seperate errors
                print("*** An error occured while saving value \(error.localizedDescription) ***")
                throw error
            }
        }
        
        func modify(postId: Int, postContent: PostContent, userId: String) async throws -> Post? {
            do {
                let apiResponse: APIResponse = try await self.modify(postId: postId, postContent: postContent, userId: userId)
                
                if apiResponse.isSucceeded {
                    return apiResponse.result
                } else {
                    throw APIError.networkError
                }
            } catch {
                // TODO: seperate errors
                print("*** An error occured while saving value \(error.localizedDescription) ***")
                throw error
            }
        }
        
        private func modify(postId: Int, postContent: PostContent, userId: String) async throws -> APIResponse<Post> {
            do {
                let parameters = [
                    "post_id": String(postId),
                    "title": postContent.title,
                    "content": postContent.content,
                    "user_id": userId
                ]
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .customISO8601
                
                return try await AF.request(APIRouter.modify(parameters)).serializingDecodable(APIResponse<Post>.self, decoder: decoder).value
            } catch {
                // TODO: seperate errors
                print("*** An error occured while saving value \(error.localizedDescription) ***")
                throw error
            }
        }
        
        func delete(postId: Int, userId: String) async throws {
            do {
                let apiResponse: APIResponse = try await self.delete(postId: postId, userId: userId)
                
                if apiResponse.isSucceeded {
                    return
                } else {
                    throw APIError.unAuthorizedOptions
                }
            } catch {
                // TODO: seperate errors
                print("*** An error occured while deleting value \(error.localizedDescription) ***")
                throw error
            }
        }
        
        private func delete(postId: Int, userId: String) async throws -> APIResponse<Empty> {
            do {
                let parameters = [
                    "user_id": userId,
                    "post_id": String(postId)
                ]

                return try await AF.request(APIRouter.delete(parameters)).serializingDecodable(APIResponse<Empty>.self).value
            } catch {
                // TODO: seperate errors
                print("*** An error occured while deleting value \(error.localizedDescription) ***")
                throw error
            }
        }
        
        func writeComment(userId: String, postId: Int, content: String) async throws {
            do {
                let apiResponse: APIResponse = try await self.writeComment(userId: userId, postId: postId, content: content)
                
                if apiResponse.isSucceeded {
                    return
                } else {
                    throw APIError.unAuthorizedOptions
                }
            } catch {
                // TODO: seperate errors
                print("*** An error occured while writeComment value \(error.localizedDescription) ***")
                throw error
            }
        }
        
        private func writeComment(userId: String, postId: Int, content: String) async throws -> APIResponse<Comment> {
            do {
                let parameters = [
                    "user_id": userId,
                    "post_id": String(postId),
                    "content": content
                ]
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .customISO8601

                return try await AF.request(APIRouter.comment(parameters)).serializingDecodable(APIResponse<Comment>.self, decoder: decoder).value
            } catch {
                // TODO: seperate errors
                print("*** An error occured while writeComment value \(error.localizedDescription) ***")
                throw error
            }
        }
        
        func loadComments(postId: Int) async throws -> [Comment]?{
            do {
                let apiResponse: APIResponse = try await self.loadComments(postId: postId)
                
                if apiResponse.isSucceeded {
                    return apiResponse.result ?? []
                } else {
                    throw APIError.unAuthorizedOptions
                }
            } catch {
                // TODO: seperate errors
                print("*** loadComments: \(error.localizedDescription) ***")
                throw error
            }
        }
        
        private func loadComments(postId: Int) async throws -> APIResponse<[Comment]> {
            do {
                let parameters = [
                    "post_id": String(postId)
                ]
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .customISO8601

                return try await AF.request(APIRouter.commentsview(parameters)).serializingDecodable(APIResponse<[Comment]>.self, decoder: decoder).value
            } catch {
                // TODO: seperate errors
                print("*** loadComments: \(error.localizedDescription) ***")
                throw error
            }
        }
        
        func deleteComment(commentId: Int, userId: String) async throws {
            do {
                let apiResponse: APIResponse = try await self.deleteComment(commentId: commentId, userId: userId)
                
                if apiResponse.isSucceeded {
                    return
                } else {
                    throw APIError.unAuthorizedOptions
                }
            } catch {
                // TODO: seperate errors
                print("*** An error occured while deleting value \(error.localizedDescription) ***")
                throw error
            }
        }
        
        private func deleteComment(commentId: Int, userId: String) async throws -> APIResponse<Empty> {
            do {
                let parameters = [
                    "user_id": userId,
                    "id": String(commentId)
                ]

                return try await AF.request(APIRouter.deletecomment(parameters)).serializingDecodable(APIResponse<Empty>.self).value
            } catch {
                // TODO: seperate errors
                print("*** An error occured while deleting value \(error.localizedDescription) ***")
                throw error
            }
        }
        
        // MARK: For Blocked Post
        func saveBlockedPostIds(_ blockedPostIds: Set<Int>) {
            UserDefaults.standard.set(Array(blockedPostIds), forKey: "BlockedPostIds")
        }
        
        func loadBlockedPostIds() -> Set<Int> {
            Set(UserDefaults.standard.array(forKey: "BlockedPostIds") as? [Int] ?? [])
        }
        
        // MARK: For Blocked Comment
        func saveBlockedCommentIds(_ blockedCommentIds: Set<Int>) {
            UserDefaults.standard.set(Array(blockedCommentIds), forKey: "BlockedCommentIds")
        }
        
        func loadBlockedCommentIds() -> Set<Int> {
            Set(UserDefaults.standard.array(forKey: "BlockedCommentIds") as? [Int] ?? [])
        }
        
        // MARK: For Blocked User
        func saveBlockedUserIds(_ blockedUserIds: Set<String>) {
            UserDefaults.standard.set(Array(blockedUserIds), forKey: "BlockedUserIds")
        }
        
        func loadBlockedUserIds() -> Set<String> {
            Set(UserDefaults.standard.array(forKey: "BlockedUserIds") as? [String] ?? [])
        }
        
        /*
        func save(_ blockedPostIds: [Int]) {
            let data: Data
            do {
                data = try JSONEncoder().encode(blockedPostIds)
            } catch {
                print("*** An error occured while saving blockedPostIds value \(error.localizedDescription) ***")
                return
            }
            
            do {
                try data.write(to: dataURL, options: [.atomic])
            } catch {
                print("*** An error occured while saving blockedPostIds value \(error.localizedDescription) ***")
            }
        }
        
        func load() -> [Int] {
            load(from: .main)
        }
        
        private func load(from bundle: Bundle) -> [Int] {
            var blockedPostIds: [Int]
            do {
                let data = try Data(contentsOf: dataURL, options: .mappedIfSafe)
                blockedPostIds = try JSONDecoder().decode([Int].self, from: data)
            } catch CocoaError.fileNoSuchFile {
                blockedPostIds = []
            } catch let error {
                print("*** An error occured while loading blockedPostIds value \(error.localizedDescription) ***")
                blockedPostIds = []
            }
            return blockedPostIds
        }
        
        
        // Provide the URL for the JSON file that stores the airport data.
        private var dataURL: URL {
            get throws {
                try FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
                )
                // Append the filename to the directory.
                .appendingPathComponent("BlockedPostIds.json")
            }
        }
        */
    }
}

extension BoardModel {
    static var preview: BoardModel {
        let preview = BoardModel()
        preview.posts = Post.previews
        preview.comments = Comment.previews
        return preview
    }
}
