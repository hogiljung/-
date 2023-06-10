//
//  APIError.swift
//  Board
//
//  Created by 정호길 on 2023/02/19.
//

import Foundation

enum APIError: Error {
    case failedSignIn
    
    case invalidSignForm

    case duplicatedUsername
    
    case unAuthorizedOptions
    
    case networkError
    
    case unexpectedError(error: Error)
}
