//
//  ProfileRepositoryImpl.swift
//  VOICE
//
//  Profile repository implementation
//

import Foundation

final class ProfileRepositoryImpl: ProfileRepository {
    private let httpClient: HTTPClient
    private let logger: Logger
    
    init(httpClient: HTTPClient, logger: Logger) {
        self.httpClient = httpClient
        self.logger = logger
    }
    
    func getCurrentUser() async throws -> User {
        logger.info("Fetching current user", module: "ProfileRepository")
        
        let request = HTTPRequest(
            path: "/users/me",
            method: .get
        )
        
        do {
            let user: User = try await httpClient.send(request)
            logger.info("Successfully fetched user: \(user.id)", module: "ProfileRepository")
            return user
        } catch {
            logger.error("Failed to fetch user: \(error.localizedDescription)", module: "ProfileRepository")
            throw error
        }
    }
    
    func updateProfile(name: String, avatarURL: URL?) async throws -> User {
        logger.info("Updating user profile", module: "ProfileRepository")
        
        let request = HTTPRequest(
            path: "/users/me",
            method: .put,
            body: UpdateProfileRequest(name: name, avatarURL: avatarURL)
        )
        
        do {
            let user: User = try await httpClient.send(request)
            logger.info("Successfully updated user profile", module: "ProfileRepository")
            return user
        } catch {
            logger.error("Failed to update profile: \(error.localizedDescription)", module: "ProfileRepository")
            throw error
        }
    }
}

// MARK: - Request Models

private struct UpdateProfileRequest: Encodable {
    let name: String
    let avatarURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case name
        case avatarURL = "avatar_url"
    }
}


