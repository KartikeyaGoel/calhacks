# VOICE Tests

## Overview

This test suite follows the testing pyramid with unit tests, integration tests, and contract tests to ensure the stability of the clean architecture implementation.

## Test Structure

```
Tests/
├── Fixtures/              # JSON fixtures for contract tests
├── Mocks/                 # Mock implementations of protocols
├── Unit/                  # Unit tests
│   ├── UseCases/         # Use case tests
│   ├── ContractTests/    # JSON decoding tests
│   └── Repositories/     # Repository tests
├── Integration/          # Integration tests (future)
└── UITests/             # UI tests (future)
```

## Test Categories

### 1. Contract Tests

Validate that domain models correctly decode API responses.

**Location**: `Tests/Unit/ContractTests/`

**Purpose**: Ensure backend API contract compatibility

**Example**:
```swift
func testDecodeAuthLoginResponse() throws {
    let json = loadFixture("auth_login_response")
    let session = try JSONDecoder().decode(AuthSession.self, from: json)
    XCTAssertEqual(session.user.email, "test@example.com")
}
```

**Fixtures**: `Tests/Fixtures/*.json`

### 2. Use Case Unit Tests

Test business logic in isolation using mocked repositories.

**Location**: `Tests/Unit/UseCases/`

**Purpose**: Validate business rules without network/storage dependencies

**Example**:
```swift
func testLoginSuccess() async throws {
    mockAuthRepository.loginHandler = { email, password in
        return AuthSession(...)
    }
    
    let output = try await useCase.execute(input: input)
    
    XCTAssertEqual(output.user.id, "expected_id")
}
```

**Tests**:
- `AuthLoginUseCaseTests`: Login validation, token storage
- `ItemsListUseCaseTests`: Pagination, error handling

### 3. Repository Tests (Future)

Test repository implementations with mocked HTTP client.

**Location**: `Tests/Unit/Repositories/`

**Purpose**: Validate request construction and response handling

### 4. Integration Tests (Future)

Test complete flows with real network stack against mock server.

**Location**: `Tests/Integration/`

**Purpose**: Validate end-to-end behavior

### 5. UI Tests (Future)

Test user flows through the SwiftUI interface.

**Location**: `Tests/UITests/`

**Purpose**: Validate UI interactions

## Mock Implementations

### MockHTTPClient
Simulates network requests without actual HTTP calls.

```swift
mockHTTPClient.sendHandler = { request in
    return mockData
}
```

### MockKeychainService
In-memory keychain for testing token storage.

```swift
try mockKeychainService.save("token", for: "access_token")
let token = try mockKeychainService.get("access_token")
```

### MockLogger
Captures log messages for verification.

```swift
XCTAssertTrue(mockLogger.logs.contains(where: { $0.message.contains("Login") }))
```

### MockAuthRepository / MockItemsRepository
Mock repository implementations for use case testing.

```swift
mockAuthRepository.loginHandler = { email, password in
    throw HTTPError.unauthorized
}
```

## Running Tests

### All Tests
```bash
xcodebuild test \
  -project VOICE/VOICE.xcodeproj \
  -scheme VOICE-Dev \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Specific Test Suite
```bash
xcodebuild test \
  -project VOICE/VOICE.xcodeproj \
  -scheme VOICE-Dev \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:VOICETests/AuthLoginUseCaseTests
```

### Using Script
```bash
./Scripts/test.sh VOICE-Dev
```

## Test Coverage

Target minimum coverage:
- **Domain Layer**: 90%+ (use cases)
- **Data Layer**: 80%+ (repositories)
- **Infrastructure**: 70%+ (HTTP client, keychain)
- **Presentation**: 60%+ (view models)

## Writing New Tests

### 1. Add Test Fixtures

For new API endpoints:
```json
// Tests/Fixtures/new_endpoint_response.json
{
  "id": "test_id",
  "field": "value"
}
```

### 2. Create Contract Test

```swift
func testDecodeNewEndpointResponse() throws {
    let json = loadFixture("new_endpoint_response")
    let model = try JSONDecoder().decode(NewModel.self, from: json)
    XCTAssertEqual(model.id, "test_id")
}
```

### 3. Create Use Case Test

```swift
func testNewUseCaseSuccess() async throws {
    mockRepository.handler = { input in
        return ExpectedOutput(...)
    }
    
    let output = try await useCase.execute(input: input)
    
    XCTAssertEqual(output.result, expectedValue)
}
```

## Best Practices

1. **Isolation**: Each test should be independent
2. **AAA Pattern**: Arrange, Act, Assert
3. **Descriptive Names**: `testLoginWithInvalidCredentialsShowsError`
4. **Mock External Dependencies**: Network, storage, time
5. **Async Testing**: Use `async throws` for async use cases
6. **Reset Mocks**: Call `reset()` in `tearDown()`

## Continuous Integration

Tests run automatically on:
- Pull request creation
- Commits to main branch
- Manual workflow dispatch

See `.github/workflows/test.yml` for CI configuration.

## Debugging Tests

Enable verbose logging:
```swift
let logger = MockLogger()
// Logger captures all messages
logger.logs.forEach { print($0) }
```

View test failures:
```bash
# Show test results
cat DerivedData/Logs/Test/*.xcresult
```

## Known Issues

- XCTest async/await requires iOS 15+
- Mock implementations must match protocol signatures exactly
- Fixtures must use ISO8601 date format

## Future Additions

- [ ] Integration tests with WireMock
- [ ] UI tests for critical flows
- [ ] Performance tests for list scrolling
- [ ] Snapshot tests for UI components
- [ ] Mutation testing

