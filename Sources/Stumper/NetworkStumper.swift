//
//  NetworkStumper.swift
//  Stumper
//
//  Copyright © Tim Brooks. All rights reserved.
//

import Foundation

/// Specialized Logger for Network requests and responses
///
/// The NetworkLogger uses specialized formatting logic unique to Network requests and responses
/// that is used to show metadata and content related to Network operations.
struct NetworkStumper {
    
    /// Identifies different levels of Network logging based on level of detail logged.
    enum LogType: String {
            
        /// Logs response lines.
        case basic

        /// Logs response lines and their respective headers.
        case headers

        /// Logs response lines and their respective headers and bodies (if present).
        case body
    }
    
    // MARK: - Properties
    private static var redactedHeaders = [String]()
    private static let stumper = Stumper.shared
    
    // MARK: - Public methods
    /// Logs a Request / Response pair to the Logger instance
    ///
    /// - Parameters:
    ///     - response: The HTTPURLResponse
    ///     - responseBody: Optional Data payload from the response
    ///     - elapsed: Request Duration - defaults to .zero
    ///     - type: Network log type - defaults to .basic
    ///     - level: Log level - defaults to .info
    static func log(response: HTTPURLResponse,
                    responseBody: Data?,
                    elapsed: Duration = .zero,
                    type: LogType = .basic,
                    level: Stumper.StumpLevel = .info) {

        // Logging lambda
        let log = { (message: String) in
            stumper.stump(message, level: level)
        }
                
        // Log start
        log("URLResponse Info")
        let showHeaders = (type == .body) || (type == .headers)
        
        // Body
        let contentLength = responseBody?.count ?? -1
        var bodyInfo: String = "unknown-length"
        if contentLength != -1 {
            bodyInfo = "\(contentLength)-byte"
        }
        
        // Start Body
        let bodyMessage = 
        """
        <--- \(response.statusCode) \(response.url!.absoluteString) (elapsed: \(elapsed), \(bodyInfo) body)
        """
        log(bodyMessage)
        
        // Body headers
        if showHeaders {
            
            let headers = (response.allHeaderFields as? [String: Any]) ?? [:]
            headers.keys.forEach { key in
                if let value = response.value(forHTTPHeaderField: key) {
                    logHeader(key: key, value: value, level: level)
                }
            }
        }
        
        // Body
        if type == .body {
            
            if let data = responseBody, let bodyString = String(data: data, encoding: .utf8) {
                log("Request Body")
                let message =
                """
                \(bodyString)
                """
                
                log(message)
            } else {
                log("Unable to parse body")
            }
        }
        
        if type != .body {
            log("<-- END HTTP")
        } else {
            log("<-- END HTTP (\(contentLength)-byte body)")
        }
    }

    /// Logs a Request to the Logger instance
    ///
    /// - Parameters:
    ///     - request: The URLRequest
    ///     - elapsed: Request Duration - defaults to .zero
    ///     - level: Log level - defaults to .info
    static func log(request: URLRequest,
                    elapsed: Duration = .zero,
                    level: Stumper.StumpLevel = .info) {

        // Logging lambda
        let log = { (message: String) in
            stumper.stump(message, level: level)
        }

        // Log start
        log("URLRequest Info")

        // Start message
        let requestMethod = request.httpMethod ?? "UNKNOWN"
        let message =
        """
        --> \(requestMethod) \(request.url?.absoluteString ?? "")
        """
                
        log(message)
        
        // Headers
        let headers = (request.allHTTPHeaderFields ?? [:])
        let headerKeys = headers.map { key, _ in
            key.lowercased()
        }
        
        // Request body
        let requestBody = request.httpBody

        let contentLengthKey = "Content-Length"
        
        if let body = requestBody {
            if !headerKeys.contains(contentLengthKey.lowercased()) {
                log("\(contentLengthKey): \(body.count)")
            }
        }
        
        // Request headers
        log("Request Headers")
        for (key, value) in headers {
            logHeader(key: key, value: value, level: level)
        }
                
        if let data = requestBody {

            if let bodyString = String(data: data, encoding: .utf8) {
                log("Request Body")
                let message =
                """
                \(bodyString)
                """
                
                log(message)
            }
            
            log("--> END \(requestMethod) (\(data.count)-byte body)")
        } else {
            log("--> END \(requestMethod)")
        }
    }

    /// Private helper to wrap a Logger.log call
    private static func logHeader(key: String, value: String, level: Stumper.StumpLevel) {
        let val = redactedHeaders.contains(key.lowercased()) ? "██" : value
        self.stumper.stump("\(key): \(val)", level: level)
    }
    
    /// Allows for redaction (removal) of a header
    ///
    /// Header redaction might be desirable in cases of sensitive
    /// or private header keys you don't want to appear in logs

    /// - Parameter header: Header key to redact from log
    public static func redactHeader(_ header: String) {
        self.redactedHeaders.append(header)
    }
}
