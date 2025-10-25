//
//  Logger.swift
//  VOICE
//
//  Logging service for debugging and monitoring
//

import Foundation
import os.log

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

protocol Logger {
    func log(_ message: String, level: LogLevel, module: String, file: String, function: String, line: Int)
}

extension Logger {
    func debug(_ message: String, module: String = "App", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, module: module, file: file, function: function, line: line)
    }
    
    func info(_ message: String, module: String = "App", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, module: module, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, module: String = "App", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, module: module, file: file, function: function, line: line)
    }
    
    func error(_ message: String, module: String = "App", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, module: module, file: file, function: function, line: line)
    }
}

final class DefaultLogger: Logger {
    private let osLog = OSLog(subsystem: "com.voice.app", category: "general")
    
    func log(_ message: String, level: LogLevel, module: String, file: String, function: String, line: Int) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(timestamp)][\(level.rawValue)][\(module)][\(fileName):\(line)] \(message)"
        
        let osLogType: OSLogType
        switch level {
        case .debug:
            osLogType = .debug
        case .info:
            osLogType = .info
        case .warning:
            osLogType = .default
        case .error:
            osLogType = .error
        }
        
        os_log("%{public}@", log: osLog, type: osLogType, logMessage)
        
        // Also print to console in debug builds
        #if DEBUG
        print(logMessage)
        #endif
    }
}

