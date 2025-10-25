# Environment Configuration Setup

This guide explains how to configure multiple environments (Dev, Staging, Prod) in the VOICE iOS app.

## Overview

The app uses `.xcconfig` files to manage environment-specific settings. Each environment has its own API base URL, bundle identifier, and display name.

## Configuration Files

Located in `/VOICE/Config/`:
- `Base.xcconfig` - Shared settings across all environments
- `Dev.xcconfig` - Development environment
- `Staging.xcconfig` - Staging environment
- `Prod.xcconfig` - Production environment

## Xcode Project Setup

### Step 1: Link xcconfig Files to Project

1. Open `VOICE.xcodeproj` in Xcode
2. Select the project in the Project Navigator
3. Select the "Info" tab
4. Under "Configurations", expand "Debug" and "Release"
5. For each configuration:
   - **Debug**: Set to `Dev.xcconfig`
   - **Release**: Set to `Prod.xcconfig`

### Step 2: Configure Info.plist

1. Select the VOICE target
2. Go to "Build Settings"
3. Search for "Info.plist File"
4. Set the path to: `VOICE/Info.plist`
5. Search for "Generate Info.plist File"
6. Set to **NO** (we're using a custom Info.plist)

### Step 3: Create Schemes

You need to create three schemes for different environments:

#### VOICE-Dev Scheme

1. Go to **Product → Scheme → Manage Schemes**
2. Click **+** to add a new scheme
3. Name it: `VOICE-Dev`
4. Select the VOICE target
5. Click **Edit**
6. For each action (Run, Test, Profile, Analyze, Archive):
   - Set "Build Configuration" to use `Debug` with `Dev.xcconfig`

#### VOICE-Staging Scheme

1. Create a new scheme named `VOICE-Staging`
2. Set all actions to use `Debug` configuration
3. Later, link to `Staging.xcconfig` in project settings

#### VOICE-Prod Scheme

1. Create a new scheme named `VOICE-Prod`
2. Set all actions to use `Release` configuration
3. This will use `Prod.xcconfig` automatically

### Alternative: Using Configuration Files in Target Build Settings

For more granular control per scheme:

1. Go to Project Settings → Info tab
2. Under Configurations, create new configurations:
   - Duplicate "Debug" → Name it "Debug-Staging"
   - Duplicate "Release" → Name it "Release-Prod"
3. Assign xcconfig files:
   - Debug → Dev.xcconfig
   - Debug-Staging → Staging.xcconfig
   - Release → Prod.xcconfig
4. Update schemes to use the appropriate configuration

## Environment Variables

Each xcconfig file defines these variables (accessible via Info.plist):

| Variable | Description | Example |
|----------|-------------|---------|
| `API_BASE_URL` | Backend API base URL | `https://dev.api.voice-app.com` |
| `BUILD_ENV` | Environment identifier | `DEV`, `STAGING`, `PROD` |
| `API_TIMEOUT` | Network request timeout (seconds) | `30` |
| `FEATURE_FLAGS_BOOTSTRAP_URL` | Feature flags endpoint | `https://dev.api.voice-app.com/feature-flags` |
| `PRODUCT_BUNDLE_IDENTIFIER` | App bundle ID | `com.voice.app.dev` |
| `PRODUCT_DISPLAY_NAME` | App display name | `VOICE DEV` |

## Accessing Configuration in Code

The `DefaultConfig` class reads these values from `Bundle.main.infoDictionary`:

```swift
let config: Config = DefaultConfig()
print("API Base URL: \(config.apiBaseURL)")
print("Environment: \(config.buildEnv)")
```

## Verification

After setup, verify the configuration is working:

1. Build the app with the Dev scheme
2. Check the app icon on the simulator/device
3. The display name should show "VOICE DEV"
4. Check the bundle identifier in the app's settings

## Troubleshooting

### "API_BASE_URL not configured" error

- Ensure Info.plist exists at `VOICE/Info.plist`
- Verify "Generate Info.plist File" is set to NO
- Check that xcconfig files are properly linked in project settings

### Wrong environment values at runtime

- Clean build folder: **Product → Clean Build Folder** (⇧⌘K)
- Rebuild with the correct scheme
- Verify the scheme is using the correct configuration

### Xcode not recognizing xcconfig files

- Ensure files are added to the project (not just the file system)
- Drag the Config folder into Xcode project navigator
- Do not add to any target (they're build configuration files)

## CI/CD Configuration

For continuous integration, pass the scheme name:

```bash
xcodebuild -scheme VOICE-Dev -destination 'platform=iOS Simulator,name=iPhone 15'
```

See `/Scripts/build.sh` for automated build scripts.

