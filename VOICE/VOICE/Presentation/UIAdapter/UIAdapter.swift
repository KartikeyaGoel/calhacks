//
//  UIAdapter.swift
//  VOICE
//
//  Adapter that translates UI actions to domain use cases
//

import Foundation

final class UIAdapter: UIActionDispatcher {
    private let registry: ComponentRegistry
    private let authLoginUseCase: AuthLoginUseCase
    private let authLogoutUseCase: AuthLogoutUseCase
    private let itemsListUseCase: ItemsListUseCase
    private let itemsCreateUseCase: ItemsCreateUseCase
    private let itemsUpdateUseCase: ItemsUpdateUseCase
    private let itemsDeleteUseCase: ItemsDeleteUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let logger: Logger
    
    init(
        registry: ComponentRegistry,
        authLoginUseCase: AuthLoginUseCase,
        authLogoutUseCase: AuthLogoutUseCase,
        itemsListUseCase: ItemsListUseCase,
        itemsCreateUseCase: ItemsCreateUseCase,
        itemsUpdateUseCase: ItemsUpdateUseCase,
        itemsDeleteUseCase: ItemsDeleteUseCase,
        getCurrentUserUseCase: GetCurrentUserUseCase,
        logger: Logger
    ) {
        self.registry = registry
        self.authLoginUseCase = authLoginUseCase
        self.authLogoutUseCase = authLogoutUseCase
        self.itemsListUseCase = itemsListUseCase
        self.itemsCreateUseCase = itemsCreateUseCase
        self.itemsUpdateUseCase = itemsUpdateUseCase
        self.itemsDeleteUseCase = itemsDeleteUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.logger = logger
    }
    
    func dispatch(action: UIAction) async -> UIResult {
        logger.info("Dispatching action: \(action.id) from component: \(action.componentId)", module: "UIAdapter")
        
        // Look up use case from registry
        guard let actionMapping = registry.actions[action.id] else {
            logger.warning("Action not found in registry: \(action.id)", module: "UIAdapter")
            return .validationError("Action not found: \(action.id)")
        }
        
        // Route to appropriate use case
        do {
            let result = try await executeUseCase(actionMapping.useCase, payload: action.payload)
            logger.info("Action \(action.id) completed successfully", module: "UIAdapter")
            return result
        } catch let appError as AppError {
            logger.error("Action \(action.id) failed: \(appError.localizedDescription)", module: "UIAdapter")
            return mapAppError(appError)
        } catch {
            logger.error("Action \(action.id) failed with unexpected error: \(error.localizedDescription)", module: "UIAdapter")
            return .serverError(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    
    private func executeUseCase(_ useCaseName: String, payload: [String: AnyCodable]) async throws -> UIResult {
        switch useCaseName {
        case "AuthLoginUseCase":
            return try await executeAuthLogin(payload: payload)
            
        case "AuthLogoutUseCase":
            return try await executeAuthLogout()
            
        case "ItemsListUseCase":
            return try await executeItemsList(payload: payload)
            
        case "ItemsCreateUseCase":
            return try await executeItemsCreate(payload: payload)
            
        case "ItemsUpdateUseCase":
            return try await executeItemsUpdate(payload: payload)
            
        case "ItemsDeleteUseCase":
            return try await executeItemsDelete(payload: payload)
            
        case "GetCurrentUserUseCase":
            return try await executeGetCurrentUser()
            
        default:
            throw AppError.validation("Unknown use case: \(useCaseName)")
        }
    }
    
    // MARK: - Use Case Executors
    
    private func executeAuthLogin(payload: [String: AnyCodable]) async throws -> UIResult {
        guard let email = payload["email"]?.value as? String,
              let password = payload["password"]?.value as? String else {
            throw AppError.validation("Email and password are required")
        }
        
        let input = AuthLoginUseCase.Input(email: email, password: password)
        let output = try await authLoginUseCase.execute(input: input)
        
        return .success([
            "user": AnyCodable(encodeUser(output.user)),
            "access_token": AnyCodable(output.accessToken)
        ])
    }
    
    private func executeAuthLogout() async throws -> UIResult {
        try await authLogoutUseCase.execute()
        return .success(["status": AnyCodable("logged_out")])
    }
    
    private func executeItemsList(payload: [String: AnyCodable]) async throws -> UIResult {
        let cursor = payload["cursor"]?.value as? String
        let limit = payload["limit"]?.value as? Int ?? 20
        
        let input = ItemsListUseCase.Input(cursor: cursor, limit: limit)
        let output = try await itemsListUseCase.execute(input: input)
        
        return .success([
            "items": AnyCodable(output.items.map(encodeItem)),
            "next_cursor": AnyCodable(output.nextCursor ?? "")
        ])
    }
    
    private func executeItemsCreate(payload: [String: AnyCodable]) async throws -> UIResult {
        guard let title = payload["title"]?.value as? String else {
            throw AppError.validation("Title is required")
        }
        
        let description = payload["description"]?.value as? String
        
        let input = ItemsCreateUseCase.Input(title: title, description: description)
        let output = try await itemsCreateUseCase.execute(input: input)
        
        return .success(["item": AnyCodable(encodeItem(output.item))])
    }
    
    private func executeItemsUpdate(payload: [String: AnyCodable]) async throws -> UIResult {
        guard let id = payload["id"]?.value as? String,
              let title = payload["title"]?.value as? String else {
            throw AppError.validation("ID and title are required")
        }
        
        let description = payload["description"]?.value as? String
        
        let input = ItemsUpdateUseCase.Input(id: id, title: title, description: description)
        let output = try await itemsUpdateUseCase.execute(input: input)
        
        return .success(["item": AnyCodable(encodeItem(output.item))])
    }
    
    private func executeItemsDelete(payload: [String: AnyCodable]) async throws -> UIResult {
        guard let id = payload["id"]?.value as? String else {
            throw AppError.validation("ID is required")
        }
        
        let input = ItemsDeleteUseCase.Input(id: id)
        try await itemsDeleteUseCase.execute(input: input)
        
        return .success(["status": AnyCodable("deleted"), "id": AnyCodable(id)])
    }
    
    private func executeGetCurrentUser() async throws -> UIResult {
        let output = try await getCurrentUserUseCase.execute()
        return .success(["user": AnyCodable(encodeUser(output.user))])
    }
    
    // MARK: - Helpers
    
    private func mapAppError(_ error: AppError) -> UIResult {
        switch error {
        case .validation(let message):
            return .validationError(message)
        case .unauthorized:
            return .unauthorized
        case .notFound:
            return .notFound
        case .network(let message):
            return .transportError(message)
        case .server(let message):
            return .serverError(message)
        default:
            return .serverError(error.localizedDescription)
        }
    }
    
    private func encodeUser(_ user: User) -> [String: Any] {
        return [
            "id": user.id,
            "email": user.email,
            "name": user.name,
            "avatar_url": user.avatarURL?.absoluteString ?? ""
        ]
    }
    
    private func encodeItem(_ item: DomainItem) -> [String: Any] {
        var dict: [String: Any] = [
            "id": item.id,
            "title": item.title,
            "created_at": ISO8601DateFormatter().string(from: item.createdAt)
        ]
        
        if let description = item.description {
            dict["description"] = description
        }
        
        if let updatedAt = item.updatedAt {
            dict["updated_at"] = ISO8601DateFormatter().string(from: updatedAt)
        }
        
        return dict
    }
}

