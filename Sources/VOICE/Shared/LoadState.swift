//
//  LoadState.swift
//  VOICE
//
//  Generic state management for async operations
//

import Foundation

enum LoadState<T> {
    case idle
    case loading
    case loaded(T)
    case error(AppError)
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var value: T? {
        if case .loaded(let value) = self {
            return value
        }
        return nil
    }
    
    var error: AppError? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
}


