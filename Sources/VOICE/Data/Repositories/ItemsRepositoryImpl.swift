//
//  ItemsRepositoryImpl.swift
//  VOICE
//
//  Items repository implementation
//

import Foundation

final class ItemsRepositoryImpl: ItemsRepository {
    private let httpClient: HTTPClient
    private let logger: Logger
    
    init(httpClient: HTTPClient, logger: Logger) {
        self.httpClient = httpClient
        self.logger = logger
    }
    
    func list(cursor: String?, limit: Int) async throws -> (items: [DomainItem], nextCursor: String?) {
        logger.info("Fetching items list with limit: \(limit)", module: "ItemsRepository")
        
        var query: [String: String] = ["limit": String(limit)]
        if let cursor = cursor {
            query["cursor"] = cursor
        }
        
        let request = HTTPRequest(
            path: "/items",
            method: .get,
            query: query
        )
        
        do {
            let response: ItemsList = try await httpClient.send(request)
            logger.info("Successfully fetched \(response.items.count) items", module: "ItemsRepository")
            return (items: response.items, nextCursor: response.nextCursor)
        } catch {
            logger.error("Failed to fetch items: \(error.localizedDescription)", module: "ItemsRepository")
            throw error
        }
    }
    
    func create(title: String, description: String?) async throws -> DomainItem {
        logger.info("Creating item: \(title)", module: "ItemsRepository")
        
        let request = HTTPRequest(
            path: "/items",
            method: .post,
            body: CreateItemRequest(title: title, description: description)
        )
        
        do {
            let item: DomainItem = try await httpClient.send(request)
            logger.info("Successfully created item with id: \(item.id)", module: "ItemsRepository")
            return item
        } catch {
            logger.error("Failed to create item: \(error.localizedDescription)", module: "ItemsRepository")
            throw error
        }
    }
    
    func update(id: String, title: String, description: String?) async throws -> DomainItem {
        logger.info("Updating item: \(id)", module: "ItemsRepository")
        
        let request = HTTPRequest(
            path: "/items/\(id)",
            method: .put,
            body: UpdateItemRequest(title: title, description: description)
        )
        
        do {
            let item: DomainItem = try await httpClient.send(request)
            logger.info("Successfully updated item: \(item.id)", module: "ItemsRepository")
            return item
        } catch {
            logger.error("Failed to update item: \(error.localizedDescription)", module: "ItemsRepository")
            throw error
        }
    }
    
    func delete(id: String) async throws {
        logger.info("Deleting item: \(id)", module: "ItemsRepository")
        
        let request = HTTPRequest(
            path: "/items/\(id)",
            method: .delete
        )
        
        do {
            try await httpClient.sendVoid(request)
            logger.info("Successfully deleted item: \(id)", module: "ItemsRepository")
        } catch {
            logger.error("Failed to delete item: \(error.localizedDescription)", module: "ItemsRepository")
            throw error
        }
    }
}

// MARK: - Request Models

private struct CreateItemRequest: Encodable {
    let title: String
    let description: String?
}

private struct UpdateItemRequest: Encodable {
    let title: String
    let description: String?
}


