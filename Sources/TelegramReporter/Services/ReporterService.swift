import Foundation

enum ReporterService {
    static func report(
        event: TelegramReporterEvent,
        token: String,
        chatID: String,
        additional: String,
        attachment: Transport.Attachment? = nil
    ) async throws {
        ReporterLogger.log("ReporterService.report", "Preparing event=\(event.logName), chatID=\(chatID)")
        let cfg = Config(token: token, chatID: chatID)
        let viewModel = ReportViewModel(event: event, additional: additional)
        let routedAttachment = attachment ?? viewModel.attachment
        ReporterLogger.log("ReporterService.report", "Built message for event=\(event.logName), length=\(viewModel.message.count)")
        try await Transport.send(viewModel.message, using: cfg, attachment: routedAttachment)
        ReporterLogger.log("ReporterService.report", "Sent event=\(event.logName) successfully")
    }
}
