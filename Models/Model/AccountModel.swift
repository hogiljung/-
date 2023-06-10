//
//  AccountModel.swift
//  Board
//
//  Created by 정호길 on 2022/12/03.
//

import Foundation
import Alamofire

@MainActor
public class AccountModel: ObservableObject {
    @Published private(set) var currentUser: User? = nil

    private let store = Store()
    
    public var isSignedIn: Bool {
        currentUser != nil
    }
    
    func signInWithSavedAccount() async throws {
        currentUser = try await store.signInWithSavedAccount()
    }
    
    func signIn(username: String, password: String) async throws {
        currentUser = try await store.signIn(username: username, password: password)
    }
    
    func signUp(username: String, password: String) async throws {
        try await store.signUp(username: username, password: password)
    }
    
    func signOut() {
        currentUser = nil
        
        Task.detached {
            await self.store.signOut()
        }
    }
    
    func delete(userId: String) async throws {
        currentUser = nil
        
        try await self.store.delete(userId: userId)
    }
}

extension AccountModel {
    private actor Store {
        func signInWithSavedAccount() async throws -> User? {
            guard let username = try? KeychainItem(service: "com.semo.board", account: "username").readItem(),
                  let password = try? KeychainItem(service: "com.semo.board", account: "password").readItem()
            else {
                throw AccountError.unAuthorized
            }
            
            return try await signIn(username: username, password: password)
        }
        
        func signIn(username: String, password: String) async throws -> User? {
            let apiResponse: APIResponse<User> = try await self.signIn(username: username, password: password)
            
            if apiResponse.isSucceeded {
                if let user = apiResponse.result {
                    self.saveUserInKeychain(user.id, username, password)
                    return user
                } else {
                    return nil
                }
            } else if apiResponse.code == "002"{
                throw APIError.failedSignIn
            } else {
                debugPrint("apiResponse code: \(apiResponse.code)")
                throw APIError.failedSignIn
            }
        }
        
        private func signIn(username: String, password: String) async throws -> APIResponse<User> {
            let parameters: [String: String] = [
                "username": username,
                "password": password,
                "token": try KeychainItem(service: "com.semo.board", account: "FirebaseToken").readItem()
            ]
            
            return try await AF.request(APIRouter.signin(parameters))
                .serializingDecodable(APIResponse<User>.self).value
        }
        
        func signUp(username: String, password: String) async throws {
            let apiResponse: APIResponse<User> = try await self.signUp(username: username, password: password)
            
            if apiResponse.isSucceeded {
                return
            } else if apiResponse.code == "001" {
                throw APIError.duplicatedUsername
            } else {
                throw APIError.invalidSignForm
            }
        }
        
        private func signUp(username: String, password: String) async throws -> APIResponse<User> {
            let parameters: [String: String] = [
                "username": username,
                "password": password,
                "token": try KeychainItem(service: "com.semo.board", account: "FirebaseToken").readItem()
            ]
            
            return try await AF.request(APIRouter.signup(parameters)).serializingDecodable(APIResponse<User>.self).value
        }
        
        /*
        func signOut() {
            KeychainItem.deleteUserIdentifierFromKeychain()
        }
        
        func delete(userId: String) async throws {
            KeychainItem.deleteUserIdentifierFromKeychain()
            
            let parameters: [String: String] = [
                "id": userId
            ]
            
            _ = AF.request(APIRouter.deleteAccount(parameters))
                .serializingDecodable(APIResponse<User>.self)
        }
        
        private func saveUserInKeychain(_ userIdentifier: String) {
            do {
                try KeychainItem(service: "com.semo.board", account: "userIdentifier").saveItem(userIdentifier)
            } catch {
                print("Unable to save userIdentifier to keychain.")
            }
        }
        */
        
        func signOut() {
            do {
                try KeychainItem(service: "com.semo.board", account: "userIdentifier").deleteItem()
                try KeychainItem(service: "com.semo.board", account: "username").deleteItem()
                try KeychainItem(service: "com.semo.board", account: "password").deleteItem()
            } catch {
                print("Unable to delete userIdentifier from keychain")
            }
        }
        
        func delete(userId: String) async throws {
            self.signOut()
            
            let parameters: [String: String] = [
                "id": userId
            ]
            
            _ = AF.request(APIRouter.deleteAccount(parameters))
                .serializingDecodable(APIResponse<User>.self)
        }
        
        private func saveUserInKeychain(_ userIdentifier: User.ID, _ username: String, _ password: String) {
            do {
                try KeychainItem(service: "com.semo.board", account: "userIdentifier").saveItem(userIdentifier)
                try KeychainItem(service: "com.semo.board", account: "username").saveItem(username)
                try KeychainItem(service: "com.semo.board", account: "password").saveItem(password)
            } catch {
                print("Unable to save user to keychain.")
            }
        }
    }
}
