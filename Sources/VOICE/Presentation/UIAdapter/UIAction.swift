//
//  UIAction.swift
//  VOICE
//
//  UI action model for frontend-agnostic interaction
//

import Foundation

struct UIAction {
    let id: String
    let componentId: String
    let payload: [String: AnyCodable]
    
    init(id: String, componentId: String, payload: [String: AnyCodable] = [:]) {
        self.id = id
        self.componentId = componentId
        self.payload = payload
    }
}

enum UIResult {
    case success([String: AnyCodable])
    case validationError(String)
    case transportError(String)
    case unauthorized
    case notFound
    case serverError(String)
    
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        switch self {
        case .success:
            return nil
        case .validationError(let message),
             .transportError(let message),
             .serverError(let message):
            return message
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .notFound:
            return "Resource not found."
        }
    }
}


