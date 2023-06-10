//
//  PrivacyPolicyView.swift
//  Board
//
//  Created by 정호길 on 2023/02/27.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            ScrollView {
                Text("PrivacyPolicy")
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
