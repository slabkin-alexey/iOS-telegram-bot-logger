//
//  TelegramReporterEvent.swift
//

import Foundation

enum TelegramReporterEvent {
    case firstLaunch
    case appDidBecomeActive
    case custom(title: String, details: [String: String] = [:])
    case feedback(text: String, image: FeedbackImage? = nil)

    var logName: String {
        switch self {
        case .firstLaunch:
            return "firstLaunch"
        case .appDidBecomeActive:
            return "appDidBecomeActive"
        case let .custom(title, details):
            return "custom(title: \(title), detailsCount: \(details.count))"
        case let .feedback(text, image):
            return "feedback(textLength: \(text.count), hasImage: \(image != nil))"
        }
    }
}
