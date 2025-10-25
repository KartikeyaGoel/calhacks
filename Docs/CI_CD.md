# CI/CD Documentation

## Overview

The VOICE project uses GitHub Actions for continuous integration and deployment. All workflows are defined in `.github/workflows/`.

## Workflows

### 1. CI Workflow (`ci.yml`)

**Triggers**: Push to main/develop, Pull requests, Manual dispatch

**Jobs**:

#### build-and-test
- Runs on: macOS 13
- Matrix: VOICE-Dev scheme
- Steps:
  1. Checkout code
  2. Setup Xcode 15.0
  3. Cache DerivedData for faster builds
  4. Clean build folder
  5. Build project
  6. Run tests with code coverage
  7. Upload test results and coverage reports

**Environment Variables**:
- `XCODE_VERSION`: 15.0
- `IOS_SIMULATOR`: iPhone 15
- `IOS_VERSION`: 17.0

#### lint
- Runs SwiftLint to check code quality
- Uses `.swiftlint.yml` configuration
- Reports issues in GitHub Actions format

#### build-release
- Only runs on main branch
- Builds production archive
- Uploads archive as artifact (30-day retention)

### 2. PR Checks Workflow (`pr-checks.yml`)

**Triggers**: Pull request opened, synchronized, reopened

**Jobs**:

#### pr-validation
- Validates commit messages follow conventional commits
- Checks for merge conflicts
- Checks for large files (>1MB)

#### code-quality
- Counts lines of code
- Checks for excessive TODOs
- Warns about print statements

### 3. Release Workflow (`release.yml`)

**Triggers**: Tag push (v*), Manual dispatch

**Jobs**:

#### create-release
- Updates version number in Info.plist
- Builds archives for all environments (Dev, Staging, Prod)
- Generates release notes from git log
- Creates GitHub Release with archives

## Local CI Simulation

### Run build locally
```bash
./Scripts/build.sh VOICE-Dev
```

### Run tests locally
```bash
./Scripts/test.sh VOICE-Dev
```

### Run SwiftLint locally
```bash
brew install swiftlint
swiftlint lint
```

## Artifacts

### Test Results
- **Retention**: 7 days
- **Location**: Actions → Workflow run → Artifacts
- **Format**: .xcresult bundle

### Coverage Reports
- **Retention**: 7 days
- **Format**: JSON
- **View**: Download and open in Xcode

### Archives
- **Retention**: 30 days (release: indefinite)
- **Format**: .xcarchive
- **Use**: For distribution or TestFlight

## Status Badges

Add to README.md:

```markdown
![CI](https://github.com/username/voice/workflows/CI/badge.svg)
![PR Checks](https://github.com/username/voice/workflows/PR%20Checks/badge.svg)
```

## Branch Protection

Recommended settings for main branch:

- ✅ Require pull request reviews (1 approval)
- ✅ Require status checks to pass before merging
  - build-and-test
  - pr-validation
  - code-quality
- ✅ Require branches to be up to date before merging
- ✅ Require linear history
- ✅ Include administrators

## Secrets Configuration

No secrets required for basic CI. For production deployment:

1. Go to Repository Settings → Secrets → Actions
2. Add secrets:
   - `APPLE_ID`: Apple Developer account email
   - `APP_STORE_CONNECT_API_KEY`: API key content
   - `CERTIFICATE_PASSWORD`: Certificate password
   - `PROVISIONING_PROFILE`: Base64 encoded profile

## Caching Strategy

### DerivedData Cache
- **Key**: OS + project file hash
- **Benefits**: Faster builds (30-50% speedup)
- **Size**: ~2-5GB
- **Invalidation**: When project.pbxproj changes

### CocoaPods Cache (if used)
- **Key**: OS + Podfile.lock hash
- **Path**: Pods/

## Failure Notifications

Configure notifications:
1. Repository Settings → Notifications
2. Enable "Actions" notifications
3. Choose notification method (email, Slack, etc.)

## Matrix Builds

To test multiple Xcode versions:

```yaml
strategy:
  matrix:
    xcode: ['14.3', '15.0']
    scheme: ['VOICE-Dev', 'VOICE-Staging']
```

## Performance Optimization

### Build Time Optimization
- Use incremental builds
- Cache DerivedData
- Parallelize test execution
- Use minimal simulator

### Cost Optimization
- Free tier: 2,000 minutes/month
- macOS multiplier: 10x (200 actual minutes)
- Optimize by:
  - Running tests only on PRs
  - Using matrix selectively
  - Caching dependencies

## Debugging CI Failures

### View Logs
```bash
# Download and view
gh run view <run-id> --log
```

### Run Job Locally
```bash
# Install act
brew install act

# Run workflow
act -j build-and-test
```

### Common Issues

1. **Xcode version mismatch**
   - Solution: Update `XCODE_VERSION` in ci.yml

2. **Simulator not available**
   - Solution: Check `xcrun simctl list devices`

3. **Code signing errors**
   - Solution: Ensure `CODE_SIGNING_REQUIRED=NO` for CI

4. **Test timeouts**
   - Solution: Increase timeout or optimize tests

## Best Practices

1. **Keep builds fast** (<10 minutes)
2. **Fail fast** (run cheap checks first)
3. **Cache dependencies** aggressively
4. **Use matrix builds** sparingly
5. **Monitor usage** to avoid overage charges
6. **Keep artifacts small** (delete old ones)
7. **Version pin actions** for reproducibility

## Maintenance

### Weekly
- Review failed builds
- Check artifact storage usage
- Update dependencies

### Monthly
- Update Xcode version if needed
- Review cache effectiveness
- Clean up old workflows

### Quarterly
- Update GitHub Actions versions
- Review and optimize build times
- Update documentation

## Integration with External Services

### Slack Notifications
```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### TestFlight Distribution
```yaml
- name: Upload to TestFlight
  uses: apple-actions/upload-testflight-build@v1
  with:
    app-path: build/VOICE.ipa
```

### Code Coverage Reporting
```yaml
- name: Upload to Codecov
  uses: codecov/codecov-action@v3
  with:
    file: coverage.json
```

## Troubleshooting

### Problem: Tests fail locally but pass in CI
- Check Xcode versions match
- Verify environment variables
- Clean DerivedData locally

### Problem: Build succeeds but release fails
- Check code signing configuration
- Verify provisioning profiles
- Review archive settings

### Problem: Slow builds
- Enable verbose logging
- Profile with Xcode Instruments
- Check cache hit rate

## Resources

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Xcode Cloud Migration Guide](https://developer.apple.com/xcode-cloud/)
- [fastlane Integration](https://fastlane.tools)

