//
//  PostReportView.swift
//  Board
//
//  Created by 정호길 on 2023/02/28.
//

import SwiftUI

struct PostReportView: View {
    @Binding var selection: Policy?
    @Binding var block: Bool
    
    var body: some View {
        NavigationStack {
            List {
                Text("Why are you reporting this post?")
                    .font(.headline).listRowSeparator(.hidden, edges: .top)

                ForEach(Policy.allCases) { policy in
                    NavigationLink(value: policy) {
                        Text(LocalizedStringKey(policy.rawValue))
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Policy.self) { policy in
                ReportDoneView(block: $block)
                    .task {
                        selection = policy
                    }
            }
        }
    }
}

struct PolicyView_Previews: PreviewProvider {
    struct Preview: View {
        @State private var selection: Policy?

        var body: some View {
            PostReportView(selection: $selection, block: .constant(false))
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
