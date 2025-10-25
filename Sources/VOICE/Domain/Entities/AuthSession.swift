//
//  AuthSession.swift
//  VOICE
//
//  Authentication session entity
//

import Foundation

struct AuthSession: Codable, Equatable {
    let user: User?
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date?
    
    init(user: User? = nil, accessToken: String, refreshToken: String, expiresAt: Date? = nil) {
        self.user = user
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }
    
    enum CodingKeys: String, CodingKey {
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
    }
}

struct RefreshTokenResponse: Codable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}


