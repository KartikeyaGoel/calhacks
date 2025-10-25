//
//  RootView.swift
//  VOICE
//
//  Root coordinator view for navigation
//

import SwiftUI

struct RootView: View {
    @StateObject private var authState = AuthStateManager()
    
    var body: some View {
        Group {
            if authState.isAuthenticated {
                ItemsListView()
                    .onChange(of: authState.isAuthenticated) { newValue in
                        if !newValue {
                            // User logged out, show login
                        }
                    }
            } else {
                LoginView()
                    .onChange(of: authState.isAuthenticated) { newValue in
                        if newValue {
                            // User logged in, show items list
                        }
                    }
            }
        }
        .task {
            await authState.checkAuthentication()
        }
    }
}

@MainActor
final class AuthStateManager: ObservableObject {
    @Published var isAuthenticated = false
    
    private let keychainService = DependencyContainer.shared.keychainService
    
    func checkAuthentication() async {
        // Check if we have a valid access token
        if let token = try? keychainService.get("access_token"), !token.isEmpty {
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }
    }
    
    func logout() {
        isAuthenticated = false
    }
}

#Preview {
    RootView()
}


