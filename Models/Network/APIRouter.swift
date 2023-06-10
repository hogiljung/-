//
//  Router.swift
//  Board
//
//  Created by 정호길 on 2023/02/19.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    case signup([String: String]),
         signin([String: String]),
         delete([String: String]),
         titleview,
         contentview([String: String]),
         post([String: String]),
         deleteAccount([String: String]),
         modify([String: String]),
         comment([String: String]),
         commentsview([String: String]),
         deletecomment([String: String])
    
    public static var baseURL: URL {
        return URL(string: "https://semo.monster")!
    }
    
    var method: HTTPMethod {
        switch self {
        case .titleview: return .get
        case .signup, .signin, .deleteAccount, .contentview, .post, .delete, .modify, .comment, .commentsview, .deletecomment:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .titleview: return "/titleview/"
        case .signup: return "/signup/"
        case .signin: return "/signin/"
        case .deleteAccount: return "/withdraw/"
        case .contentview: return "/contentview/"
        case .post: return "/post/"
        case .delete: return "/delete/"
        case .modify: return "/modify/"
        case .comment: return "/writecommentview/"
        case .commentsview: return "/commentview/"
        case .deletecomment: return "/deletecommentview/"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = APIRouter.baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        
        switch self {
        case .titleview: break
        case let .signup(parameters),
            let .signin(parameters),
            let .deleteAccount(parameters),
            let .contentview(parameters),
            let .post(parameters),
            let .delete(parameters),
            let .modify(parameters),
            let .comment(parameters),
            let .commentsview(parameters),
            let .deletecomment(parameters):
            
            request = try URLEncodedFormParameterEncoder(destination: .httpBody).encode(parameters, into: request)
        }
        
        return request
    }
}
