# UI Adapter and Component Registry

## Overview

The UI Adapter provides a stable contract between the frontend (UI) and backend (Domain/Data/Infrastructure) layers, enabling complete frontend replacement without touching business logic.

## Architecture

```
┌──────────────────────────────────────────────┐
│           UI Layer (Replaceable)             │
│  SwiftUI / UIKit / React Native / Flutter   │
└────────────────┬─────────────────────────────┘
                 │
                 │ UIAction
                 ▼
┌──────────────────────────────────────────────┐
│         UIActionDispatcher Protocol          │
└────────────────┬─────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────┐
│              UIAdapter                       │
│  • Reads ComponentRegistry.json              │
│  • Maps actions to use cases                 │
│  • Translates payloads                       │
│  • Returns UIResult                          │
└────────────────┬─────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────┐
│         Domain Use Cases                     │
│  AuthLoginUseCase, ItemsListUseCase, etc.   │
└──────────────────────────────────────────────┘
```

## Core Types

### UIAction

Represents a user interaction from the UI:

```swift
struct UIAction {
    let id: String              // e.g., "auth.login"
    let componentId: String     // e.g., "login_form"
    let payload: [String: AnyCodable]  // Dynamic data
}
```

**Example:**
```swift
let action = UIAction(
    id: "auth.login",
    componentId: "login_form",
    payload: [
        "email": AnyCodable("user@example.com"),
        "password": AnyCodable("secret")
    ]
)
```

### UIResult

Represents the result of a UI action:

```swift
enum UIResult {
    case success([String: AnyCodable])
    case validationError(String)
    case transportError(String)
    case unauthorized
    case notFound
    case serverError(String)
}
```

### UIActionDispatcher

Protocol that any UI layer must use:

```swift
protocol UIActionDispatcher {
    func dispatch(action: UIAction) async -> UIResult
}
```

## Component Registry

The `ComponentRegistry.json` file defines the mapping between UI components and domain use cases.

### Structure

```json
{
  "components": [
    {
      "id": "login_form",
      "type": "form",
      "fields": ["email", "password"],
      "onSubmit": "auth.login"
    }
  ],
  "actions": {
    "auth.login": {
      "useCase": "AuthLoginUseCase"
    }
  }
}
```

### Component Types

- **form**: Input form with fields
- **button**: Single action button
- **list**: Scrollable list with refresh
- **view**: Display-only component

### Action Events

- **onSubmit**: Form submission
- **onTap**: Button tap
- **onRefresh**: Pull-to-refresh

## Available Actions

| Action ID | Use Case | Description |
|-----------|----------|-------------|
| `auth.login` | `AuthLoginUseCase` | User login with email/password |
| `auth.logout` | `AuthLogoutUseCase` | User logout |
| `items.list` | `ItemsListUseCase` | Fetch items list with pagination |
| `items.create` | `ItemsCreateUseCase` | Create new item |
| `items.update` | `ItemsUpdateUseCase` | Update existing item |
| `items.delete` | `ItemsDeleteUseCase` | Delete item by ID |
| `user.current` | `GetCurrentUserUseCase` | Fetch current user profile |

## Usage in SwiftUI

```swift
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        Form {
            TextField("Email", text: $viewModel.email)
            SecureField("Password", text: $viewModel.password)
            Button("Login") {
                Task {
                    await viewModel.login()
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Text(viewModel.errorMessage)
        }
    }
}

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let dispatcher: UIActionDispatcher = DependencyContainer.shared.uiActionDispatcher
    
    func login() async {
        let action = UIAction(
            id: "auth.login",
            componentId: "login_form",
            payload: [
                "email": AnyCodable(email),
                "password": AnyCodable(password)
            ]
        )
        
        let result = await dispatcher.dispatch(action: action)
        
        switch result {
        case .success(let data):
            // Handle successful login
            print("Logged in: \(data)")
        case .validationError(let message):
            errorMessage = message
            showError = true
        case .unauthorized:
            errorMessage = "Invalid credentials"
            showError = true
        default:
            errorMessage = result.errorMessage ?? "Unknown error"
            showError = true
        }
    }
}
```

## Frontend Swap Procedure

To replace the UI with a new framework:

### 1. Keep the SDK Intact
- Do **not** modify Domain, Data, or Infrastructure layers
- Do **not** modify UIAdapter or ComponentRegistry

### 2. Create New UI Components
- Implement new views in your chosen framework
- Each component must:
  - Create UIAction instances
  - Call UIActionDispatcher.dispatch()
  - Handle UIResult responses

### 3. Wire Dependencies
```swift
// In your new framework's initialization
let dispatcher = DependencyContainer.shared.uiActionDispatcher

// Use in your views/components
let result = await dispatcher.dispatch(action: action)
```

### 4. Optional: Extend Component Registry
If you need new UI-specific actions:

```json
{
  "components": [
    {
      "id": "new_feature_view",
      "type": "view",
      "onRefresh": "feature.load"
    }
  ],
  "actions": {
    "feature.load": {
      "useCase": "NewFeatureUseCase"
    }
  }
}
```

Then implement the use case in the Domain layer and add it to UIAdapter.

### 5. Test
- Run unit tests (should all still pass)
- Test each action through new UI
- Verify UIResult handling

## Benefits

1. **Framework Agnostic**: Works with SwiftUI, UIKit, React Native, Flutter, etc.
2. **Stable Contract**: Backend never changes when UI changes
3. **Type Safe**: AnyCodable handles dynamic payloads safely
4. **Testable**: Mock UIActionDispatcher for UI tests
5. **Declarative**: Component registry is self-documenting
6. **Versioned**: Registry can evolve with backward compatibility

## Debugging

Enable verbose logging:
```swift
let logger = DependencyContainer.shared.logger
logger.debug("Action dispatched", module: "UIAdapter")
```

Check logs for:
- Action dispatch and completion
- Use case execution
- Error mapping

## Adding New Actions

1. Define use case in Domain layer
2. Implement repository in Data layer (if needed)
3. Add action to ComponentRegistry.json
4. Add case in UIAdapter.executeUseCase()
5. Create executor method (e.g., executeMyNewAction)
6. Test with UI

Example:
```swift
// 1. UIAdapter.swift
case "MyNewUseCase":
    return try await executeMyNew(payload: payload)

// 2. Add executor
private func executeMyNew(payload: [String: AnyCodable]) async throws -> UIResult {
    guard let param = payload["param"]?.value as? String else {
        throw AppError.validation("param is required")
    }
    
    let input = MyNewUseCase.Input(param: param)
    let output = try await myNewUseCase.execute(input: input)
    
    return .success(["result": AnyCodable(output.result)])
}
```

## API Contract Versioning

To version the API while maintaining UI compatibility:

1. Add version field to UIAction
2. UIAdapter handles multiple payload formats
3. Translate to appropriate use case input

This ensures old and new UIs can coexist during migration.

