//
//  CreateItemView.swift
//  VOICE
//
//  Create item sheet using UIActionDispatcher
//

import SwiftUI

struct CreateItemView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateItemViewModel()
    
    let onCreated: () async -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Title", text: $viewModel.title)
                    
                    TextEditor(text: $viewModel.description)
                        .frame(height: 100)
                }
                
                Section {
                    Button(action: {
                        Task {
                            if await viewModel.createItem() {
                                await onCreated()
                                dismiss()
                            }
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Create Item")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(viewModel.isLoading || !viewModel.isValid)
                }
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

@MainActor
final class CreateItemViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let dispatcher: UIActionDispatcher = DependencyContainer.shared.uiActionDispatcher
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func createItem() async -> Bool {
        isLoading = true
        
        let action = UIAction(
            id: "items.create",
            componentId: "new_item_form",
            payload: [
                "title": AnyCodable(title),
                "description": AnyCodable(description.isEmpty ? nil : description)
            ]
        )
        
        let result = await dispatcher.dispatch(action: action)
        
        isLoading = false
        
        switch result {
        case .success:
            return true
        case .validationError(let message):
            errorMessage = message
            showError = true
            return false
        default:
            errorMessage = result.errorMessage ?? "Failed to create item"
            showError = true
            return false
        }
    }
}

#Preview {
    CreateItemView(onCreated: {})
}


