import Foundation

struct TransportSendMessagePayload: Encodable {
    let chatID: String
    let text: String
    let disableWebPagePreview: Bool

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: TransportSendMessagePayloadKey.self)
        try container.encode(chatID, forKey: .chatID)
        try container.encode(text, forKey: .text)
        try container.encode(disableWebPagePreview, forKey: .disableWebPagePreview)
    }
}
