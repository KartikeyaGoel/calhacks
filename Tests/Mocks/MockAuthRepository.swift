//
//  MockAuthRepository.swift
//  VOICE Tests
//
//  Mock auth repository for testing
//

import Foundation

final class MockAuthRepository: AuthRepository {
    var loginHandler: ((String, String) async throws -> AuthSession)?
    var refreshHandler: ((String) async throws -> String)?
    var logoutHandler: (() async throws -> Void)?
    
    var loginCallCount = 0
    var refreshCallCount = 0
    var logoutCallCount = 0
    
    func login(email: String, password: String) async throws -> AuthSession {
        loginCallCount += 1
        
        guard let handler = loginHandler else {
            throw HTTPError.serverError(500, "No handler configured")
        }
        
        return try await handler(email, password)
    }
    
    func refresh(refreshToken: String) async throws -> String {
        refreshCallCount += 1
        
        guard let handler = refreshHandler else {
            throw HTTPError.serverError(500, "No handler configured")
        }
        
        return try await handler(refreshToken)
    }
    
    func logout() async throws {
        logoutCallCount += 1
        
        if let handler = logoutHandler {
            try await handler()
        }
    }
    
    func reset() {
        loginHandler = nil
        refreshHandler = nil
        logoutHandler = nil
        loginCallCount = 0
        refreshCallCount = 0
        logoutCallCount = 0
    }
}

