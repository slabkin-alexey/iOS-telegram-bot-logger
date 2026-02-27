import Foundation

struct TransportSendMessagePayload: Encodable {
    let chatID: String
    let text: String
    let disableWebPagePreview: Bool

    enum CodingKeys: String, CodingKey {
        case chatID = "chat_id"
        case text
        case disableWebPagePreview = "disable_web_page_preview"
    }
}
