# Swift Package Manager Guide

This project has been restructured to support Swift Package Manager (SPM), allowing you to build and test the code directly from Cursor or the command line without opening Xcode.

## 📁 New Project Structure

```
/workspace/
├── Package.swift              # SPM manifest file
├── Sources/
│   ├── VOICE/                # Main library code
│   │   ├── Domain/          # Business logic & entities
│   │   ├── Data/            # Repository implementations
│   │   ├── Infrastructure/  # Network, storage, logging
│   │   ├── Presentation/    # UI & view models
│   │   └── Shared/          # Common utilities
│   └── VOICECLI/            # Command-line executable
│       └── main.swift
├── Tests/                    # Test files
│   ├── Unit/
│   ├── Mocks/
│   └── Fixtures/
└── VOICE/                    # Original Xcode project (still available)
    └── VOICE.xcodeproj/
```

## 🚀 Quick Start

### Build the Package

```bash
# From the workspace root
swift build

# Or use the build script
./Scripts/build.sh
```

### Run Tests

```bash
# Run all tests
swift test

# Or use the test script
./Scripts/test.sh

# Run tests in parallel
./Scripts/test.sh --parallel
```

### Run the CLI

```bash
# Run the command-line interface
swift run voice-cli
```

## 🔧 Available Commands

### Package Management

```bash
# Clean build artifacts
swift package clean

# Resolve dependencies
swift package resolve

# Update dependencies
swift package update

# Generate Xcode project from Package.swift
swift package generate-xcodeproj
```

### Building

```bash
# Debug build (default)
swift build

# Release build (optimized)
swift build -c release

# Build specific target
swift build --target VOICE
swift build --target VOICECLI
```

### Testing

```bash
# Run all tests
swift test

# Run tests in parallel
swift test --parallel

# Run specific test
swift test --filter ItemsListUseCaseTests

# Generate code coverage
swift test --enable-code-coverage
```

## 📦 Package Structure

### Products

- **VOICE** (library): The main framework containing all business logic
- **voice-cli** (executable): Command-line interface for testing

### Targets

- **VOICE**: Main library with domain, data, and infrastructure layers
- **VOICECLI**: CLI executable for command-line testing
- **VOICETests**: Test suite

### Platform Support

- iOS 17.0+
- macOS 14.0+

## 🎯 Working from Cursor

### Terminal Commands

You can now run these commands directly in Cursor's terminal:

```bash
# Navigate to workspace
cd /workspace

# Build the project
swift build

# Run tests
swift test

# Run the CLI
swift run voice-cli
```

### Integrated Development

1. **Syntax Highlighting**: Swift files have full syntax support
2. **Build Errors**: Run `swift build` to see compilation errors
3. **Test Feedback**: Run `swift test` to get immediate test results
4. **No Xcode Required**: Everything works from the command line

## 🔀 Dual System Support

This project now supports both SPM and Xcode:

### Use SPM when you want to:
- Build and test from Cursor/command line
- Work without Xcode
- Run unit tests quickly
- Test business logic layer
- Use in CI/CD pipelines

### Use Xcode when you want to:
- Run the iOS app in simulator
- Debug UI components
- Use Interface Builder
- Test the full app experience
- Work with SwiftUI previews

```bash
# Open in Xcode
open VOICE/VOICE.xcodeproj
```

## 🧪 Testing from Cursor

The test suite is fully functional from command line:

```bash
# Run all tests
swift test

# Run specific test class
swift test --filter ItemsListUseCaseTests

# Run with verbose output
swift test --verbose

# Run tests in parallel (faster)
swift test --parallel
```

### Test Coverage

```bash
# Generate coverage report
swift test --enable-code-coverage

# View coverage (requires additional tools)
xcrun llvm-cov show .build/debug/VOICEPackageTests.xctest/Contents/MacOS/VOICEPackageTests \
  -instr-profile=.build/debug/codecov/default.profdata
```

## 📝 Notes

### iOS UI Components

- SwiftUI views are included in the package but may have platform limitations
- For full UI testing, use Xcode with iOS Simulator
- The business logic layer (Domain, Data, Infrastructure) works perfectly from CLI

### Config Files

- The `Config.swift` file uses `Bundle.main` which is iOS-specific
- For CLI testing, mock configurations are used
- When running the iOS app, configurations work normally

### Assets

- iOS assets (Images, Colors) are excluded from SPM compilation
- These are only needed when running the full iOS app in Xcode
- All code-based functionality works without assets

## 🐛 Troubleshooting

### "swift: command not found"

Install Swift toolchain:
- macOS: `xcode-select --install`
- Linux: Follow [Swift.org installation guide](https://swift.org/download/)

### Build Errors

```bash
# Clean and rebuild
swift package clean
swift build
```

### Test Failures

```bash
# Check for missing imports
# Make sure all test files have: @testable import VOICE

# Run tests with verbose output
swift test --verbose
```

## 🎉 Benefits

1. **No Xcode Required**: Build and test entirely from Cursor
2. **Faster Iteration**: Quick compile times without Xcode overhead
3. **CI/CD Ready**: Easy integration with build systems
4. **Cross-Platform**: Same code works on macOS and Linux
5. **Better Testing**: Run tests instantly from command line
6. **Version Control**: Package.swift is cleaner than .xcodeproj

## 📚 Resources

- [Swift Package Manager Documentation](https://swift.org/package-manager/)
- [Building Swift Packages](https://developer.apple.com/documentation/packagedescription)
- [Testing in Swift Packages](https://developer.apple.com/documentation/xctest)

---

**Happy Coding! 🚀**

You can now develop, build, and test your Swift code entirely from Cursor without opening Xcode!

