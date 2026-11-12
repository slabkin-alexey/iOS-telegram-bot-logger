import Foundation

enum TelegramTransportError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int, body: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Telegram API URL (check bot token)"
        case .invalidResponse:
            return "Invalid HTTP response from Telegram API"
        case let .serverError(statusCode, body):
            return "Telegram API error (HTTP \(statusCode)): \(body)"
        }
    }
}
