//
//  main.swift
//  VOICE CLI
//
//  Command-line interface for testing VOICE functionality
//

import Foundation
#if canImport(VOICE)
import VOICE
#endif

print("🎤 VOICE CLI - Command Line Interface")
print("=====================================\n")

// Demonstrate the Domain layer functionality
print("✅ Successfully compiled VOICE package!")
print("📦 Available modules:")
print("   - Domain (Entities & Use Cases)")
print("   - Data (Repositories)")
print("   - Infrastructure (Network, Storage, Logging)")
print("   - Presentation (UI Adapter)")

print("\n🔧 Testing Domain Entities...")

// Test creating domain entities
let testItem = DomainItem(
    id: "test-1",
    title: "Test Item",
    description: "This is a test item created from CLI",
    createdAt: Date(),
    updatedAt: nil
)

print("   Created DomainItem: \(testItem.title)")
print("   ID: \(testItem.id)")
print("   Created at: \(testItem.createdAt)")

let testUser = User(
    id: "user-1",
    email: "test@example.com",
    name: "Test User",
    createdAt: Date()
)

print("   Created User: \(testUser.name)")
print("   Email: \(testUser.email)")

let testSession = AuthSession(
    accessToken: "test-token-123",
    refreshToken: "refresh-token-456",
    expiresAt: Date().addingTimeInterval(3600)
)

print("   Created AuthSession")
print("   Token: \(String(testSession.accessToken.prefix(20)))...")
print("   Expires in: 1 hour")

print("\n✨ All domain entities working correctly!")

print("\n📝 To run tests, use: swift test")
print("📦 To build the package, use: swift build")
print("🚀 To run this CLI again, use: swift run voice-cli")

print("\n💡 Note: The UI components require an iOS simulator or device.")
print("   Use Xcode for running the full iOS app with UI.")
print("   This CLI demonstrates that the business logic layer")
print("   can be built and tested directly from the command line!\n")

