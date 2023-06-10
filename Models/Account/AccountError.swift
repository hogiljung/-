//
//  AccountError.swift
//  Board
//
//  Created by 정호길 on 2023/03/10.
//

import Foundation

enum AccountError: Error {
    case unAuthorized
    
    case emptyInput
    case invalidPassword
    case unexpectedError
    
    case failedSignIn
    case duplicatedUsername
    case notAgree
}

extension AccountError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unAuthorized:
            return ""
        case .emptyInput:
            return NSLocalizedString("Please write your ID or PW.", comment: "")
        case .invalidPassword:
            return NSLocalizedString("Password must be between 8 and 15 characters.", comment: "")
        case .failedSignIn:
            return NSLocalizedString("Please check your ID or PW.", comment: "")
        case .duplicatedUsername:
            return NSLocalizedString("This ID already exists.", comment: "")
        case .unexpectedError:
            return NSLocalizedString("Please try again later.", comment: "")
        case .notAgree:
            return NSLocalizedString("To sign up, you must agree to the Terms and Conditions and Personal Information Processing Policy.", comment: "")
        }
    }
}
