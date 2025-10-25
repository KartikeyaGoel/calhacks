//
//  ItemsListUseCaseTests.swift
//  VOICE Tests
//
//  Unit tests for ItemsListUseCase
//

import XCTest

final class ItemsListUseCaseTests: XCTestCase {
    var useCase: DefaultItemsListUseCase!
    var mockItemsRepository: MockItemsRepository!
    var mockLogger: MockLogger!
    
    override func setUp() {
        super.setUp()
        mockItemsRepository = MockItemsRepository()
        mockLogger = MockLogger()
        
        useCase = DefaultItemsListUseCase(
            itemsRepository: mockItemsRepository,
            logger: mockLogger
        )
    }
    
    override func tearDown() {
        useCase = nil
        mockItemsRepository = nil
        mockLogger = nil
        super.tearDown()
    }
    
    func testListItemsSuccess() async throws {
        // Given
        let expectedItems = [
            DomainItem(id: "1", title: "Item 1", description: nil, createdAt: Date(), updatedAt: nil),
            DomainItem(id: "2", title: "Item 2", description: "Desc", createdAt: Date(), updatedAt: nil)
        ]
        
        mockItemsRepository.listHandler = { cursor, limit in
            XCTAssertNil(cursor)
            XCTAssertEqual(limit, 20)
            return (items: expectedItems, nextCursor: "next_cursor")
        }
        
        let input = ItemsListUseCase.Input(cursor: nil, limit: 20)
        
        // When
        let output = try await useCase.execute(input: input)
        
        // Then
        XCTAssertEqual(output.items.count, 2)
        XCTAssertEqual(output.items[0].id, "1")
        XCTAssertEqual(output.items[1].id, "2")
        XCTAssertEqual(output.nextCursor, "next_cursor")
        XCTAssertEqual(mockItemsRepository.listCallCount, 1)
    }
    
    func testListItemsWithCursor() async throws {
        // Given
        mockItemsRepository.listHandler = { cursor, limit in
            XCTAssertEqual(cursor, "existing_cursor")
            XCTAssertEqual(limit, 50)
            return (items: [], nextCursor: nil)
        }
        
        let input = ItemsListUseCase.Input(cursor: "existing_cursor", limit: 50)
        
        // When
        let output = try await useCase.execute(input: input)
        
        // Then
        XCTAssertTrue(output.items.isEmpty)
        XCTAssertNil(output.nextCursor)
    }
    
    func testListItemsWithRepositoryError() async {
        // Given
        mockItemsRepository.listHandler = { _, _ in
            throw HTTPError.serverError(500, "Internal error")
        }
        
        let input = ItemsListUseCase.Input(cursor: nil, limit: 20)
        
        // When/Then
        do {
            _ = try await useCase.execute(input: input)
            XCTFail("Should throw error")
        } catch {
            // Expected to throw
        }
        
        XCTAssertEqual(mockItemsRepository.listCallCount, 1)
    }
}

