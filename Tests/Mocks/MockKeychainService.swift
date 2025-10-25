//
//  MockKeychainService.swift
//  VOICE Tests
//
//  Mock keychain service for testing
//

import Foundation
@testable import VOICE

final class MockKeychainService: KeychainService {
    private var storage: [String: String] = [:]
    
    func save(_ value: String, for key: String) throws {
        storage[key] = value
    }
    
    func get(_ key: String) throws -> String? {
        return storage[key]
    }
    
    func delete(_ key: String) throws {
        storage.removeValue(forKey: key)
    }
    
    func clear() throws {
        storage.removeAll()
    }
    
    func reset() {
        storage.removeAll()
    }
}

