//
//  ItemsListUseCase.swift
//  VOICE
//
//  Use case for listing items
//

import Foundation

protocol ItemsListUseCase {
    func execute(input: Input) async throws -> Output
    
    struct Input {
        let cursor: String?
        let limit: Int
        
        init(cursor: String? = nil, limit: Int = 20) {
            self.cursor = cursor
            self.limit = limit
        }
    }
    
    struct Output {
        let items: [DomainItem]
        let nextCursor: String?
    }
}

final class DefaultItemsListUseCase: ItemsListUseCase {
    private let itemsRepository: ItemsRepository
    private let logger: Logger
    
    init(
        itemsRepository: ItemsRepository,
        logger: Logger
    ) {
        self.itemsRepository = itemsRepository
        self.logger = logger
    }
    
    func execute(input: Input) async throws -> Output {
        logger.info("Fetching items list with limit: \(input.limit)", module: "Items")
        
        do {
            let (items, nextCursor) = try await itemsRepository.list(
                cursor: input.cursor,
                limit: input.limit
            )
            
            logger.info("Successfully fetched \(items.count) items", module: "Items")
            
            return Output(items: items, nextCursor: nextCursor)
        } catch {
            logger.error("Failed to fetch items: \(error.localizedDescription)", module: "Items")
            throw AppError.from(error)
        }
    }
}


