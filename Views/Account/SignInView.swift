//
//  SignInView.swift
//  Board
//
//  Created by 정호길 on 2022/11/04.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var accountModel: AccountModel
    @Environment(\.colorScheme) var colorScheme
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var isLoading: Bool = false
    @FocusState private var focusedField: Field?
    @State private var errorMessage: LocalizedStringKey = ""
    @State private var showErrorMessage: Bool = false
    
    @Binding var isAccountSheetPresented: Bool
    
    enum Field: Hashable {
        case username
        case password
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(alignment: .center) {
                    Image("60")
                        .resizable()
                        .frame(width: 60, height: 60)
                    Group {
                        TextField("ID", text: $username)
                            .focused($focusedField, equals: .username)
                            .autocorrectionDisabled(true)
                            .textFieldStyle(.roundedBorder)
                        
                        SecureField("PW", text: $password)
                            .focused($focusedField, equals: .password)
                            .autocorrectionDisabled(true)
                            .textFieldStyle(.roundedBorder)
                            .padding(.top, 20)
                    }
                    .frame(maxWidth: 500)
                    .padding(.horizontal)
                    
                    Text(errorMessage)
                        .foregroundColor(Color.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .opacity(showErrorMessage ? 1 : 0)
                        .padding(.bottom, 8)
                    
                    Button {
                        if isFormValid {
                            signIn()
                        }
                    } label: {
                        Text("Sign In")
                            .opacity(isLoading ? 0 : 1)
                            .overlay {
                                if isLoading {
                                    ProgressView()
                                }
                            }
                    }
                    .padding()
                    .disabled(isLoading)
                    
                    NavigationLink {
                        showSignUpView()
                    } label: {
                        Text("Sign Up")
                    }
                    .disabled(isLoading)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        if username.isEmpty || password.isEmpty {
            errorMessage = .init(AccountError.emptyInput.errorDescription!)
            showErrorMessage = true
            return false
        }
        
        let regex = "^(?=.*[a-zA-Z0-9!@#$%^&*()_+=-]).{0,}$"
        if password.range(of: regex, options: .regularExpression) == nil {
            errorMessage = .init(AccountError.invalidPassword.errorDescription!)
            showErrorMessage = true
            return false
        }
        
        showErrorMessage = false
        return true
    }
    
    private func signIn() {
        Task { @MainActor in
            isLoading = true
            do {
                try await accountModel.signIn(username: username, password: password)
                
                isAccountSheetPresented = false
            } catch let error {
                switch error {
                case APIError.failedSignIn:
                    errorMessage = .init(AccountError.failedSignIn.errorDescription!)
                default:
                    errorMessage = .init(AccountError.unexpectedError.errorDescription!)
                }
                
                showErrorMessage = true
            }
            isLoading = false
        }
    }
    
    private func showSignUpView() -> some View {
        SignUpView()
    }
}

struct SignInView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var accoutModel = AccountModel()
        var body: some View {
            NavigationStack {
                SignInView(isAccountSheetPresented: .constant(false))
                    .environmentObject(accoutModel)
            }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
