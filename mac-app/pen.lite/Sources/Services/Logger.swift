import Foundation
import os.log

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

struct Logger {
    private static let subsystem = "com.penai.penlite"
    private static let osLog = OSLog(subsystem: subsystem, category: "App")
    
    private static var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    private static func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        let fileName = (file as NSString).lastPathComponent
        let className = (fileName as NSString).deletingPathExtension
        let formattedMessage = "[\(className)] \(message)"
        
        #if DEBUG
        print("[\(level.rawValue)] \(formattedMessage)")
        #endif
        
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
        
        os_log("%{public}@", log: osLog, type: osLogType, formattedMessage)
    }
}
