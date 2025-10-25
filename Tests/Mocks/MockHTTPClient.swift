//
//  MockHTTPClient.swift
//  VOICE Tests
//
//  Mock HTTP client for testing
//

import Foundation

final class MockHTTPClient: HTTPClient {
    var sendHandler: ((HTTPRequest) async throws -> Any)?
    var sendVoidHandler: ((HTTPRequest) async throws -> Void)?
    
    var lastRequest: HTTPRequest?
    var requestCount = 0
    
    func send<T: Decodable>(_ request: HTTPRequest) async throws -> T {
        lastRequest = request
        requestCount += 1
        
        guard let handler = sendHandler else {
            throw HTTPError.serverError(500, "No handler configured")
        }
        
        let result = try await handler(request)
        
        if let typedResult = result as? T {
            return typedResult
        } else if let data = result as? Data {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } else {
            throw HTTPError.decodingError("Cannot convert result to type \(T.self)")
        }
    }
    
    func sendVoid(_ request: HTTPRequest) async throws {
        lastRequest = request
        requestCount += 1
        
        if let handler = sendVoidHandler {
            try await handler(request)
        }
    }
    
    func reset() {
        sendHandler = nil
        sendVoidHandler = nil
        lastRequest = nil
        requestCount = 0
    }
}

