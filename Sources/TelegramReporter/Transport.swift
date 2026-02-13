//
//  Transport.swift
//

import Foundation

enum Transport {
    private static let sendMessageEndpoint = "https://api.telegram.org/bot%@/sendMessage"

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

    static func send(_ text: String, using cfg: Config) async throws {
        ReporterLogger.log("Transport.send", "Creating request for chatID=\(cfg.chatID), textLength=\(text.count)")
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
}
