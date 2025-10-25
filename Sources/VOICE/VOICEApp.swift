//
//  VOICEApp.swift
//  VOICE
//
//  Created by Kartikeya Goel on 10/24/25.
//

import SwiftUI

@main
struct VOICEApp: App {
    init() {
        // Initialize dependency container early
        _ = DependencyContainer.shared
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

