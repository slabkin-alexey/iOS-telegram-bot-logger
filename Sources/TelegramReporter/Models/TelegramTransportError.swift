import Foundation

enum TelegramTransportError: LocalizedError {
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
