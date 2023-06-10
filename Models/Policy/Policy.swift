//
//  Policy.swift
//  Board
//
//  Created by 정호길 on 2023/02/28.
//

import Foundation

enum Policy: String, CaseIterable, Identifiable, Hashable {
    var id: String { rawValue }
    
    case sexual = "Sexual content"
    case violent = "Violent content"
    case hateSpeech = "Hate speech content"
    case advertising = "Advertising or spam"
    case falseInfo = "False information"
}
