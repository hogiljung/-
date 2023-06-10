//
//  SettingsView.swift
//  Board
//
//  Created by 정호길 on 2023/02/27.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var accountModel: AccountModel
    @Environment(\.dismiss) private var dismiss

    @State private var hasError = false
    @State private var isSignOutSheetPresented = false
    @State private var isDeleteAccountSheetPresented = false

    private enum Setting: Hashable {
        case licences
        case privacy
        case support
    }
    
    var body: some View {
        ZStack {
            Form {
                Section {
                    NavigationLink {
                        LicencesView()
                    } label: {
                        Text("OpenSource License")
                    }
                    
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Text("Terms of Use and Privacy Policy")
                    }
                    
                    NavigationLink {
                        SupportView()
                    } label: {
                        Text("Support")
                    }
                }
                
                Section {
                    LabeledContent("Sign out") {
                        Button("Sign Out", role: .destructive) {
                            isSignOutSheetPresented = true
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .labelsHidden()
                }
                
                Section {
                    LabeledContent("Delete Account") {
                        Button("Delete Account", role: .destructive) {
                            isDeleteAccountSheetPresented.toggle()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .labelsHidden()
                }
            }
        }
        .navigationDestination(for: Setting.self) { setting in
            switch setting {
            case .licences:
                LicencesView()
            case .privacy:
                PrivacyPolicyView()
            case .support:
                SupportView()
            }
        }
        .alert(Text("Are you sure you want to sign out?"), isPresented: $isSignOutSheetPresented) {
            Button("Sign Out", role: .destructive) {
                accountModel.signOut()
                dismiss()
            }
        }
        .alert(Text("Are you sure you want to delete account?"), isPresented: $isDeleteAccountSheetPresented) {
            Button("Delete Account", role: .destructive) {
                Task {
                    do {
                        if let user = accountModel.currentUser {
                            try await accountModel.delete(userId: user.id)
                            dismiss()
                        }
                    } catch {
                        hasError = true
                    }
                }
            }
        }
    }
    
    private var signOutAlert: Alert {
        Alert(title: Text("Are you sure you want to sign out?"), primaryButton: .destructive(Text("Sign Out")) {
            accountModel.signOut()
            dismiss()
        }, secondaryButton: .cancel())
    }
}

struct SettingsView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var accoutModel = AccountModel()
        var body: some View {
            NavigationStack {
                
                SettingsView()
                    .environmentObject(accoutModel)
            }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
