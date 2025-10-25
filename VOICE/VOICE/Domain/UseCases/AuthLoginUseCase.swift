//
//  AuthLoginUseCase.swift
//  VOICE
//
//  Use case for user authentication
//

import Foundation

protocol AuthLoginUseCase {
    func execute(input: Input) async throws -> Output
    
    struct Input {
        let email: String
        let password: String
    }
    
    struct Output {
        let user: User
        let accessToken: String
        let refreshToken: String
    }
}

final class DefaultAuthLoginUseCase: AuthLoginUseCase {
    private let authRepository: AuthRepository
    private let keychainService: KeychainService
    private let logger: Logger
    
    init(
        authRepository: AuthRepository,
        keychainService: KeychainService,
        logger: Logger
    ) {
        self.authRepository = authRepository
        self.keychainService = keychainService
        self.logger = logger
    }
    
    func execute(input: Input) async throws -> Output {
        logger.info("Attempting login for email: \(input.email)", module: "Auth")
        
        // Validate input
        guard !input.email.isEmpty else {
            throw AppError.validation("Email is required")
        }
        
        guard !input.password.isEmpty else {
            throw AppError.validation("Password is required")
        }
        
        // Call repository
        do {
            let session = try await authRepository.login(email: input.email, password: input.password)
            
            // Store tokens in keychain
            try keychainService.save(session.accessToken, for: "access_token")
            try keychainService.save(session.refreshToken, for: "refresh_token")
            
            logger.info("Login successful for user: \(session.user.id)", module: "Auth")
            
            return Output(
                user: session.user,
                accessToken: session.accessToken,
                refreshToken: session.refreshToken
            )
        } catch {
            logger.error("Login failed: \(error.localizedDescription)", module: "Auth")
            throw AppError.from(error)
        }
    }
}

