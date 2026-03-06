import Foundation

enum TransportSendMessagePayloadKey: String, CodingKey {
    case chatID = "chat_id"
    case text
    case disableWebPagePreview = "disable_web_page_preview"
}
