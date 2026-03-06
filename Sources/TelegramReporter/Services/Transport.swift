import Foundation

enum Transport {
    typealias Attachment = TransportAttachment
    typealias TransportError = TelegramTransportError

    private static let sendMessageEndpoint = "https://api.telegram.org/bot%@/sendMessage"
    private static let sendPhotoEndpoint = "https://api.telegram.org/bot%@/sendPhoto"

    static func send(_ text: String, using cfg: Config, attachment: Attachment? = nil) async throws {
        if let attachment {
            try await sendPhoto(text, using: cfg, attachment: attachment)
            return
        }

        ReporterLogger.log("Transport.send", "Creating message request for chatID=\(cfg.chatID), textLength=\(text.count)")
        let url = URL(string: String(format: sendMessageEndpoint, cfg.token))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = TransportSendMessagePayload(
            chatID: cfg.chatID,
            text: text,
            disableWebPagePreview: true
        )
        let body = try JSONEncoder().encode(payload)
        request.httpBody = body
        ReporterLogger.log("Transport.send", "Request payload encoded, bodyLength=\(body.count)")
        try await sendRequest(request)
    }

    private static func sendPhoto(_ text: String, using cfg: Config, attachment: Attachment) async throws {
        ReporterLogger.log(
            "Transport.sendPhoto",
            "Creating photo request for chatID=\(cfg.chatID), captionLength=\(text.count), fileName=\(attachment.fileName), mimeType=\(attachment.mimeType), fileSize=\(attachment.data.count)"
        )
        let url = URL(string: String(format: sendPhotoEndpoint, cfg.token))!
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let body = makePhotoMultipartBody(
            chatID: cfg.chatID,
            caption: text,
            attachment: attachment,
            boundary: boundary
        )
        request.httpBody = body
        ReporterLogger.log("Transport.sendPhoto", "Multipart payload encoded, bodyLength=\(body.count)")
        try await sendRequest(request)
    }

    private static func sendRequest(_ request: URLRequest) async throws {
        let (data, response) = try await URLSession.shared.data(for: request)
        ReporterLogger.log("Transport.send", "Response received, bodyLength=\(data.count)")
        guard let http = response as? HTTPURLResponse else {
            ReporterLogger.log("Transport.send", "Invalid non-HTTP response")
            throw TransportError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "No response body"
            ReporterLogger.log("Transport.send", "Server error status=\(http.statusCode), body=\(body)")
            throw TransportError.serverError(statusCode: http.statusCode, body: body)
        }
        ReporterLogger.log("Transport.send", "Message delivered successfully with status=\(http.statusCode)")
    }

    private static func makePhotoMultipartBody(
        chatID: String,
        caption: String,
        attachment: Attachment,
        boundary: String
    ) -> Data {
        var builder = TransportMultipartBodyBuilder(boundary: boundary)
        builder.addTextField(name: "chat_id", value: chatID)
        builder.addTextField(name: "caption", value: caption)
        builder.addFileField(name: "photo", attachment: attachment)
        builder.finalize()
        return builder.build()
    }
}
