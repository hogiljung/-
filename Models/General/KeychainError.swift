//
//  KeychainError.swift
//  Board
//
//  Created by 정호길 on 2023/02/25.
//

import Foundation

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}
