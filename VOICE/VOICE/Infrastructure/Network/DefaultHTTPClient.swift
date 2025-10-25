//
//  DefaultHTTPClient.swift
//  VOICE
//
//  Default HTTP client implementation with retry logic and error handling
//

import Foundation

final class DefaultHTTPClient: HTTPClient {
    private let config: Config
    private let keychainService: KeychainService
    private let logger: Logger
    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    
    private let maxRetries = 3
    private let retryableStatusCodes: Set<Int> = [408, 429, 500, 502, 503, 504]
    
    init(
        config: Config,
        keychainService: KeychainService,
        logger: Logger,
        session: URLSession = .shared
    ) {
        self.config = config
        self.keychainService = keychainService
        self.logger = logger
        self.session = session
        
        // Configure JSON decoder
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.dateDecodingStrategy = .iso8601
    }
    
    func send<T: Decodable>(_ request: HTTPRequest) async throws -> T {
        let urlRequest = try buildURLRequest(request)
        let (data, response) = try await performRequest(urlRequest, retries: 0, isRetryable: isRetryableMethod(request.method))
        
        return try decodeResponse(data: data, response: response)
    }
    
    func sendVoid(_ request: HTTPRequest) async throws {
        let urlRequest = try buildURLRequest(request)
        let (_, response) = try await performRequest(urlRequest, retries: 0, isRetryable: isRetryableMethod(request.method))
        
        try validateResponse(response)
    }
    
    // MARK: - Private Methods
    
    private func buildURLRequest(_ request: HTTPRequest) throws -> URLRequest {
        // Build URL
        var components = URLComponents(url: config.apiBaseURL, resolvingAgainstBaseURL: false)
        components?.path = request.path
        
        // Add query parameters
        if let query = request.query, !query.isEmpty {
            components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = components?.url else {
            throw HTTPError.invalidRequest("Invalid URL construction")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = config.apiTimeout
        
        // Add headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authorization header if token available
        if let accessToken = try? keychainService.get("access_token") {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Add custom headers
        request.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body if present
        if let body = request.body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            urlRequest.httpBody = try encoder.encode(AnyEncodable(body))
        }
        
        return urlRequest
    }
    
    private func performRequest(_ request: URLRequest, retries: Int, isRetryable: Bool) async throws -> (Data, HTTPURLResponse) {
        logger.debug("HTTP \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "unknown")", module: "Network")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HTTPError.invalidRequest("Invalid response type")
            }
            
            logger.debug("HTTP Response: \(httpResponse.statusCode)", module: "Network")
            
            // Check if we should retry
            if isRetryable && retryableStatusCodes.contains(httpResponse.statusCode) && retries < maxRetries {
                let delay = calculateBackoff(attempt: retries)
                logger.warning("Retrying request after \(delay)s (attempt \(retries + 1)/\(maxRetries))", module: "Network")
                
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await performRequest(request, retries: retries + 1, isRetryable: isRetryable)
            }
            
            // Handle error responses
            if httpResponse.statusCode >= 400 {
                throw try mapHTTPError(statusCode: httpResponse.statusCode, data: data)
            }
            
            return (data, httpResponse)
            
        } catch let error as HTTPError {
            throw error
        } catch {
            // Network errors
            let nsError = error as NSError
            
            // Retry on network errors if retryable
            if isRetryable && retries < maxRetries && isNetworkError(nsError) {
                let delay = calculateBackoff(attempt: retries)
                logger.warning("Retrying after network error (attempt \(retries + 1)/\(maxRetries))", module: "Network")
                
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await performRequest(request, retries: retries + 1, isRetryable: isRetryable)
            }
            
            throw mapNetworkError(nsError)
        }
    }
    
    private func decodeResponse<T: Decodable>(data: Data, response: HTTPURLResponse) throws -> T {
        try validateResponse(response)
        
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            logger.error("JSON decoding failed: \(error.localizedDescription)", module: "Network")
            throw HTTPError.decodingError("Failed to decode response: \(error.localizedDescription)")
        }
    }
    
    private func validateResponse(_ response: HTTPURLResponse) throws {
        guard (200..<300).contains(response.statusCode) else {
            throw HTTPError.serverError(response.statusCode, "Unexpected status code")
        }
    }
    
    private func mapHTTPError(statusCode: Int, data: Data) throws -> HTTPError {
        // Try to extract error message from response
        var errorMessage = "HTTP error \(statusCode)"
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let message = json["message"] as? String ?? json["error"] as? String {
            errorMessage = message
        }
        
        switch statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 400..<500:
            return .validationError(errorMessage)
        case 500..<600:
            return .serverError(statusCode, errorMessage)
        default:
            return .serverError(statusCode, errorMessage)
        }
    }
    
    private func mapNetworkError(_ error: NSError) -> HTTPError {
        switch error.code {
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
            return .networkUnreachable
        case NSURLErrorTimedOut:
            return .timeout
        default:
            return .networkUnreachable
        }
    }
    
    private func isRetryableMethod(_ method: HTTPMethod) -> Bool {
        // GET and PUT are idempotent and safe to retry
        return method == .get || method == .put
    }
    
    private func isNetworkError(_ error: NSError) -> Bool {
        let retryableCodes = [
            NSURLErrorTimedOut,
            NSURLErrorCannotFindHost,
            NSURLErrorCannotConnectToHost,
            NSURLErrorNetworkConnectionLost,
            NSURLErrorNotConnectedToInternet
        ]
        return retryableCodes.contains(error.code)
    }
    
    private func calculateBackoff(attempt: Int) -> TimeInterval {
        // Exponential backoff: 1s, 2s, 4s
        return pow(2.0, Double(attempt))
    }
}

// MARK: - Helper Types

private struct AnyEncodable: Encodable {
    private let encodable: Encodable
    
    init(_ encodable: Encodable) {
        self.encodable = encodable
    }
    
    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}

