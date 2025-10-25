//
//  UIActionDispatcher.swift
//  VOICE
//
//  Protocol for dispatching UI actions to domain layer
//

import Foundation

protocol UIActionDispatcher {
    func dispatch(action: UIAction) async -> UIResult
}

