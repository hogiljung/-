//
//  CacheEntryObject.swift
//  Board
//
//  Created by 정호길 on 2023/02/25.
//

import Foundation

/// A class to hold a CacheEntry.
final class CacheEntryObject {
    let entry: CacheEntry
    init(entry: CacheEntry) { self.entry = entry }
}

/// An enumeration of cache post cache entries.
enum CacheEntry {
    case inProgress(Task<PostContent?, Error>)
    case ready(PostContent?)
}
