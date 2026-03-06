import Foundation
import TelegramReporter

struct LiveDemoReporterClient: DemoReporterClient {
    typealias StartReportHandler = @Sendable (String, String, String) async throws -> Void
    typealias CustomEventHandler = @Sendable (String, String, String, [String: String], String) async throws -> Void
    typealias FeedbackHandler = @Sendable (String, String, String, String, FeedbackImage?) async throws -> Void

    private let startReportHandler: StartReportHandler
    private let customEventHandler: CustomEventHandler
    private let feedbackHandler: FeedbackHandler

    init(
        startReportHandler: @escaping StartReportHandler = { token, chatID, additional in
            await TelegramReporter.startLogReport(
                token: token,
                chatID: chatID,
                additional: additional,
                ignoreFirstLaunch: true
            )
        },
        customEventHandler: @escaping CustomEventHandler = { token, chatID, title, details, additional in
            await TelegramReporter.sendCustomEvent(
                token: token,
                chatID: chatID,
                title: title,
                details: details,
                additional: additional
            )
        },
        feedbackHandler: @escaping FeedbackHandler = { token, chatID, additional, text, image in
            try await TelegramReporter.sendFeedback(
                token: token,
                chatID: chatID,
                additional: additional,
                text: text,
                feedbackImage: image
            )
        }
    ) {
        self.startReportHandler = startReportHandler
        self.customEventHandler = customEventHandler
        self.feedbackHandler = feedbackHandler
    }

    func sendStartReport(token: String, chatID: String, additional: String) async throws {
        try await startReportHandler(token, chatID, additional)
    }

    func sendCustomEvent(token: String, chatID: String, title: String, details: [String: String], additional: String) async throws {
        try await customEventHandler(token, chatID, title, details, additional)
    }

    func sendFeedback(token: String, chatID: String, additional: String, text: String, image: FeedbackImage?) async throws {
        try await feedbackHandler(token, chatID, additional, text, image)
    }
}
