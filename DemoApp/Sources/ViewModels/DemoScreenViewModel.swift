import Foundation
import Observation
import TelegramReporter

@MainActor
@Observable
final class DemoScreenViewModel {
    var token = "mock-token"
    var chatID = "mock-chat"
    var additional = "Demo"
    var customTitle = L10n.tr("custom.default_title")
    var feedbackText = ""
    private(set) var hasFeedbackImage = false
    private(set) var isSending = false
    private(set) var statusMessage = L10n.tr("status.ready")
    private(set) var isError = false

    private var feedbackImage: FeedbackImage?
    private let client: any DemoReporterClient

    init(client: any DemoReporterClient) {
        self.client = client
    }

    var feedbackImageDescription: String {
        hasFeedbackImage ? L10n.tr("feedback.image.attached") : L10n.tr("feedback.image.none")
    }

    func attachSampleImage() {
        feedbackImage = SampleFeedbackImageFactory.make()
        hasFeedbackImage = true
        isError = false
        statusMessage = L10n.tr("status.ready")
    }

    func clearFeedbackImage() {
        feedbackImage = nil
        hasFeedbackImage = false
        isError = false
        statusMessage = L10n.tr("status.ready")
    }

    func sendStartReport() async {
        await perform(successMessage: L10n.tr("status.start.success")) {
            try await self.client.sendStartReport(token: self.token, chatID: self.chatID, additional: self.additional)
        }
    }

    func sendCustomEvent() async {
        await perform(successMessage: L10n.tr("status.custom.success")) {
            try await self.client.sendCustomEvent(
                token: self.token,
                chatID: self.chatID,
                title: self.customTitle,
                details: CustomDetailsParser.defaultDetails(),
                additional: self.additional
            )
        }
    }

    func sendFeedback() async {
        let successMessage = hasFeedbackImage
            ? L10n.tr("status.feedback.success_with_image")
            : L10n.tr("status.feedback.success")

        await perform(successMessage: successMessage) {
            try await self.client.sendFeedback(
                token: self.token,
                chatID: self.chatID,
                additional: self.additional,
                text: self.feedbackText,
                image: self.feedbackImage
            )
        }
    }

    private func perform(
        successMessage: String,
        operation: @escaping () async throws -> Void
    ) async {
        isSending = true
        defer { isSending = false }

        do {
            try await operation()
            isError = false
            statusMessage = successMessage
        } catch {
            isError = true
            statusMessage = L10n.format("status.failure", error.localizedDescription)
        }
    }
}
