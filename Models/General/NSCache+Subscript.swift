//
//  NSCache+Subscript.swift
//  Board
//
//  Created by 정호길 on 2023/02/25.
//

import Foundation

extension NSCache where KeyType == NSString, ObjectType == CacheEntryObject {
    subscript(_ postId: Int) -> CacheEntry? {
        get {
            let key = String(postId) as NSString
            let value = object(forKey: key)
            return value?.entry
        }
        set {
            let key = String(postId) as NSString
            if let entry = newValue {
                let value = CacheEntryObject(entry: entry)
                setObject(value, forKey: key)
            } else {
                removeObject(forKey: key)
            }
        }
    }
}
