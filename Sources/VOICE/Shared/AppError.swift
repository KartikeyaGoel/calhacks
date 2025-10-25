//
//  AppError.swift
//  VOICE
//
//  Centralized error handling for the application
//

import Foundation

enum AppError: Error, Equatable {
    case network(String)
    case validation(String)
    case unauthorized
    case forbidden
    case notFound
    case server(String)
    case decoding(String)
    case unknown(String)
    
    var localizedDescription: String {
        switch self {
        case .network(let message):
            return "Network error: \(message)"
        case .validation(let message):
            return "Validation error: \(message)"
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .forbidden:
            return "You don't have permission to access this resource."
        case .notFound:
            return "Resource not found."
        case .server(let message):
            return "Server error: \(message)"
        case .decoding(let message):
            return "Data parsing error: \(message)"
        case .unknown(let message):
            return "An unexpected error occurred: \(message)"
        }
    }
    
    static func from(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        
        let nsError = error as NSError
        
        // Map URLSession errors
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
            return .network("No internet connection")
        case NSURLErrorTimedOut:
            return .network("Request timed out")
        case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
            return .network("Cannot reach server")
        default:
            return .unknown(error.localizedDescription)
        }
    }
}


