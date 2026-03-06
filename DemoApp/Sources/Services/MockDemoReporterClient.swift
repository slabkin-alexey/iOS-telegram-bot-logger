import Foundation
import TelegramReporter

struct MockDemoReporterClient: DemoReporterClient {
    func sendStartReport(token: String, chatID: String, additional: String) async throws {
        try await simulateNetwork(token: token)
    }

    func sendCustomEvent(token: String, chatID: String, title: String, details: [String: String], additional: String) async throws {
        try await simulateNetwork(token: token)
    }

    func sendFeedback(token: String, chatID: String, additional: String, text: String, image: FeedbackImage?) async throws {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw TelegramReporter.FeedbackError.emptyMessage
        }
        try await simulateNetwork(token: token)
    }

    private func simulateNetwork(token: String) async throws {
        try await Task.sleep(for: .milliseconds(20))
        if token.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "fail" {
            throw DemoReporterClientError.simulatedFailure
        }
    }
}
