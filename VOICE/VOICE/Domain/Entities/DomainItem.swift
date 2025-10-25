//
//  DomainItem.swift
//  VOICE
//
//  Item entity (Domain layer) - renamed to avoid conflict with SwiftData Item
//

import Foundation

struct DomainItem: Codable, Equatable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let createdAt: Date
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ItemsList: Codable {
    let items: [DomainItem]
    let nextCursor: String?
    
    enum CodingKeys: String, CodingKey {
        case items
        case nextCursor = "next_cursor"
    }
}

