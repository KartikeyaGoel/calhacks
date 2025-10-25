//
//  ItemsRepository.swift
//  VOICE
//
//  Items repository protocol (Data layer)
//

import Foundation

protocol ItemsRepository {
    func list(cursor: String?, limit: Int) async throws -> (items: [DomainItem], nextCursor: String?)
    func create(title: String, description: String?) async throws -> DomainItem
    func update(id: String, title: String, description: String?) async throws -> DomainItem
    func delete(id: String) async throws
}


