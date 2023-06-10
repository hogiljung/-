//
//  APIResponse.swift
//  Board
//
//  Created by 정호길 on 2023/02/13.
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let code: String
    var result: T?
    
    struct CodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.code = try container.decode(String.self, forKey: CodingKeys(stringValue: "code")!)
        
        for key in container.allKeys {
            if key.stringValue != "code" {
                self.result = try container.decode(T.self, forKey: CodingKeys(stringValue: key.stringValue)!)
            }
        }
    }
    
    var isSucceeded: Bool {
        if code == "000" {
            return true
        } else {
            return false
        }
    }
}
