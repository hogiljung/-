//
//  SupportView.swift
//  Board
//
//  Created by 정호길 on 2023/03/11.
//

import SwiftUI

struct SupportView: View {
    var body: some View {
        ZStack {
            ScrollView {
                Text("SupportMessage")
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}
