//
//  CommentWriteForm.swift
//  Board
//
//  Created by 정호길 on 2023/02/24.
//

import SwiftUI

struct CommentWriteForm: View {
    var writeComment: (String) async -> Void

    @State private var content = ""
    @State private var isLoading = false
    
    var body: some View {
        HStack {
            TextField("Write a Comment", text: $content, axis: .vertical)
            
            Button {
                Task {
                    isLoading = true
                    await writeComment(content)
                    isLoading = false
                    formClear()
                }
            } label: {
                Text("Post")
                    .opacity(isLoading ? 0 : 1)
                    .overlay {
                        if isLoading {
                            ProgressView()
                        }
                    }
            }
            .disabled(!isFormValid)
            .disabled(isLoading)
        }
        .offset(y:-6)
        .padding()
    }
    
    private func formClear() {
        content = ""
    }
    
    private var isFormValid: Bool {
        return !content.isEmpty
    }
}

struct CommentWriteForm_Previews: PreviewProvider {
    struct Preview: View {
        private func writeComment(content: String) async {}
        @FocusState private var focusedField: Bool
        var body: some View {
            CommentWriteForm(writeComment: writeComment)
        }
    }
    static var previews: some View {
        Preview()
    }
}
