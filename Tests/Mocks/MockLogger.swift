//
//  MockLogger.swift
//  VOICE Tests
//
//  Mock logger for testing
//

import Foundation
@testable import VOICE

final class MockLogger: Logger {
    var logs: [(message: String, level: LogLevel, module: String)] = []
    
    func log(_ message: String, level: LogLevel, module: String, file: String, function: String, line: Int) {
        logs.append((message, level, module))
    }
    
    func reset() {
        logs.removeAll()
    }
}

