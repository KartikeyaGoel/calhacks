//
//  ItemsGetUseCase.swift
//  VOICE
//
//  Use case for fetching a single item by ID
//

import Foundation

protocol ItemsGetUseCase {
    func execute(input: Input) async throws -> Output
    
    struct Input {
        let id: String
    }
    
    struct Output {
        let item: DomainItem
    }
}

final class DefaultItemsGetUseCase: ItemsGetUseCase {
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
        logger.info("Fetching item: \(input.id)", module: "Items")
        
        // Validate input
        guard !input.id.isEmpty else {
            throw AppError.validation("Item ID is required")
        }
        
        do {
            // Note: If backend supports GET /items/:id, add to repository protocol
            // For now, fetch list and filter (not optimal but works)
            let (items, _) = try await itemsRepository.list(cursor: nil, limit: 100)
            
            guard let item = items.first(where: { $0.id == input.id }) else {
                throw AppError.notFound
            }
            
            logger.info("Successfully fetched item: \(item.id)", module: "Items")
            
            return Output(item: item)
        } catch {
            logger.error("Failed to fetch item: \(error.localizedDescription)", module: "Items")
            throw AppError.from(error)
        }
    }
}

