//
//  TelegramReporterEvent.swift
//

import Foundation

enum TelegramReporterEvent {
    case firstLaunch
    case appDidBecomeActive
    case custom(title: String, details: [String: String] = [:])
}
