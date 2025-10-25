# 🚀 Cursor Quick Start Guide

Your VOICE project is now set up for development directly in Cursor!

## ⚡ Quick Commands

Run these directly in Cursor's terminal:

```bash
# Build the project
swift build

# Run tests
swift test

# Run the CLI demo
swift run voice-cli

# Clean build
swift package clean
```

## 📁 What Changed?

1. ✅ Added `Package.swift` - SPM manifest
2. ✅ Created `Sources/VOICE/` - Main library code
3. ✅ Created `Sources/VOICECLI/` - Command-line executable
4. ✅ Updated `Tests/` - Added `@testable import VOICE`
5. ✅ Updated `Scripts/` - Now use SPM commands
6. ✅ Original Xcode project still works in `VOICE/VOICE.xcodeproj`

## 🎯 Common Tasks

### Build the Code

```bash
cd /workspace
swift build
```

### Run All Tests

```bash
swift test
```

### Run Specific Test

```bash
swift test --filter ItemsListUseCaseTests
```

### Test with Coverage

```bash
swift test --enable-code-coverage
```

### Run in Parallel (Faster!)

```bash
swift test --parallel
```

### Clean Build Artifacts

```bash
swift package clean
```

## 📊 Project Structure

```
/workspace/
├── Package.swift              # SPM manifest (NEW!)
├── Sources/                   # Source code (NEW!)
│   ├── VOICE/                # Main library
│   └── VOICECLI/             # CLI executable
├── Tests/                    # Tests (updated with imports)
├── Scripts/                  # Build scripts (updated for SPM)
├── VOICE/                    # Original Xcode project (still works)
│   └── VOICE.xcodeproj/
└── SPM_GUIDE.md              # Detailed SPM guide (NEW!)
```

## 🔄 Dual Workflow

### Use Cursor/CLI when you:
- Want quick builds and tests
- Don't need UI preview
- Work on business logic
- Test repositories, use cases, entities
- Run CI/CD-like builds

### Use Xcode when you:
- Need iOS Simulator
- Want SwiftUI previews
- Debug UI issues
- Test the full app
- Need visual tools

## 💡 Tips

1. **Fast Feedback Loop**
   ```bash
   swift test --filter YourTestClass
   ```

2. **Parallel Testing** (much faster)
   ```bash
   swift test --parallel
   ```

3. **Verbose Output** (see what's happening)
   ```bash
   swift test --verbose
   ```

4. **Release Build** (optimized)
   ```bash
   swift build -c release
   ```

5. **Generate Xcode Project from Package**
   ```bash
   swift package generate-xcodeproj
   ```

## 🧪 Testing Strategy

The test suite is fully functional from command line:

- ✅ Unit tests for use cases
- ✅ Contract tests for JSON parsing
- ✅ Mock implementations
- ✅ All tests have proper imports

```bash
# Quick test run
swift test

# Watch for changes and re-run (using other tools)
# You can use entr or watchexec:
find Tests Sources -name "*.swift" | entr -c swift test
```

## 🐛 Troubleshooting

### "swift: command not found"

Install Swift:
```bash
xcode-select --install
```

Or download from: https://swift.org/download/

### Build Errors

```bash
# Clean and rebuild
swift package clean
swift build
```

### Tests Not Found

Make sure all test files have:
```swift
@testable import VOICE
```

### Missing Dependencies

```bash
swift package resolve
swift package update
```

## 📚 Learn More

- [SPM_GUIDE.md](./SPM_GUIDE.md) - Complete SPM documentation
- [README.md](./README.md) - Project overview
- [Docs/ARCHITECTURE.md](./Docs/ARCHITECTURE.md) - Architecture details

## 🎉 What You Can Do Now

1. ✅ Build and test without opening Xcode
2. ✅ Run tests in seconds, not minutes
3. ✅ Use Cursor's terminal for everything
4. ✅ Quick iteration on business logic
5. ✅ Easy CI/CD integration
6. ✅ Still have Xcode when you need it

---

**Happy coding in Cursor! 🚀**

For questions, see [SPM_GUIDE.md](./SPM_GUIDE.md) or the [Swift Package Manager docs](https://swift.org/package-manager/).

