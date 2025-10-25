//
//  GetCurrentUserUseCase.swift
//  VOICE
//
//  Use case for fetching current user profile
//

import Foundation

protocol GetCurrentUserUseCase {
    func execute() async throws -> Output
    
    struct Output {
        let user: User
    }
}

final class DefaultGetCurrentUserUseCase: GetCurrentUserUseCase {
    private let profileRepository: ProfileRepository
    private let logger: Logger
    
    init(
        profileRepository: ProfileRepository,
        logger: Logger
    ) {
        self.profileRepository = profileRepository
        self.logger = logger
    }
    
    func execute() async throws -> Output {
        logger.info("Fetching current user profile", module: "Profile")
        
        do {
            let user = try await profileRepository.getCurrentUser()
            logger.info("Successfully fetched user profile: \(user.id)", module: "Profile")
            return Output(user: user)
        } catch {
            logger.error("Failed to fetch user profile: \(error.localizedDescription)", module: "Profile")
            throw AppError.from(error)
        }
    }
}

