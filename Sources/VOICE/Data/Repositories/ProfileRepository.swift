//
//  ProfileRepository.swift
//  VOICE
//
//  Profile repository protocol (Data layer)
//

import Foundation

protocol ProfileRepository {
    func getCurrentUser() async throws -> User
    func updateProfile(name: String, avatarURL: URL?) async throws -> User
}


