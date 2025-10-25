# VOICE App Architecture

## Overview

This iOS application follows Clean Architecture principles with strict layer separation and dependency inversion. The architecture is designed to support frontend swapping while maintaining a stable backend contract.

## Layer Structure

### 1. Presentation Layer (`/VOICE/Presentation/`)
- **Responsibility**: UI components, views, and view models
- **Dependencies**: Can only depend on Domain layer
- **Contains**: SwiftUI views, UIKit components, ViewModels

### 2. Domain Layer (`/VOICE/Domain/`)
- **Responsibility**: Business logic and entities (pure Swift, no frameworks)
- **Dependencies**: No dependencies on other layers
- **Contains**:
  - `Entities/`: Core business objects (User, DomainItem, AuthSession)
  - `UseCases/`: Business operations (AuthLoginUseCase, ItemsListUseCase, etc.)

### 3. Data Layer (`/VOICE/Data/`)
- **Responsibility**: Repository implementations and data access
- **Dependencies**: Domain (protocols) and Infrastructure
- **Contains**:
  - `Repositories/`: Protocol definitions for data access

### 4. Infrastructure Layer (`/VOICE/Infrastructure/`)
- **Responsibility**: Framework implementations and external services
- **Dependencies**: None (leaf layer)
- **Contains**:
  - `Network/`: HTTP client, request/response handling
  - `Storage/`: Keychain, file storage, cache
  - `Logging/`: Logging service

### 5. Config Layer (`/VOICE/Config/`)
- **Responsibility**: Environment configuration and build settings
- **Dependencies**: None
- **Contains**: Config protocol and default implementation

### 6. Shared Layer (`/VOICE/Shared/`)
- **Responsibility**: Common utilities and types
- **Dependencies**: None
- **Contains**: AppError, LoadState, AnyCodable

## Dependency Rules

```
Presentation → Domain ← Data → Infrastructure
                ↑
              Config
                ↑
              Shared
```

- Dependencies flow inward: Presentation → Domain ← Data ← Infrastructure
- Domain layer has no dependencies (pure business logic)
- Shared and Config can be used by any layer

## Key Protocols

### Config
Provides environment-specific configuration (API URLs, timeouts, feature flags)

### HTTPClient
Handles network requests with retry logic and error mapping

### KeychainService
Secure storage for tokens and sensitive data

### Logger
Unified logging interface for debugging and monitoring

### Repositories
- `AuthRepository`: Authentication operations
- `ItemsRepository`: CRUD operations for items

### Use Cases
- `AuthLoginUseCase`: User authentication
- `ItemsListUseCase`: Fetch items list
- `ItemsCreateUseCase`: Create new item

## Error Handling

Centralized error handling via `AppError` enum:
- Network errors
- Validation errors
- Authorization errors
- Server errors
- Decoding errors

## State Management

Generic `LoadState<T>` enum for async operations:
- `.idle`: Initial state
- `.loading`: Operation in progress
- `.loaded(T)`: Success with data
- `.error(AppError)`: Failure with error

## Testing Strategy

- **Unit Tests**: Use cases with mock repositories
- **Integration Tests**: Repository implementations with mock server
- **Contract Tests**: Validate JSON decoding with fixtures
- **UI Tests**: End-to-end flows

## Frontend Adaptability

The architecture supports frontend swapping via:
1. UI Adapter pattern translating UI events to use cases
2. Component Registry mapping UI components to actions
3. Stable SDK (Domain + Data + Infrastructure) with clear protocols

See PRD for detailed frontend swap procedure.

