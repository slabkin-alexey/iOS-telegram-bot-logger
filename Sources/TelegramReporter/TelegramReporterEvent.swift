//
//  TelegramReporterEvent.swift
//

import Foundation

enum TelegramReporterEvent {
    case firstLaunch
    case appDidBecomeActive
    case custom(title: String, details: [String: String] = [:])

    var logName: String {
        switch self {
        case .firstLaunch:
            return "firstLaunch"
        case .appDidBecomeActive:
            return "appDidBecomeActive"
        case let .custom(title, details):
            return "custom(title: \(title), detailsCount: \(details.count))"
        }
    }
}
