//
//  AuthLogoutUseCase.swift
//  VOICE
//
//  Use case for user logout
//

import Foundation

protocol AuthLogoutUseCase {
    func execute() async throws
}

final class DefaultAuthLogoutUseCase: AuthLogoutUseCase {
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
    
    func execute() async throws {
        logger.info("Executing logout", module: "Auth")
        
        do {
            // Call backend to invalidate tokens
            try await authRepository.logout()
            
            // Clear local tokens
            try keychainService.delete("access_token")
            try keychainService.delete("refresh_token")
            
            logger.info("Logout successful", module: "Auth")
        } catch {
            // Clear tokens even if backend call fails
            try? keychainService.delete("access_token")
            try? keychainService.delete("refresh_token")
            
            logger.error("Logout failed: \(error.localizedDescription)", module: "Auth")
            throw AppError.from(error)
        }
    }
}


