//
//  Transport.swift
//

import Foundation

enum Transport {
    private static let sendMessageEndpoint = "https://api.telegram.org/bot%@/sendMessage"
    private static let sendPhotoEndpoint = "https://api.telegram.org/bot%@/sendPhoto"

    private struct SendMessagePayload: Encodable {
        let chatID: String
        let text: String
        let disableWebPagePreview: Bool

        enum CodingKeys: String, CodingKey {
            case chatID = "chat_id"
            case text
            case disableWebPagePreview = "disable_web_page_preview"
        }
    }

    struct Attachment {
        let data: Data
        let fileName: String
        let mimeType: String
    }

    enum TransportError: LocalizedError {
        case invalidResponse
        case serverError(statusCode: Int, body: String)

        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Invalid HTTP response from Telegram API"
            case let .serverError(statusCode, body):
                return "Telegram API error (HTTP \(statusCode)): \(body)"
            }
        }
    }

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

        let payload = SendMessagePayload(
            chatID: cfg.chatID,
            text: text,
            disableWebPagePreview: true
        )
        request.httpBody = try JSONEncoder().encode(payload)
        ReporterLogger.log("Transport.send", "Request payload encoded, bodyLength=\(request.httpBody?.count ?? 0)")
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
        request.httpBody = makePhotoMultipartBody(
            chatID: cfg.chatID,
            caption: text,
            attachment: attachment,
            boundary: boundary
        )
        ReporterLogger.log("Transport.sendPhoto", "Multipart payload encoded, bodyLength=\(request.httpBody?.count ?? 0)")
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
        let lineBreak = "\r\n"
        var body = Data()

        func append(_ value: String) {
            body.append(Data(value.utf8))
        }

        append("--\(boundary)\(lineBreak)")
        append("Content-Disposition: form-data; name=\"chat_id\"\(lineBreak)\(lineBreak)")
        append("\(chatID)\(lineBreak)")

        append("--\(boundary)\(lineBreak)")
        append("Content-Disposition: form-data; name=\"caption\"\(lineBreak)\(lineBreak)")
        append("\(caption)\(lineBreak)")

        append("--\(boundary)\(lineBreak)")
        append("Content-Disposition: form-data; name=\"photo\"; filename=\"\(attachment.fileName)\"\(lineBreak)")
        append("Content-Type: \(attachment.mimeType)\(lineBreak)\(lineBreak)")
        body.append(attachment.data)
        append(lineBreak)

        append("--\(boundary)--\(lineBreak)")
        return body
    }
}
