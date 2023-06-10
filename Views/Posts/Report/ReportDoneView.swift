//
//  ReportDoneView.swift
//  Board
//
//  Created by 정호길 on 2023/03/03.
//

import SwiftUI

struct ReportDoneView: View {
    @Binding var block: Bool
    
    var body: some View {
        ZStack {
            VStack {
                Text("Thanks for letting us know")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                Text("After checking the report, we will delete the content if it has violated the rules of use.")
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                    .multilineTextAlignment(.center)
                
                Text("If you don't want to see other posts and comments from this user, please press the button below.")
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                    .multilineTextAlignment(.center)
                
                if !block {
                    Button(role: .destructive) {
                        block = true
                    } label: {
                        Label("Block User", systemImage: "person.crop.circle.badge.minus")
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        block = false
                    } label: {
                        Label("Unblock User", systemImage: "person.crop.circle.badge.checkmark")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

struct ReportDoneView_Previews: PreviewProvider {
    struct Preview: View {
        @State private var block: Bool = false

        var body: some View {
            ReportDoneView(block: $block)
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
