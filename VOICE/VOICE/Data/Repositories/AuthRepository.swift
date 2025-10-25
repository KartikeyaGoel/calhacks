//
//  AuthRepository.swift
//  VOICE
//
//  Authentication repository protocol (Data layer)
//

import Foundation

protocol AuthRepository {
    func login(email: String, password: String) async throws -> AuthSession
    func refresh(refreshToken: String) async throws -> String
    func logout() async throws
}

