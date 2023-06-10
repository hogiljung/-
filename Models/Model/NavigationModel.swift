//
//  NavigationModel.swift
//  Board
//
//  Created by 정호길 on 2023/03/21.
//

import SwiftUI
import Combine

@MainActor
final class NavigationModel: ObservableObject {
    @Published var path: [Post.ID]//NavigationPath() { didSet { debugPrint("path count: \(path.count)") } }
    
    static let shared = NavigationModel()
    
    private init(path: [Post.ID] = []) {
        self.path = path
    }
    
    var objectWillChangeSequence: AsyncPublisher<Publishers.Buffer<ObservableObjectPublisher>> {
        objectWillChange
            .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
            .values
    }
}
