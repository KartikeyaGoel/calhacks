//
//  ItemsUpdateUseCase.swift
//  VOICE
//
//  Use case for updating an existing item
//

import Foundation

protocol ItemsUpdateUseCase {
    func execute(input: Input) async throws -> Output
    
    struct Input {
        let id: String
        let title: String
        let description: String?
    }
    
    struct Output {
        let item: DomainItem
    }
}

final class DefaultItemsUpdateUseCase: ItemsUpdateUseCase {
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
        logger.info("Updating item: \(input.id)", module: "Items")
        
        // Validate input
        guard !input.id.isEmpty else {
            throw AppError.validation("Item ID is required")
        }
        
        guard !input.title.isEmpty else {
            throw AppError.validation("Title is required")
        }
        
        do {
            let item = try await itemsRepository.update(
                id: input.id,
                title: input.title,
                description: input.description
            )
            
            logger.info("Successfully updated item: \(item.id)", module: "Items")
            
            return Output(item: item)
        } catch {
            logger.error("Failed to update item: \(error.localizedDescription)", module: "Items")
            throw AppError.from(error)
        }
    }
}

