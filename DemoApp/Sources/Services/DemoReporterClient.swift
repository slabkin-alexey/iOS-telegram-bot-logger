import Foundation
import TelegramReporter

protocol DemoReporterClient: Sendable {
    func sendStartReport(token: String, chatID: String, additional: String) async throws
    func sendCustomEvent(token: String, chatID: String, title: String, details: [String: String], additional: String) async throws
    func sendFeedback(token: String, chatID: String, additional: String, text: String, image: FeedbackImage?) async throws
}
