//
//  HTTPClient.swift
//  VOICE
//
//  HTTP client protocol and types for network communication
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

struct HTTPRequest {
    let path: String
    let method: HTTPMethod
    let query: [String: String]?
    let headers: [String: String]?
    let body: Encodable?
    
    init(
        path: String,
        method: HTTPMethod,
        query: [String: String]? = nil,
        headers: [String: String]? = nil,
        body: Encodable? = nil
    ) {
        self.path = path
        self.method = method
        self.query = query
        self.headers = headers
        self.body = body
    }
}

protocol HTTPClient {
    func send<T: Decodable>(_ request: HTTPRequest) async throws -> T
    func sendVoid(_ request: HTTPRequest) async throws
}

// Error codes for HTTP client
enum HTTPError: Error, Equatable {
    case networkUnreachable
    case timeout
    case unauthorized
    case forbidden
    case notFound
    case validationError(String)
    case serverError(Int, String)
    case decodingError(String)
    case invalidRequest(String)
    
    static func == (lhs: HTTPError, rhs: HTTPError) -> Bool {
        switch (lhs, rhs) {
        case (.networkUnreachable, .networkUnreachable),
             (.timeout, .timeout),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound):
            return true
        case (.validationError(let a), .validationError(let b)),
             (.serverError(_, let a), .serverError(_, let b)),
             (.decodingError(let a), .decodingError(let b)),
             (.invalidRequest(let a), .invalidRequest(let b)):
            return a == b
        default:
            return false
        }
    }
}

