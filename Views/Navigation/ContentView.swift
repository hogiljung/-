//
//  ContentView.swift
//  Board
//
//  Created by 정호길 on 2022/11/23.
//

import SwiftUI
import os

struct ContentView: View {
    @EnvironmentObject var accountModel : AccountModel
    @ObservedObject var boardModel: BoardModel
    
    @State private var isAccountSheetPresented = false
    
    var body: some View {
        ZStack {
            if accountModel.isSignedIn {
                BoardView(boardModel: boardModel)
            } else {
                ProgressView()
                    .controlSize(.large)
                .task {
                    await signedWithSavedAccount()
                }
            }
        }
        .fullScreenCover(isPresented: $isAccountSheetPresented) {
            SignInView(isAccountSheetPresented: $isAccountSheetPresented)
        }
    }
    
    private func signedWithSavedAccount() async {
        do {
            try await accountModel.signInWithSavedAccount()
        } catch let error {
            print(error.localizedDescription)
            isAccountSheetPresented = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var accountModel = AccountModel()
        @StateObject private var boardModel = BoardModel.preview
        
        var body: some View {
            ContentView(boardModel: boardModel)
                .environmentObject(accountModel)
        }
    }
    static var previews: some View {
        Preview()
    }
}
