//
//  ItemsContractTests.swift
//  VOICE Tests
//
//  Contract tests for Items API responses
//

import XCTest
@testable import VOICE

final class ItemsContractTests: XCTestCase {
    func testDecodeItemsListResponse() throws {
        let json = loadFixture("items_list_response")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let response = try decoder.decode(ItemsList.self, from: json)
        
        XCTAssertEqual(response.items.count, 2)
        XCTAssertEqual(response.nextCursor, "cursor_abc123")
        
        // First item
        let item1 = response.items[0]
        XCTAssertEqual(item1.id, "item_1")
        XCTAssertEqual(item1.title, "First Item")
        XCTAssertEqual(item1.description, "This is the first test item")
        XCTAssertNotNil(item1.createdAt)
        XCTAssertNotNil(item1.updatedAt)
        
        // Second item
        let item2 = response.items[1]
        XCTAssertEqual(item2.id, "item_2")
        XCTAssertEqual(item2.title, "Second Item")
        XCTAssertNil(item2.description)
        XCTAssertNotNil(item2.createdAt)
        XCTAssertNil(item2.updatedAt)
    }
    
    func testDecodeSingleItem() throws {
        let jsonString = """
        {
            "id": "item_test",
            "title": "Test Item",
            "description": "Test Description",
            "created_at": "2025-10-25T10:00:00Z",
            "updated_at": "2025-10-25T11:00:00Z"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let item = try decoder.decode(DomainItem.self, from: data)
        
        XCTAssertEqual(item.id, "item_test")
        XCTAssertEqual(item.title, "Test Item")
        XCTAssertEqual(item.description, "Test Description")
        XCTAssertNotNil(item.createdAt)
        XCTAssertNotNil(item.updatedAt)
    }
}

