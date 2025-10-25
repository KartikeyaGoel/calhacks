//
//  Config.swift
//  VOICE
//
//  Configuration protocol and service for environment-based settings
//

import Foundation

enum BuildEnv: String {
    case dev = "DEV"
    case staging = "STAGING"
    case prod = "PROD"
}

protocol Config {
    var apiBaseURL: URL { get }
    var buildEnv: BuildEnv { get }
    var apiTimeout: TimeInterval { get }
    var featureFlagsURL: URL? { get }
}

// Default implementation reading from Info.plist (populated via xcconfig)
final class DefaultConfig: Config {
    var apiBaseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["API_BASE_URL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("API_BASE_URL not configured in Info.plist")
        }
        return url
    }
    
    var buildEnv: BuildEnv {
        guard let envString = Bundle.main.infoDictionary?["BUILD_ENV"] as? String,
              let env = BuildEnv(rawValue: envString) else {
            return .dev // fallback
        }
        return env
    }
    
    var apiTimeout: TimeInterval {
        if let timeoutString = Bundle.main.infoDictionary?["API_TIMEOUT"] as? String,
           let timeout = TimeInterval(timeoutString) {
            return timeout
        }
        return 30.0 // default
    }
    
    var featureFlagsURL: URL? {
        guard let urlString = Bundle.main.infoDictionary?["FEATURE_FLAGS_BOOTSTRAP_URL"] as? String else {
            return nil
        }
        return URL(string: urlString)
    }
}


