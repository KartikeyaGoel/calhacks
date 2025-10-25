//
//  MockItemsRepository.swift
//  VOICE Tests
//
//  Mock items repository for testing
//

import Foundation
@testable import VOICE

final class MockItemsRepository: ItemsRepository {
    var listHandler: ((String?, Int) async throws -> (items: [DomainItem], nextCursor: String?))?
    var createHandler: ((String, String?) async throws -> DomainItem)?
    var updateHandler: ((String, String, String?) async throws -> DomainItem)?
    var deleteHandler: ((String) async throws -> Void)?
    
    var listCallCount = 0
    var createCallCount = 0
    var updateCallCount = 0
    var deleteCallCount = 0
    
    func list(cursor: String?, limit: Int) async throws -> (items: [DomainItem], nextCursor: String?) {
        listCallCount += 1
        
        guard let handler = listHandler else {
            throw HTTPError.serverError(500, "No handler configured")
        }
        
        return try await handler(cursor, limit)
    }
    
    func create(title: String, description: String?) async throws -> DomainItem {
        createCallCount += 1
        
        guard let handler = createHandler else {
            throw HTTPError.serverError(500, "No handler configured")
        }
        
        return try await handler(title, description)
    }
    
    func update(id: String, title: String, description: String?) async throws -> DomainItem {
        updateCallCount += 1
        
        guard let handler = updateHandler else {
            throw HTTPError.serverError(500, "No handler configured")
        }
        
        return try await handler(id, title, description)
    }
    
    func delete(id: String) async throws {
        deleteCallCount += 1
        
        if let handler = deleteHandler {
            try await handler(id)
        }
    }
    
    func reset() {
        listHandler = nil
        createHandler = nil
        updateHandler = nil
        deleteHandler = nil
        listCallCount = 0
        createCallCount = 0
        updateCallCount = 0
        deleteCallCount = 0
    }
}

