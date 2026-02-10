//
//  Transport.swift
//

import Foundation

enum Transport {
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
        let url = URL(string: "https://api.telegram.org/bot\(cfg.token)/sendMessage")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "chat_id": cfg.chatID,
            "text": text,
            "disable_web_page_preview": true
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw TransportError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "No response body"
            throw TransportError.serverError(statusCode: http.statusCode, body: body)
        }
    }
}
