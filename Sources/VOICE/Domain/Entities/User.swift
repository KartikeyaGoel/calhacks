//
//  User.swift
//  VOICE
//
//  User entity (Domain layer)
//

import Foundation

struct User: Codable, Equatable {
    let id: String
    let email: String
    let name: String
    let avatarURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case avatarURL = "avatar_url"
    }
}


