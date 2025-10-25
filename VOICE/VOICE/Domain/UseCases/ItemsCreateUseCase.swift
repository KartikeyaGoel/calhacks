//
//  ItemsCreateUseCase.swift
//  VOICE
//
//  Use case for creating a new item
//

import Foundation

protocol ItemsCreateUseCase {
    func execute(input: Input) async throws -> Output
    
    struct Input {
        let title: String
        let description: String?
    }
    
    struct Output {
        let item: DomainItem
    }
}

final class DefaultItemsCreateUseCase: ItemsCreateUseCase {
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
        logger.info("Creating new item: \(input.title)", module: "Items")
        
        // Validate input
        guard !input.title.isEmpty else {
            throw AppError.validation("Title is required")
        }
        
        do {
            let item = try await itemsRepository.create(
                title: input.title,
                description: input.description
            )
            
            logger.info("Successfully created item with id: \(item.id)", module: "Items")
            
            return Output(item: item)
        } catch {
            logger.error("Failed to create item: \(error.localizedDescription)", module: "Items")
            throw AppError.from(error)
        }
    }
}

