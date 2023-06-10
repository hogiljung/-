//
//  SignUpView.swift
//  Board
//
//  Created by 정호길 on 2022/11/23.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var accoutModel: AccountModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var password = ""
    @State private var showErrorMessage: Bool = false
    @State private var isLoading = false
    @State private var errorMessage: LocalizedStringKey = ""
    @State private var isOn = false
    
    var body: some View {
        VStack {
            TextField("ID", text: $username)
                .autocorrectionDisabled(true)
                .textFieldStyle(.roundedBorder)
                .padding()
            SecureField("PW", text: $password)
                .autocorrectionDisabled(true)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Text(errorMessage)
                .foregroundColor(Color.red)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .opacity(showErrorMessage ? 1 : 0)
                .padding(.bottom, 8)
            
            Toggle(isOn: $isOn) {
                Text("I agree with the app [Terms and Conditions](https://sites.google.com/view/boardrodlswjdqh/%ED%99%88)\nand [Personal Information Processing Policy](https://sites.google.com/view/boardrodlswjdqh/%ED%99%88).")
                    .multilineTextAlignment(.leading)
            }
            .toggleStyle(CheckBox())
            
            Button {
                if isFormValid {
                    signUp()
                }
            } label: {
                Text("Sign Up")
                    .opacity(isLoading ? 0 : 1)
                    .overlay {
                        if isLoading {
                            ProgressView()
                        }
                    }
            }
            .padding()
            .disabled(isLoading)
        }
        .frame(maxWidth: 500, maxHeight: .infinity)
    }
    
    private struct CheckBox: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                Button {
                    configuration.isOn.toggle()
                } label: {
                    Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                }
                .buttonStyle(.plain)
                .controlSize(.large)
                configuration.label
                    .font(.subheadline)
            }
        }
    }
    
    private func signUp() {
        Task { @MainActor in
            do {
                try await accoutModel.signUp(username: username, password: password)
                    
                dismiss()
            } catch let error {
                switch error {
                case APIError.duplicatedUsername:
                    errorMessage = .init(AccountError.duplicatedUsername.errorDescription!)
                default:
                    errorMessage = .init(AccountError.unexpectedError.errorDescription!)
                }
                
                showErrorMessage = true
            }
        }
    }
    
    private var isFormValid: Bool {
        if !isOn {
            errorMessage = .init(AccountError.notAgree.errorDescription!)
            showErrorMessage = true
            return false
        }
        
        if username.isEmpty || password.isEmpty {
            errorMessage = .init(AccountError.emptyInput.errorDescription!)
            showErrorMessage = true
            return false
        }
        
        let regex = "^(?=.*[a-zA-Z0-9!@#$%^&*()_+=-]).{8,15}$"
        if password.range(of: regex, options: .regularExpression) == nil {
            errorMessage = .init(AccountError.invalidPassword.errorDescription!)
            showErrorMessage = true
            return false
        }
        
        showErrorMessage = false
        return true
    }
    
}

struct SignUpView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var accoutModel = AccountModel()
        var body: some View {
            SignUpView()
                .environmentObject(accoutModel)
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
