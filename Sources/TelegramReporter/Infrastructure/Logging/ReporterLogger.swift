//
//  ReporterLogger.swift
//

import Foundation

enum ReporterLogger {
    static func log(_ scope: String, _ message: String) {
        let timestamp = String(format: "%.3f", Date().timeIntervalSince1970)
        print("[TelegramReporter][\(timestamp)][\(scope)] \(message)")
    }
}
