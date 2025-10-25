lorem ipsum//
//  ItemsListView.swift
//  VOICE
//
//  Items list screen using UIActionDispatcher
//

import SwiftUI

struct ItemsListView: View {
    @StateObject private var viewModel = ItemsListViewModel()
    @State private var showCreateSheet = false
    
    var body: some View {
        NavigationView {
            Group {
                switch viewModel.state {
                case .idle:
                    Text("Pull to refresh")
                        .foregroundColor(.secondary)
                    
                case .loading:
                    ProgressView("Loading items...")
                    
                case .loaded(let items):
                    if items.isEmpty {
                        emptyState
                    } else {
                        itemsList(items: items)
                    }
                    
                case .error(let error):
                    errorView(error: error)
                }
            }
            .navigationTitle("Items")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Logout") {
                        Task { await viewModel.logout() }
                    }
                }
            }
            .refreshable {
                await viewModel.loadItems()
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateItemView { await viewModel.loadItems() }
            }
            .task {
                await viewModel.loadItems()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No items yet")
                .font(.title2)
            Text("Tap + to create your first item")
                .foregroundColor(.secondary)
        }
    }
    
    private func itemsList(items: [ItemDisplayModel]) -> some View {
        List {
            ForEach(items) { item in
                ItemRowView(item: item)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteItem(id: item.id)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }
    
    private func errorView(error: AppError) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            Text("Error")
                .font(.title2)
            Text(error.localizedDescription)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await viewModel.loadItems() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct ItemRowView: View {
    let item: ItemDisplayModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.headline)
            
            if let description = item.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Text(item.createdAt, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct ItemDisplayModel: Identifiable {
    let id: String
    let title: String
    let description: String?
    let createdAt: Date
}

@MainActor
final class ItemsListViewModel: ObservableObject {
    @Published var state: LoadState<[ItemDisplayModel]> = .idle
    @Published var isLoggedOut = false
    
    private let dispatcher: UIActionDispatcher = DependencyContainer.shared.uiActionDispatcher
    
    func loadItems() async {
        state = .loading
        
        let action = UIAction(
            id: "items.list",
            componentId: "items_list",
            payload: ["limit": AnyCodable(50)]
        )
        
        let result = await dispatcher.dispatch(action: action)
        
        switch result {
        case .success(let data):
            if let itemsData = data["items"]?.value as? [[String: Any]] {
                let items = itemsData.compactMap { dict -> ItemDisplayModel? in
                    guard let id = dict["id"] as? String,
                          let title = dict["title"] as? String,
                          let createdAtString = dict["created_at"] as? String,
                          let createdAt = ISO8601DateFormatter().date(from: createdAtString) else {
                        return nil
                    }
                    
                    return ItemDisplayModel(
                        id: id,
                        title: title,
                        description: dict["description"] as? String,
                        createdAt: createdAt
                    )
                }
                state = .loaded(items)
            } else {
                state = .error(.decoding("Invalid items format"))
            }
            
        case .unauthorized:
            isLoggedOut = true
            
        default:
            let message = result.errorMessage ?? "Failed to load items"
            state = .error(.unknown(message))
        }
    }
    
    func deleteItem(id: String) async {
        let action = UIAction(
            id: "items.delete",
            componentId: "delete_item_button",
            payload: ["id": AnyCodable(id)]
        )
        
        let result = await dispatcher.dispatch(action: action)
        
        if result.isSuccess {
            // Reload items after successful delete
            await loadItems()
        }
    }
    
    func logout() async {
        let action = UIAction(
            id: "auth.logout",
            componentId: "logout_button"
        )
        
        _ = await dispatcher.dispatch(action: action)
        isLoggedOut = true
    }
}

#Preview {
    ItemsListView()
}


