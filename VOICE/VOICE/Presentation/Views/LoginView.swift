//
//  LoginView.swift
//  VOICE
//
//  Login screen using UIActionDispatcher
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Credentials")) {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.password)
                }
                
                Section {
                    Button(action: {
                        Task {
                            await viewModel.login()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Log In")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(viewModel.isLoading || !viewModel.isValid)
                }
            }
            .navigationTitle("VOICE Login")
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isAuthenticated = false
    
    private let dispatcher: UIActionDispatcher = DependencyContainer.shared.uiActionDispatcher
    
    var isValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    func login() async {
        isLoading = true
        
        let action = UIAction(
            id: "auth.login",
            componentId: "login_form",
            payload: [
                "email": AnyCodable(email),
                "password": AnyCodable(password)
            ]
        )
        
        let result = await dispatcher.dispatch(action: action)
        
        isLoading = false
        
        switch result {
        case .success:
            isAuthenticated = true
        case .validationError(let message):
            errorMessage = message
            showError = true
        case .unauthorized:
            errorMessage = "Invalid email or password"
            showError = true
        case .transportError(let message):
            errorMessage = "Network error: \(message)"
            showError = true
        default:
            errorMessage = result.errorMessage ?? "An unknown error occurred"
            showError = true
        }
    }
}

#Preview {
    LoginView()
}

