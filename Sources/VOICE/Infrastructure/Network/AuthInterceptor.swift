//
//  AuthInterceptor.swift
//  VOICE
//
//  HTTP client wrapper that handles automatic token refresh on 401 errors
//

import Foundation

final class AuthInterceptor: HTTPClient {
    private let httpClient: HTTPClient
    private let keychainService: KeychainService
    private let logger: Logger
    private let config: Config
    
    private var isRefreshing = false
    private var refreshTask: Task<String, Error>?
    
    init(
        httpClient: HTTPClient,
        keychainService: KeychainService,
        logger: Logger,
        config: Config
    ) {
        self.httpClient = httpClient
        self.keychainService = keychainService
        self.logger = logger
        self.config = config
    }
    
    func send<T: Decodable>(_ request: HTTPRequest) async throws -> T {
        do {
            return try await httpClient.send(request)
        } catch HTTPError.unauthorized {
            // Attempt to refresh token and retry
            try await refreshTokenIfNeeded()
            return try await httpClient.send(request)
        }
    }
    
    func sendVoid(_ request: HTTPRequest) async throws {
        do {
            try await httpClient.sendVoid(request)
        } catch HTTPError.unauthorized {
            // Attempt to refresh token and retry
            try await refreshTokenIfNeeded()
            try await httpClient.sendVoid(request)
        }
    }
    
    // MARK: - Private Methods
    
    private func refreshTokenIfNeeded() async throws {
        // If already refreshing, wait for that task
        if let existingTask = refreshTask {
            _ = try await existingTask.value
            return
        }
        
        // Get refresh token
        guard let refreshToken = try? keychainService.get("refresh_token") else {
            logger.error("No refresh token available", module: "Auth")
            throw HTTPError.unauthorized
        }
        
        // Create refresh task
        let task = Task<String, Error> {
            logger.info("Refreshing access token", module: "Auth")
            
            let refreshRequest = HTTPRequest(
                path: "/auth/refresh",
                method: .post,
                body: ["refresh_token": refreshToken]
            )
            
            // Create a temporary client without auth interceptor to avoid recursion
            let tempClient = DefaultHTTPClient(
                config: config,
                keychainService: keychainService,
                logger: logger
            )
            
            let response: RefreshTokenResponse = try await tempClient.send(refreshRequest)
            
            // Save new access token
            try keychainService.save(response.accessToken, for: "access_token")
            
            logger.info("Access token refreshed successfully", module: "Auth")
            
            return response.accessToken
        }
        
        refreshTask = task
        
        do {
            _ = try await task.value
            refreshTask = nil
        } catch {
            refreshTask = nil
            logger.error("Token refresh failed: \(error.localizedDescription)", module: "Auth")
            
            // Clear tokens on refresh failure
            try? keychainService.delete("access_token")
            try? keychainService.delete("refresh_token")
            
            throw HTTPError.unauthorized
        }
    }
}


