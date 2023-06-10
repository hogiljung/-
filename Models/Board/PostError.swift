//
//  PostError.swift
//  Board
//
//  Created by 정호길 on 2023/01/18.
//

import Foundation

enum PostError: Error {
    case missingData
}

extension PostError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingData:
            return NSLocalizedString("Discarding a post.", comment: "")
        }
    }
}
