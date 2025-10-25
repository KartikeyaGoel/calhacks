//
//  ItemsDeleteUseCase.swift
//  VOICE
//
//  Use case for deleting an item
//

import Foundation

protocol ItemsDeleteUseCase {
    func execute(input: Input) async throws
    
    struct Input {
        let id: String
    }
}

final class DefaultItemsDeleteUseCase: ItemsDeleteUseCase {
    private let itemsRepository: ItemsRepository
    private let logger: Logger
    
    init(
        itemsRepository: ItemsRepository,
        logger: Logger
    ) {
        self.itemsRepository = itemsRepository
        self.logger = logger
    }
    
    func execute(input: Input) async throws {
        logger.info("Deleting item: \(input.id)", module: "Items")
        
        // Validate input
        guard !input.id.isEmpty else {
            throw AppError.validation("Item ID is required")
        }
        
        do {
            try await itemsRepository.delete(id: input.id)
            logger.info("Successfully deleted item: \(input.id)", module: "Items")
        } catch {
            logger.error("Failed to delete item: \(error.localizedDescription)", module: "Items")
            throw AppError.from(error)
        }
    }
}


