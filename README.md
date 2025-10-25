# VOICE iOS App

A modular iOS application built with Clean Architecture principles, designed for frontend flexibility and backend stability.

[![CI](https://github.com/username/voice/workflows/CI/badge.svg)](https://github.com/username/voice/actions)
[![Swift 5.7+](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![iOS 15.0+](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Overview

VOICE demonstrates a production-ready iOS architecture with:
- **Clean Architecture** with strict layer boundaries
- **Frontend Agnostic** design via UI Adapter pattern
- **Environment Configuration** for Dev/Staging/Prod
- **Comprehensive Testing** with unit and contract tests
- **CI/CD** with GitHub Actions

## Features

### Architecture
- ✅ Clean Architecture (Presentation, Domain, Data, Infrastructure)
- ✅ Dependency Inversion throughout all layers
- ✅ Protocol-oriented design for testability
- ✅ UI Adapter for frontend swapping
- ✅ Component Registry for declarative UI mapping

### Authentication
- ✅ Email/password login
- ✅ Automatic token refresh on 401
- ✅ Secure token storage in Keychain
- ✅ Logout with backend invalidation

### Items Management
- ✅ List items with cursor-based pagination
- ✅ Create new items
- ✅ Update existing items
- ✅ Delete items
- ✅ Pull-to-refresh

### Infrastructure
- ✅ HTTP client with retry logic
- ✅ Exponential backoff for failed requests
- ✅ Comprehensive error handling
- ✅ Structured logging
- ✅ Environment-based configuration

## Project Structure

```
VOICE/
├── VOICE/
│   ├── Presentation/          # UI layer (replaceable)
│   │   ├── Views/            # SwiftUI views
│   │   └── UIAdapter/        # Frontend decoupling
│   ├── Domain/               # Business logic (pure Swift)
│   │   ├── Entities/         # Core models
│   │   └── UseCases/         # Business operations
│   ├── Data/                 # Data access
│   │   └── Repositories/     # Repository implementations
│   ├── Infrastructure/       # External services
│   │   ├── Network/          # HTTP client
│   │   ├── Storage/          # Keychain
│   │   └── Logging/          # Logger
│   ├── Config/               # Configuration service
│   ├── Shared/               # Utilities
│   └── Resources/            # Assets, JSON files
├── Config/                   # xcconfig files
├── Tests/                    # Test suite
│   ├── Unit/                # Unit tests
│   ├── Mocks/               # Mock implementations
│   └── Fixtures/            # JSON fixtures
├── Scripts/                  # Build and test scripts
└── Docs/                     # Documentation

```

## Getting Started

### Prerequisites

- macOS 13.0+
- Xcode 15.0+
- iOS 15.0+ target
- Swift 5.7+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/username/voice.git
   cd voice
   ```

2. **Open the project**
   ```bash
   open VOICE/VOICE.xcodeproj
   ```

3. **Configure schemes** (see [Environment Setup](Docs/ENVIRONMENT_SETUP.md))
   - Link xcconfig files to build configurations
   - Create schemes for Dev, Staging, and Prod

4. **Build and run**
   ```bash
   # Using script
   ./Scripts/build.sh VOICE-Dev
   
   # Or in Xcode
   # Select VOICE-Dev scheme
   # Cmd+R to run
   ```

### Running Tests

```bash
# All tests
./Scripts/test.sh VOICE-Dev

# Specific test
xcodebuild test \
  -project VOICE/VOICE.xcodeproj \
  -scheme VOICE-Dev \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:VOICETests/AuthLoginUseCaseTests
```

## Configuration

### Environments

The app supports three environments configured via xcconfig files:

| Environment | API Base URL | Bundle ID | Analytics |
|-------------|--------------|-----------|-----------|
| Dev | `https://dev.api.voice-app.com` | `com.voice.app.dev` | Disabled |
| Staging | `https://staging.api.voice-app.com` | `com.voice.app.staging` | Enabled |
| Prod | `https://api.voice-app.com` | `com.voice.app` | Enabled |

### Configuration Keys

Edit `Config/*.xcconfig` files:

```bash
# Config/Dev.xcconfig
API_BASE_URL = https://dev.api.voice-app.com
BUILD_ENV = DEV
API_TIMEOUT = 30
FEATURE_FLAGS_BOOTSTRAP_URL = https://dev.api.voice-app.com/feature-flags
```

See [Environment Setup Guide](Docs/ENVIRONMENT_SETUP.md) for details.

## Architecture

### Layer Dependency Flow

```
Presentation → Domain ← Data → Infrastructure
                ↑
              Config
```

**Key Principles:**
- Presentation depends only on Domain (use cases)
- Domain has no dependencies (pure business logic)
- Data implements Domain protocols using Infrastructure
- Infrastructure is the leaf layer (frameworks)

### UI Adapter Pattern

The UI Adapter enables complete frontend replacement:

```swift
// Any UI framework can dispatch actions
let action = UIAction(
    id: "auth.login",
    componentId: "login_form",
    payload: ["email": "user@example.com", "password": "secret"]
)

let result = await dispatcher.dispatch(action: action)

// Handle result
switch result {
case .success(let data):
    // Navigate or update UI
case .validationError(let message):
    // Show error
}
```

See [UI Adapter Documentation](Docs/UI_ADAPTER.md) for details.

## API Integration

### Backend Contract

The app expects the following API endpoints:

#### Authentication
- `POST /auth/login` - Login with email/password
- `POST /auth/refresh` - Refresh access token
- `POST /auth/logout` - Logout and invalidate token

#### Items
- `GET /items?cursor=<cursor>&limit=<n>` - List items with pagination
- `POST /items` - Create new item
- `PUT /items/:id` - Update item
- `DELETE /items/:id` - Delete item

#### User Profile
- `GET /users/me` - Get current user
- `PUT /users/me` - Update profile

See [PRD](Docs/PRD.md) for detailed API contracts with request/response examples.

## Testing

### Test Strategy

- **Unit Tests**: Use cases with mocked repositories
- **Contract Tests**: Validate JSON decoding
- **Integration Tests**: Repositories with mocked HTTP client

### Coverage Goals

- Domain layer: 90%+
- Data layer: 80%+
- Infrastructure: 70%+

### Running Tests

```bash
# All tests
xcodebuild test -scheme VOICE-Dev

# With coverage
xcodebuild test -scheme VOICE-Dev -enableCodeCoverage YES

# View coverage
xcrun xccov view DerivedData/Logs/Test/*.xcresult
```

See [Test Documentation](Tests/README.md) for details.

## CI/CD

### GitHub Actions Workflows

- **CI**: Build, test, and lint on every push/PR
- **PR Checks**: Validate commits, check code quality
- **Release**: Create releases with archives for all environments

### Status Checks

All pull requests must pass:
- ✅ Build succeeds
- ✅ All tests pass
- ✅ SwiftLint passes
- ✅ Commit messages follow conventions
- ✅ No large files

See [CI/CD Documentation](Docs/CI_CD.md) for details.

## Frontend Replacement Guide

To replace the UI with a new framework (React Native, Flutter, etc.):

1. **Keep SDK intact**: Don't modify Domain, Data, Infrastructure
2. **Implement UIActionDispatcher**: Use existing protocol
3. **Create new views**: Dispatch actions via UIActionDispatcher
4. **Handle UIResult**: Map results to your UI framework
5. **Optional**: Extend ComponentRegistry.json for new components

Example:
```swift
// New framework's view
func loginButtonTapped() {
    let action = UIAction(id: "auth.login", componentId: "login", payload: data)
    let result = await dispatcher.dispatch(action: action)
    // Handle result in your framework
}
```

See [UI Adapter Documentation](Docs/UI_ADAPTER.md) for step-by-step guide.

## Documentation

- [Architecture Overview](Docs/ARCHITECTURE.md)
- [Environment Setup](Docs/ENVIRONMENT_SETUP.md)
- [UI Adapter Guide](Docs/UI_ADAPTER.md)
- [CI/CD Guide](Docs/CI_CD.md)
- [Test Documentation](Tests/README.md)
- [Product Requirements](Docs/PRD.md)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'feat: add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Follow [Conventional Commits](https://www.conventionalcommits.org/) format.

## Code Style

- SwiftLint enforced (see `.swiftlint.yml`)
- Use protocols for abstractions
- Async/await over closures
- Logger instead of print statements
- Comprehensive error handling

## Troubleshooting

### Build Errors

**Problem**: `API_BASE_URL not configured`
- **Solution**: Ensure xcconfig files are linked in Build Settings

**Problem**: Code signing errors
- **Solution**: Set "Code Signing" to "Sign to Run Locally"

### Test Failures

**Problem**: Tests fail with network error
- **Solution**: Tests should use mocked network, check MockHTTPClient setup

**Problem**: Keychain errors in tests
- **Solution**: Use MockKeychainService in test setup

See [Troubleshooting Guide](Docs/TROUBLESHOOTING.md) for more.

## Performance

- **Cold Start**: ~2s on iPhone 15
- **Auth Response**: ~500ms
- **List Load**: ~300ms (20 items)
- **Memory**: ~50MB baseline

## Security

- ✅ Tokens stored securely in Keychain
- ✅ No secrets in code or version control
- ✅ TLS enforced for all network requests
- ✅ Input validation at use case level
- ✅ No PII in logs

## Roadmap

### v1.1
- [ ] Offline support with local cache
- [ ] Push notifications
- [ ] Image upload
- [ ] Search functionality

### v1.2
- [ ] Dark mode support
- [ ] Accessibility improvements
- [ ] Widget support

### v2.0
- [ ] GraphQL support
- [ ] Advanced analytics
- [ ] Crash reporting
- [ ] Feature flag remote config

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Clean Architecture principles by Robert C. Martin
- iOS community best practices
- Swift Package Manager ecosystem

## Contact

For questions or support:
- Create an issue
- Email: support@voice-app.com
- Slack: #voice-ios

---

**Built with ❤️ using Clean Architecture**

