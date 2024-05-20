//
//  Logger.swift
//  Stumper
//
//  Copyright © Tim Brooks. All rights reserved.
//

import Foundation
import OSLog

extension Logger {

    // MARK: - Properties
    /// A static, default internal subsystem for OS Logging
    internal static var subsystem = Bundle.main.bundleIdentifier!
    
    /// The standard static default Logger type
    public static var `default` = Logger(subsystem: subsystem, category: "default")

    /// A static default Logger type for Network logging
    public static var network: Logger = Logger(subsystem: subsystem, category: "network")
}

public struct Stumper {
    
    // Set this to dictate logging output level
    static var stumpLevel: StumpLevel = .trace
    
    public enum StumpLevel: Int, CaseIterable {
        
        case trace
        case debug
        case info
        case notice
        case warning
        case error
        case fault

        private var icons: [String] {
            ["💜", "💚", "💙", "🖤", "💛", "🩷", "❤️"]
        }

        public var icon: String {
            // Verify no off-by-one
            precondition(self.icons.count == StumpLevel.allCases.count)
            return String(self.icons[self.rawValue])
        }
            
        public var name: String {
            switch self {
            case .debug:
                return "Debug"
            case .info:
                return "Info"
            case .error:
                return "Error"
            case .fault:
                return "Fault"
            case .notice:
                return "Notice"
            case .warning:
                return "Warning"
            case .trace:
                return "Trace"
            }
        }
        
        public var initial: String {
            
            guard let char = self.name.first else { return "" }
            return (String(char).localizedCapitalized)
        }
    }
    
    // MARK: - Properties
    public var defaultLogLevel: Stumper.StumpLevel = .debug
    public var prefix: String
    public var separator: String
    public var showLevel: Bool
    public var useIcons: Bool
    public var brackets: String
    
    public static let shared = Stumper()
    
    // MARK: - Initializers
    public init(prefix: String = Bundle.main.bundleIdentifier!,
         separator: String = ":",
         brackets: String = "[]",
         useIcons: Bool = false,
         showLevel: Bool = true) {
        
        precondition(brackets.count == 2, "There must be 2 and only 2 brackets")
        
        self.prefix = prefix
        self.separator = separator
        self.showLevel = showLevel
        self.brackets = brackets
        self.useIcons = useIcons
    }
    
    // MARK: - Convenience Logs
    public func stump(_ message: String, level: Stumper.StumpLevel) {
        switch level{
        case .trace:
            trace(message)
        case .debug:
            debug(message)
        case .info:
            info(message)
        case .notice:
            notice(message)
        case .warning:
            warning(message)
        case .error:
            error(message)
        case .fault:
            fault(message)
        }
    }
    
    public func debug(_ message: String,
               prefix: String = "",
               separator: String = "",
               logger: Logger = Logger.default) {
        
        guard shouldLog(currentLevel: .debug) else { return }
        
        let message = buildMessage(prefix: prefix, 
                                   separator: separator,
                                   message: message,
                                   level: .debug)
        logger.debug("\(message)")
    }
    
    public func error(_ message: String,
               prefix: String = "",
               separator: String = "",
               logger: Logger = Logger.default) {
        
        guard shouldLog(currentLevel: .error) else { return }

        let message = buildMessage(prefix: prefix,
                                   separator: separator,
                                   message: message,
                                   level: .error)
        logger.error("\(message)")
    }
    
    public func fault(_ message: String,
               prefix: String = "",
               separator: String = "",
               logger: Logger = Logger.default) {
        
        guard shouldLog(currentLevel: .fault) else { return }

        let message = buildMessage(prefix: prefix,
                                   separator: separator,
                                   message: message,
                                   level: .fault)
        logger.fault("\(message)")
    }
    
    public func info(_ message: String,
              prefix: String = "",
              separator: String = "",
              logger: Logger = Logger.default) {
        
        guard shouldLog(currentLevel: .info) else { return }

        let message = buildMessage(prefix: prefix,
                                   separator: separator,
                                   message: message,
                                   level: .info)
        logger.info("\(message)")
    }
    
    public func notice(_ message: String,
                prefix: String = "",
                separator: String = "",
                logger: Logger = Logger.default) {
        
        guard shouldLog(currentLevel: .notice) else { return }

        let message = buildMessage(prefix: prefix,
                                   separator: separator,
                                   message: message,
                                   level: .notice)
        logger.notice("\(message)")
    }
    
    public func trace(_ message: String,
               prefix: String = "",
               separator: String = "",
               logger: Logger = Logger.default) {
        
        guard shouldLog(currentLevel: .trace) else { return }

        let message = buildMessage(prefix: prefix,
                                   separator: separator,
                                   message: message,
                                   level: .trace)
        logger.trace("\(message)")
    }
        
    public func warning(_ message: String,
                 prefix: String = "",
                 separator: String = "",
                 logger: Logger = Logger.default) {
        
        guard shouldLog(currentLevel: .warning) else { return }

        let message = buildMessage(prefix: prefix,
                                   separator: separator,
                                   message: message,
                                   level: .warning)
        logger.warning("\(message)")
    }
    
    private func shouldLog(currentLevel: Stumper.StumpLevel) -> Bool {
        return Self.stumpLevel.rawValue <= currentLevel.rawValue
    }
    
    // MARK: - Helpers
    private func buildPrefix(prefix: String, separator: String) -> String {
        "\(prefix.isEmpty ? self.prefix : prefix)\(separator.isEmpty ? self.separator : separator) "
    }
    
    private func buildLevelSlug(level: StumpLevel) -> String {
        
        var result = self.brackets
        let char = self.useIcons ? level.icon : level.initial
        result.insert(char.first!, at: result.index(after: result.startIndex))
        result += " "
        
        return result
    }
    
    private func buildMessage(prefix: String,
                              separator: String,
                              message: String,
                              level: Stumper.StumpLevel) -> String {
        
        let levelFlag = self.showLevel ? buildLevelSlug(level: level) : ""
        return "\(levelFlag)\(buildPrefix(prefix: prefix, separator: separator))\(message)"
    }
}
