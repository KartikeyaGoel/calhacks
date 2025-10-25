//
//  AuthRepositoryImpl.swift
//  VOICE
//
//  Authentication repository implementation
//

import Foundation

final class AuthRepositoryImpl: AuthRepository {
    private let httpClient: HTTPClient
    private let logger: Logger
    
    init(httpClient: HTTPClient, logger: Logger) {
        self.httpClient = httpClient
        self.logger = logger
    }
    
    func login(email: String, password: String) async throws -> AuthSession {
        logger.info("Attempting login for email: \(email)", module: "AuthRepository")
        
        let request = HTTPRequest(
            path: "/auth/login",
            method: .post,
            body: LoginRequest(email: email, password: password)
        )
        
        do {
            let response: LoginResponse = try await httpClient.send(request)
            logger.info("Login successful", module: "AuthRepository")
            
            return AuthSession(
                user: response.user,
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )
        } catch {
            logger.error("Login failed: \(error.localizedDescription)", module: "AuthRepository")
            throw error
        }
    }
    
    func refresh(refreshToken: String) async throws -> String {
        logger.info("Refreshing access token", module: "AuthRepository")
        
        let request = HTTPRequest(
            path: "/auth/refresh",
            method: .post,
            body: RefreshRequest(refreshToken: refreshToken)
        )
        
        do {
            let response: RefreshTokenResponse = try await httpClient.send(request)
            logger.info("Token refresh successful", module: "AuthRepository")
            return response.accessToken
        } catch {
            logger.error("Token refresh failed: \(error.localizedDescription)", module: "AuthRepository")
            throw error
        }
    }
    
    func logout() async throws {
        logger.info("Logging out user", module: "AuthRepository")
        
        let request = HTTPRequest(
            path: "/auth/logout",
            method: .post
        )
        
        do {
            try await httpClient.sendVoid(request)
            logger.info("Logout successful", module: "AuthRepository")
        } catch {
            logger.error("Logout failed: \(error.localizedDescription)", module: "AuthRepository")
            throw error
        }
    }
}

// MARK: - Request/Response Models

private struct LoginRequest: Encodable {
    let email: String
    let password: String
}

private struct LoginResponse: Decodable {
    let user: User
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

private struct RefreshRequest: Encodable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}


