//
//  ComponentRegistry.swift
//  VOICE
//
//  Component registry for mapping UI components to use cases
//

import Foundation

struct ComponentRegistry: Codable {
    let components: [Component]
    let actions: [String: ActionMapping]
    
    struct Component: Codable {
        let id: String
        let type: String
        let fields: [String]?
        let onSubmit: String?
        let onTap: String?
        let onRefresh: String?
    }
    
    struct ActionMapping: Codable {
        let useCase: String
    }
}

final class ComponentRegistryLoader {
    static func load(from fileName: String = "ComponentRegistry") -> ComponentRegistry? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let registry = try? JSONDecoder().decode(ComponentRegistry.self, from: data) else {
            return nil
        }
        return registry
    }
    
    static func loadOrDefault() -> ComponentRegistry {
        return load() ?? ComponentRegistry(
            components: [],
            actions: [:]
        )
    }
}

