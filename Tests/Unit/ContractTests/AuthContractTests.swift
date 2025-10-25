//
//  AuthContractTests.swift
//  VOICE Tests
//
//  Contract tests for Auth API responses
//

import XCTest

final class AuthContractTests: XCTestCase {
    func testDecodeAuthLoginResponse() throws {
        let json = loadFixture("auth_login_response")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let session = try decoder.decode(AuthSession.self, from: json)
        
        XCTAssertEqual(session.user.id, "user_123")
        XCTAssertEqual(session.user.email, "test@example.com")
        XCTAssertEqual(session.user.name, "Test User")
        XCTAssertEqual(session.user.avatarURL?.absoluteString, "https://example.com/avatar.jpg")
        XCTAssertEqual(session.accessToken, "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")
        XCTAssertEqual(session.refreshToken, "refresh_token_abc123")
    }
    
    func testDecodeUserProfileResponse() throws {
        let json = loadFixture("user_profile_response")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let user = try decoder.decode(User.self, from: json)
        
        XCTAssertEqual(user.id, "user_456")
        XCTAssertEqual(user.email, "profile@example.com")
        XCTAssertEqual(user.name, "Profile User")
        XCTAssertNil(user.avatarURL)
    }
}

// MARK: - Helpers

extension XCTestCase {
    func loadFixture(_ name: String, extension ext: String = "json") -> Data {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: name, withExtension: ext),
              let data = try? Data(contentsOf: url) else {
            XCTFail("Failed to load fixture: \(name).\(ext)")
            return Data()
        }
        return data
    }
}

