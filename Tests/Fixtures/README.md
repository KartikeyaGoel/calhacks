# Test Fixtures

This directory contains JSON fixtures for contract testing.

## Usage

Contract tests validate that our domain models correctly decode responses from the backend API.

### Example Files

- `auth_login_response.json`: Sample response from POST /auth/login
- `items_list_response.json`: Sample response from GET /items
- `user_profile_response.json`: Sample response from GET /users/me

### Adding New Fixtures

1. Create a JSON file matching the API response format
2. Add a corresponding test in `/Tests/Unit/ContractTests/`
3. Validate decoding and field mapping

Example test:
```swift
func testDecodeAuthLoginResponse() throws {
    let json = try loadFixture("auth_login_response.json")
    let session = try JSONDecoder().decode(AuthSession.self, from: json)
    XCTAssertEqual(session.user.email, "user@example.com")
}
```

