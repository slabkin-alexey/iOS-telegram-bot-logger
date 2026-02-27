import Foundation

struct ReportViewModel {
    let event: TelegramReporterEvent
    let additional: String

    var message: String {
        MessageBuilder.build(event, additional: additional)
    }

    var attachment: Transport.Attachment? {
        switch event {
        case .feedback(_, let image):
            guard let image else {
                ReporterLogger.log("ReportViewModel.attachment", "Feedback event has no embedded image")
                return nil
            }
            ReporterLogger.log(
                "ReportViewModel.attachment",
                "Using embedded feedback image, fileName=\(image.fileName), mimeType=\(image.mimeType), size=\(image.data.count)"
            )
            return Transport.Attachment(data: image.data, fileName: image.fileName, mimeType: image.mimeType)
        default:
            return nil
        }
    }
}
