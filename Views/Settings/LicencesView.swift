//
//  LicencesView.swift
//  Board
//
//  Created by 정호길 on 2023/02/27.
//

import SwiftUI

struct LicencesView: View {
    var body: some View {
        ZStack {
            ScrollView {
                Text("Alamofire Licence")
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

struct LicencesView_Previews: PreviewProvider {
    static var previews: some View {
        LicencesView()
    }
}
